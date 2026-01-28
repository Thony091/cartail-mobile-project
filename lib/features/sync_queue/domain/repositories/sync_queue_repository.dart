import '../entities/sync_queue_item.dart';

abstract class SyncQueueRepository {
  Future<void> enqueue(SyncQueueItem item);
  Future<List<SyncQueueItem>> getPending();
  Future<void> markProcessing(String syncId);
  Future<void> markSynced(String syncId);
  Future<void> markFailed(String syncId, String error);
  Future<void> incrementRetry(String syncId, String error);
  Future<void> purgeSynced();
}
