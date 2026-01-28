
import '../../../../core/connectivity/connectivity_service.dart';
import '../../../../core/offline_first/offline_first_executor.dart';
import '../../../sync_queue/domain/entities/sync_queue_item.dart';
import '../../../sync_queue/domain/repositories/sync_queue_repository.dart';
import '../../domain/entities/reservation.dart';
import '../../domain/entities/reservation_payment_init.dart';
import '../../domain/repositories/reservation_repository.dart';
import '../datasources/local/reservation_local_datasource.dart';
import '../datasources/reservation_datasources.dart';
import '../models/reservation_model.dart';
import '../../../shared/data/models/isar_domain_models.dart' as isar_models;

class ReservationRepositoryImpl extends ReservationRepository {
  static const int _paidStatusId = 2;

  ReservationRepositoryImpl({
    required ReservationDatasource remoteDatasource,
    required ReservationLocalDatasource localDatasource,
    required ConnectivityService connectivityService,
    required SyncQueueRepository syncQueueRepository,
  })  : _remoteDatasource = remoteDatasource,
        _localDatasource = localDatasource,
        _offlineFirstExecutor = OfflineFirstExecutor(
          connectivityService: connectivityService,
          syncQueueRepository: syncQueueRepository,
        );

  final ReservationDatasource _remoteDatasource;
  final ReservationLocalDatasource _localDatasource;
  final OfflineFirstExecutor _offlineFirstExecutor;

  @override
  Future<List<Reservation>> getReservations() {
    return _offlineFirstExecutor.readStaleWhileRevalidate<List<Reservation>>(
      local: () async {
        final models = await _localDatasource.getAll();
        return models.map(_isarToEntity).toList();
      },
      remote: _remoteDatasource.getReservations,
      cache: (reservations) async {
        await _cacheAll(reservations);
      },
      isEmpty: (reservations) => reservations.isEmpty,
    );
  }

  @override
  Future<Reservation> getReservationById(String id) {
    return _offlineFirstExecutor.readStaleWhileRevalidate<Reservation>(
      local: () async {
        final model = await _localDatasource.getByBackendId(id);
        if (model == null) {
          throw StateError('Reservation not found locally: $id');
        }
        return _isarToEntity(model);
      },
      remote: () => _remoteDatasource.getReservationById(id),
      cache: (reservation) async {
        await _localDatasource.upsert(_entityToIsar(reservation, isSynced: true));
      },
    );
  }

  @override
  Future<Reservation> createUpdateReservation(Map<String, dynamic> reservationSimilar) {
    final entity = ReservationModel.fromJson(reservationSimilar).toEntity();
    final action = _actionFromMap(reservationSimilar);

    return _offlineFirstExecutor.write<Reservation>(
      localWrite: () async {
        // No guardar local hasta confirmación desde WebView.
        final localEntity = _ensureBackendId(entity);
        return localEntity;
      },
      remoteWrite: () => _remoteDatasource.createUpdateReservation(reservationSimilar),
      cache: (reservation) async {
        // No cachear reservas hasta confirmación explícita de pago.
        return;
      },
      queueItem: () => SyncQueueItem.newItem(
        action: action,
        entity: SyncEntityType.reservation,
        payload: ReservationModel.fromEntity(entity).toJson(),
      ),
    );
  }

  @override
  Future<ReservationPaymentInit> iniciarPagoReserva(
    Map<String, dynamic> reservationSimilar,
  ) {
    return _remoteDatasource.pagarReserva(reservationSimilar);
  }

  @override
  Future<void> guardarReservaConfirmadaLocal(Reservation reservation) async {
    final paidReservation = _markAsPaid(reservation);
    await _localDatasource.upsert(
      _entityToIsar(paidReservation, isSynced: true),
    );
  }

  @override
  Future<void> deleteReservation(String id) {
    return _offlineFirstExecutor.write<void>(
      localWrite: () async {
        await _localDatasource.deleteByBackendId(id);
      },
      remoteWrite: () => _remoteDatasource.deleteReservation(id),
      cache: (_) async {},
      queueItem: () => SyncQueueItem.newItem(
        action: SyncActionType.delete,
        entity: SyncEntityType.reservation,
        payload: {'id': id},
      ),
    );
  }

