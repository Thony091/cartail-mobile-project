import '../../../../core/connectivity/connectivity_service.dart';
import '../../../../core/offline_first/offline_first_executor.dart';
import '../../../sync_queue/domain/entities/sync_queue_item.dart';
import '../../../sync_queue/domain/repositories/sync_queue_repository.dart';
import '../../domain/entities/slot.dart';
import '../../domain/repositories/slot_repository.dart';
import '../datasources/local/slot_local_datasource.dart';
import '../datasources/slot_datasource.dart';
import '../models/slot_model.dart';
import '../../../shared/data/models/isar_domain_models.dart' as isar_models;

class SlotRepositoryImpl extends SlotRepository {
  SlotRepositoryImpl({
    required SlotDatasource remoteDatasource,
    required SlotLocalDatasource localDatasource,
    required ConnectivityService connectivityService,
    required SyncQueueRepository syncQueueRepository,
  })  : _remoteDatasource = remoteDatasource,
        _localDatasource = localDatasource,
        _offlineFirstExecutor = OfflineFirstExecutor(
          connectivityService: connectivityService,
          syncQueueRepository: syncQueueRepository,
        );

  final SlotDatasource _remoteDatasource;
  final SlotLocalDatasource _localDatasource;
  final OfflineFirstExecutor _offlineFirstExecutor;

  @override
  Future<List<Slot>> getSlots() {
    return _offlineFirstExecutor.read<List<Slot>>(
      local: () async {
        final models = await _localDatasource.getAll();
        return models.map(_isarToEntity).toList();
      },
      remote: _remoteDatasource.getSlots,
      cache: (slots) async {
        await _cacheAll(slots);
      },
    );
  }

  @override
  Future<List<Slot>> getSlotsByService(String serviceId) {
    return _offlineFirstExecutor.read<List<Slot>>(
      local: () async {
        final models = await _localDatasource.getAll();
        return models
            .where((model) => model.service.value?.backendId == serviceId)
            .map(_isarToEntity)
            .toList();
      },
      remote: () => _remoteDatasource.getSlotsByService(serviceId),
      cache: (slots) async {
        await _cacheAll(slots);
      },
    );
  }

  @override
  Future<List<Slot>> getAvailableSlots(DateTime date) {
    final dateKey = _formatDate(date);
    return _offlineFirstExecutor.read<List<Slot>>(
      local: () async {
        final models = await _localDatasource.getByDate(dateKey);
        return models.map(_isarToEntity).where((slot) => slot.isAvailable).toList();
      },
      remote: () => _remoteDatasource.getAvailableSlots(date),
      cache: (slots) async {
        await _cacheAll(slots);
      },
    );
  }

  @override
  Future<Slot> getSlotById(int id) {
    final backendId = id.toString();
    return _offlineFirstExecutor.read<Slot>(
      local: () async {
        final model = await _localDatasource.getByBackendId(backendId);
        if (model == null) {
          throw StateError('Slot not found locally: $backendId');
        }
        return _isarToEntity(model);
      },
      remote: () => _remoteDatasource.getSlotById(id),
      cache: (slot) async {
        await _localDatasource.upsert(_entityToIsar(slot, isSynced: true));
      },
    );
  }

  @override
  Future<Slot> createSlot(Slot slot) {
    final action = SyncActionType.create;
    return _offlineFirstExecutor.write<Slot>(
      localWrite: () async {
        final localEntity = _ensureBackendId(slot);
        await _localDatasource.upsert(
          _entityToIsar(localEntity, isSynced: false),
        );
        return localEntity;
      },
      remoteWrite: () => _remoteDatasource.createSlot(slot),
      cache: (slot) async {
        await _localDatasource.upsert(_entityToIsar(slot, isSynced: true));
      },
      queueItem: () => SyncQueueItem.newItem(
        action: action,
        entity: SyncEntityType.slot,
        payload: SlotModel.fromEntity(slot).toJson(),
      ),
    );
  }

  @override
  Future<Slot> updateSlot(Slot slot) {
    final action = SyncActionType.update;
    return _offlineFirstExecutor.write<Slot>(
      localWrite: () async {
        final localEntity = _ensureBackendId(slot);
        await _localDatasource.upsert(
          _entityToIsar(localEntity, isSynced: false),
        );
        return localEntity;
      },
      remoteWrite: () => _remoteDatasource.updateSlot(slot),
      cache: (slot) async {
        await _localDatasource.upsert(_entityToIsar(slot, isSynced: true));
      },
      queueItem: () => SyncQueueItem.newItem(
        action: action,
        entity: SyncEntityType.slot,
        payload: SlotModel.fromEntity(slot).toJson(),
      ),
    );
  }

  @override
  Future<void> deleteSlot(int id) {
    final backendId = id.toString();
    return _offlineFirstExecutor.write<void>(
      localWrite: () async {
        await _localDatasource.deleteByBackendId(backendId);
      },
      remoteWrite: () => _remoteDatasource.deleteSlot(id),
      cache: (_) async {},
      queueItem: () => SyncQueueItem.newItem(
        action: SyncActionType.delete,
        entity: SyncEntityType.slot,
        payload: {'id': backendId},
      ),
    );
  }

  Future<void> _cacheAll(List<Slot> slots) async {
    for (final slot in slots) {
      await _localDatasource.upsert(_entityToIsar(slot, isSynced: true));
    }
  }

  Slot _isarToEntity(isar_models.SlotModel model) {
    return Slot(
      id: int.tryParse(model.backendId) ?? 0,
      date: model.date,
      startTime: model.startTime,
      endTime: model.endTime,
      serviceId: 0,
      reservationId: null,
    );
  }

  isar_models.SlotModel _entityToIsar(Slot slot, {required bool isSynced}) {
    return isar_models.SlotModel()
      ..backendId = slot.id.toString()
      ..date = slot.date
      ..startTime = slot.startTime
      ..endTime = slot.endTime
      ..isSynced = isSynced
      ..updatedAt = DateTime.now();
  }

  Slot _ensureBackendId(Slot slot) {
    if (slot.id != 0) return slot;
    return Slot(
      id: DateTime.now().millisecondsSinceEpoch,
      date: slot.date,
      startTime: slot.startTime,
      endTime: slot.endTime,
      serviceId: slot.serviceId,
      reservationId: slot.reservationId,
    );
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
