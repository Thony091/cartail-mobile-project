import '../../domain/entities/sync_queue_item.dart';
import '../../domain/repositories/sync_queue_repository.dart';
import '../datasources/sync_queue_local_datasource.dart';
import '../mappers/sync_queue_mapper.dart';

class SyncQueueRepositoryImpl implements SyncQueueRepository {
  SyncQueueRepositoryImpl({
    required SyncQueueLocalDatasource localDatasource,
    SyncQueueMapper? mapper,
  })  : _localDatasource = localDatasource,
        _mapper = mapper ?? SyncQueueMapper();

  final SyncQueueLocalDatasource _localDatasource;
  final SyncQueueMapper _mapper;

  @override
  Future<void> enqueue(SyncQueueItem item) async {
    await _localDatasource.enqueue(_mapper.toModel(item));
  }

  @override
  Future<List<SyncQueueItem>> getPending() async {
    final models = await _localDatasource.getPending();
    return models.map(_mapper.toEntity).toList();
  }

  @override
  Future<void> markProcessing(String syncId) {
    return _localDatasource.markProcessing(syncId);
  }

  @override
  Future<void> markSynced(String syncId) {
    return _localDatasource.markSynced(syncId);
  }

  @override
  Future<void> markFailed(String syncId, String error) {
    return _localDatasource.markFailed(syncId, error);
  }

  @override
  Future<void> incrementRetry(String syncId, String error) {
    return _localDatasource.incrementRetry(syncId, error);
  }

  @override
  Future<void> purgeSynced() {
    return _localDatasource.purgeSynced();
  }
}