  Future<void> _cacheAll(List<Reservation> reservations) async {
    // No cachear listado de reservas antes de confirmación de pago.
    return;
  }

  Reservation _isarToEntity(isar_models.ReservationModel model) {
    return Reservation(
      id: model.backendId,
      name: model.name,
      rut: model.rut,
      email: model.email,
      reservationDate: model.reservationDate,
      reservationTime: model.reservationTime,
      serviceName: model.serviceId?.toString() ?? '',
      vehiclePlate: model.vehiclePlate,
      endTimeEstimated: model.endTimeEstimated,
      customerNotes: model.customerNotes,
      mechanicNotes: model.mechanicNotes,
      reminder: model.reminder,
      statusId: model.statusId,
      serviceId: model.serviceId,
      clientId: model.clientId,
      slotId: model.slotId,
    );
  }

  isar_models.ReservationModel _entityToIsar(Reservation reservation,
      {required bool isSynced}) {
    return isar_models.ReservationModel()
      ..backendId = reservation.id
      ..name = reservation.name
      ..rut = reservation.rut
      ..email = reservation.email
      ..reservationDate = reservation.reservationDate
      ..reservationTime = reservation.reservationTime
      ..vehiclePlate = reservation.vehiclePlate
      ..endTimeEstimated = reservation.endTimeEstimated
      ..customerNotes = reservation.customerNotes
      ..mechanicNotes = reservation.mechanicNotes
      ..reminder = reservation.reminder
      ..statusId = reservation.statusId
      ..serviceId = reservation.serviceId
      ..clientId = reservation.clientId
      ..slotId = reservation.slotId
      ..isSynced = isSynced
      ..updatedAt = DateTime.now();
  }

  Reservation _ensureBackendId(Reservation reservation) {
    if (reservation.id.isNotEmpty) return reservation;
    return Reservation(
      id: _localId(),
      name: reservation.name,
      rut: reservation.rut,
      email: reservation.email,
      reservationDate: reservation.reservationDate,
      reservationTime: reservation.reservationTime,
      serviceName: reservation.serviceName,
      vehiclePlate: reservation.vehiclePlate,
      endTimeEstimated: reservation.endTimeEstimated,
      customerNotes: reservation.customerNotes,
      mechanicNotes: reservation.mechanicNotes,
      reminder: reservation.reminder,
      statusId: reservation.statusId,
      serviceId: reservation.serviceId,
      clientId: reservation.clientId,
      slotId: reservation.slotId,
    );
  }

  Reservation _markAsPaid(Reservation reservation) {
    final reservationId =
        reservation.id.isNotEmpty ? reservation.id : _localId();

    return Reservation(
      id: reservationId,
      name: reservation.name,
      rut: reservation.rut,
      email: reservation.email,
      reservationDate: reservation.reservationDate,
      reservationTime: reservation.reservationTime,
      serviceName: reservation.serviceName,
      vehiclePlate: reservation.vehiclePlate,
      endTimeEstimated: reservation.endTimeEstimated,
      customerNotes: reservation.customerNotes,
      mechanicNotes: reservation.mechanicNotes,
      reminder: reservation.reminder,
      // Ajustar este id si el backend usa otro valor para "PAGADA".
      statusId: _paidStatusId,
      serviceId: reservation.serviceId,
      clientId: reservation.clientId,
      slotId: reservation.slotId,
    );
  }

  String _localId() => DateTime.now().millisecondsSinceEpoch.toString();

  SyncActionType _actionFromMap(Map<String, dynamic> payload) {
    final id = payload['id']?.toString() ?? payload['backendId']?.toString();
    return (id == null || id.isEmpty) ? SyncActionType.create : SyncActionType.update;
  }

  bool _shouldCache(Reservation reservation) {
    return reservation.statusId == _paidStatusId;
  }
}
