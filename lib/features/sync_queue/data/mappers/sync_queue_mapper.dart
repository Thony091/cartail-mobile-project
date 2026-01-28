import '../../domain/entities/sync_queue_item.dart';
import '../models/sync_queue_item_model.dart';

class SyncQueueMapper {
  SyncQueueItemModel toModel(SyncQueueItem entity) {
    return SyncQueueItemModel.fromEntity(entity);
  }

  SyncQueueItem toEntity(SyncQueueItemModel model) {
    return model.toEntity();
  }
}
