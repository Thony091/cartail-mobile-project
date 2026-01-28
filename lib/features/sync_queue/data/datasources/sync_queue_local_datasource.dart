import 'package:isar_community/isar.dart';

import '../../../../config/services/storage/isar_service.dart';
import '../models/sync_queue_item_model.dart';

class SyncQueueLocalDatasource {
  SyncQueueLocalDatasource({required IsarService isarService})
      : _isarService = isarService;

  final IsarService _isarService;

  Isar get _isar => _isarService.isar;

  Future<void> enqueue(SyncQueueItemModel model) async {
    await _isar.writeTxn(() async {
      await _isar.syncQueueItemModels.put(model);
    });
  }

  Future<List<SyncQueueItemModel>> getPending() async {
    return _isar.syncQueueItemModels
        .filter()
        .statusEqualTo('pending')
        .sortByCreatedAt()
        .findAll();
  }

  Future<void> markProcessing(String syncId) async {
    await _updateBySyncId(syncId, (item) {
      item.status = 'processing';
      item.lastTriedAt = DateTime.now();
    });
  }

  Future<void> markSynced(String syncId) async {
    await _updateBySyncId(syncId, (item) {
      item.status = 'synced';
      item.lastTriedAt = DateTime.now();
    });
  }

  Future<void> markFailed(String syncId, String error) async {
    await _updateBySyncId(syncId, (item) {
      item.status = 'failed';
      item.lastError = error;
      item.lastTriedAt = DateTime.now();
    });
  }

  Future<void> incrementRetry(String syncId, String error) async {
    await _updateBySyncId(syncId, (item) {
      item.retryCount += 1;
      item.lastError = error;
      item.lastTriedAt = DateTime.now();
      item.status = 'pending';
    });
  }

  Future<void> purgeSynced() async {
    await _isar.writeTxn(() async {
      final syncedIds = await _isar.syncQueueItemModels
          .filter()
          .statusEqualTo('synced')
          .idProperty()
          .findAll();
      await _isar.syncQueueItemModels.deleteAll(syncedIds);
    });
  }

  Future<void> _updateBySyncId(
    String syncId,
    void Function(SyncQueueItemModel item) updater,
  ) async {
    await _isar.writeTxn(() async {
      final item = await _isar.syncQueueItemModels
          .filter()
          .syncIdEqualTo(syncId)
          .findFirst();
      if (item == null) return;
      updater(item);
      await _isar.syncQueueItemModels.put(item);
    });
  }
}
