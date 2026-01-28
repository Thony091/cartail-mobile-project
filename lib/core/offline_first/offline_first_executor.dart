import '../connectivity/connectivity_service.dart';
import '../connectivity/connectivity_status.dart';
import '../../features/sync_queue/domain/entities/sync_queue_item.dart';
import '../../features/sync_queue/domain/repositories/sync_queue_repository.dart';

/// Mental map (write flow):
///
///  if ONLINE_STABLE:
///    remote() -> cache() -> return
///  if LOW_CONNECTION:
///    try remote with short timeout OR fallback to local + queue
///  if OFFLINE:
///    localWrite() -> enqueue(SyncQueueItem) -> return
///
class OfflineFirstExecutor {
  final ConnectivityService connectivityService;
  final SyncQueueRepository syncQueueRepository;

  /// Timeout for remote operations when connection is low
  static const Duration _lowConnectionTimeout = Duration(seconds: 5);

  OfflineFirstExecutor({
    required this.connectivityService,
    required this.syncQueueRepository,
  });

  Future<T> read<T>({
    required Future<T> Function() local,
    required Future<T> Function() remote,
    required Future<void> Function(T data) cache,
  }) async {
    final snapshot = await _latest();

    // Always use local in offline mode
    if (snapshot.state == ConnectivityState.offline) {
      return local();
    }

    // For low connection, try remote with timeout, fallback to local
    if (snapshot.state == ConnectivityState.lowConnection) {
      try {
        final result = await remote().timeout(_lowConnectionTimeout);
        await cache(result);
        return result;
      } catch (e) {
        // Timeout or error - fallback to local
        return local();
      }
    }

    // Online stable - use remote normally
    final result = await remote();
    await cache(result);
    return result;
  }

  Future<T> write<T>({
    required Future<T> Function() localWrite,
    required Future<T> Function() remoteWrite,
    required Future<void> Function(T data) cache,
    required SyncQueueItem Function() queueItem,
  }) async {
    final snapshot = await _latest();

    // Always use local + queue in offline mode
    if (snapshot.state == ConnectivityState.offline) {
      final localResult = await localWrite();
      await syncQueueRepository.enqueue(queueItem());
      return localResult;
    }

    // For low connection, try remote with timeout, fallback to local + queue
    if (snapshot.state == ConnectivityState.lowConnection) {
      try {
        final remoteResult = await remoteWrite().timeout(_lowConnectionTimeout);
        await cache(remoteResult);
        return remoteResult;
      } catch (e) {
        // Timeout or error - fallback to local + queue
        final localResult = await localWrite();
        await syncQueueRepository.enqueue(queueItem());
        return localResult;
      }
    }

    // Online stable - use remote normally
    final remoteResult = await remoteWrite();
    await cache(remoteResult);
    return remoteResult;
  }

  Future<ConnectivitySnapshot> _latest() async {
    try {
      return await connectivityService.stream.first.timeout(
        const Duration(seconds: 2),
        onTimeout: () => ConnectivitySnapshot(
          state: ConnectivityState.offline,
          latencyMs: null,
          consecutiveFailures: 0,
          failureRate: 1.0,
          checkedAt: DateTime.now(),
        ),
      );
    } catch (e) {
      // Fallback to offline if stream has issues
      return ConnectivitySnapshot(
        state: ConnectivityState.offline,
        latencyMs: null,
        consecutiveFailures: 0,
        failureRate: 1.0,
        checkedAt: DateTime.now(),
      );
    }
  }
}
