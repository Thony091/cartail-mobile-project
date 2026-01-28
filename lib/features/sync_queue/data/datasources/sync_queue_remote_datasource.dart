import '../../domain/entities/sync_queue_item.dart';

abstract class SyncQueueRemoteDatasource {
  Future<void> execute(SyncQueueItem item);
}
