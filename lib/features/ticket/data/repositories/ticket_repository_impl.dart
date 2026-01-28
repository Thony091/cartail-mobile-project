import '../../../../core/connectivity/connectivity_service.dart';
import '../../../../core/offline_first/offline_first_executor.dart';
import '../../../sync_queue/domain/entities/sync_queue_item.dart';
import '../../../sync_queue/domain/repositories/sync_queue_repository.dart';
import '../../domain/entities/estado_ticket.dart';
import '../../domain/entities/importancia_ticket.dart';
import '../../domain/entities/ticket.dart';
import '../../domain/entities/urgencia_ticket.dart';
import '../../domain/repositories/ticket_repository.dart';
import '../datasources/local/ticket_local_datasource.dart';
import '../datasources/ticket_datasource.dart';
import '../models/ticket_model.dart';
import '../../../shared/data/models/isar_domain_models.dart' as isar_models;

class TicketRepositoryImpl extends TicketRepository {
  TicketRepositoryImpl({
    required TicketDatasource remoteDatasource,
    required TicketLocalDatasource localDatasource,
    required ConnectivityService connectivityService,
    required SyncQueueRepository syncQueueRepository,
  })  : _remoteDatasource = remoteDatasource,
        _localDatasource = localDatasource,
        _offlineFirstExecutor = OfflineFirstExecutor(
          connectivityService: connectivityService,
          syncQueueRepository: syncQueueRepository,
        );

  final TicketDatasource _remoteDatasource;
  final TicketLocalDatasource _localDatasource;
  final OfflineFirstExecutor _offlineFirstExecutor;

  @override
  Future<List<Ticket>> getTickets() {
    return _offlineFirstExecutor.read<List<Ticket>>(
      local: () async {
        final models = await _localDatasource.getAll();
        return models.map(_isarToEntity).toList();
      },
      remote: _remoteDatasource.getTickets,
      cache: (tickets) async {
        await _cacheAll(tickets);
      },
    );
  }

  @override
  Future<Ticket> getTicketById(String id) {
    return _offlineFirstExecutor.read<Ticket>(
      local: () async {
        final model = await _localDatasource.getByBackendId(id);
        if (model == null) {
          throw StateError('Ticket not found locally: $id');
        }
        return _isarToEntity(model);
      },
      remote: () => _remoteDatasource.getTicketById(id),
      cache: (ticket) async {
        await _localDatasource.upsert(_entityToIsar(ticket, isSynced: true));
      },
    );
  }

  @override
  Future<Ticket> createUpdateTicket(Map<String, dynamic> ticketSimilar) {
    final entity = TicketModel.fromJson(ticketSimilar).toEntity();
    final action = _actionFromMap(ticketSimilar);

    return _offlineFirstExecutor.write<Ticket>(
      localWrite: () async {
        final localEntity = _ensureBackendId(entity);
        await _localDatasource.upsert(
          _entityToIsar(localEntity, isSynced: false),
        );
        return localEntity;
      },
      remoteWrite: () => _remoteDatasource.createUpdateTicket(ticketSimilar),
      cache: (ticket) async {
        await _localDatasource.upsert(_entityToIsar(ticket, isSynced: true));
      },
      queueItem: () => SyncQueueItem.newItem(
        action: action,
        entity: SyncEntityType.ticket,
        payload: TicketModel.fromEntity(entity).toJson(),
      ),
    );
  }

  @override
  Future<void> deleteTicket(String id) {
    return _offlineFirstExecutor.write<void>(
      localWrite: () async {
        await _localDatasource.deleteByBackendId(id);
      },
      remoteWrite: () => _remoteDatasource.deleteTicket(id),
      cache: (_) async {},
      queueItem: () => SyncQueueItem.newItem(
        action: SyncActionType.delete,
        entity: SyncEntityType.ticket,
        payload: {'id': id},
      ),
    );
  }

  Future<void> _cacheAll(List<Ticket> tickets) async {
    for (final ticket in tickets) {
      await _localDatasource.upsert(_entityToIsar(ticket, isSynced: true));
    }
  }

  Ticket _isarToEntity(isar_models.TicketModel model) {
    return Ticket(
      id: int.tryParse(model.backendId) ?? 0,
      nombre: model.nombre,
      description: model.description,
      desde: model.desde,
      hasta: model.hasta,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      idServicio: model.idServicio ?? 0,
      idUser: model.idUser,
      idReserva: model.reservationId,
      estado: EstadoTicket(id: 0, nombre: model.estado),
      importancia: ImportanciaTicket(id: 0, nombre: model.importancia),
      urgencia: UrgenciaTicket(id: 0, nombre: model.urgencia),
    );
  }

  isar_models.TicketModel _entityToIsar(Ticket ticket, {required bool isSynced}) {
    return isar_models.TicketModel()
      ..backendId = ticket.id.toString()
      ..reservationId = ticket.idReserva
      ..nombre = ticket.nombre
      ..description = ticket.description
      ..desde = ticket.desde
      ..hasta = ticket.hasta
      ..createdAt = ticket.createdAt
      ..updatedAt = ticket.updatedAt
      ..idServicio = ticket.idServicio
      ..idUser = ticket.idUser
      ..estado = ticket.estado.nombre
      ..importancia = ticket.importancia.nombre
      ..urgencia = ticket.urgencia.nombre
      ..isSynced = isSynced;
  }

  Ticket _ensureBackendId(Ticket ticket) {
    if (ticket.id != 0) return ticket;
    return ticket.copyWith(id: DateTime.now().millisecondsSinceEpoch);
  }

  SyncActionType _actionFromMap(Map<String, dynamic> payload) {
    final id = payload['id']?.toString() ?? payload['backendId']?.toString();
    return (id == null || id.isEmpty) ? SyncActionType.create : SyncActionType.update;
  }
}
