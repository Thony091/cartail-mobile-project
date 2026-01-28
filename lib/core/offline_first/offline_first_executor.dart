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
  static const Duration _lowConnectionTimeout = Duration(seconds: 10);

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

    // For offline mode with read operations, try remote with generous timeout
    // This allows initial data loading even with very slow connections
    if (snapshot.state == ConnectivityState.offline) {
      try {
        final result = await remote().timeout(const Duration(seconds: 15));
        await cache(result);
        return result;
      } catch (e) {
        // If remote fails/timeout, use local
        return local();
      }
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

  /// Stale-while-revalidate:
  /// - Retorna el cache local inmediatamente (si existe).
  /// - En paralelo intenta remoto y actualiza cache.
  /// - Si el cache local está vacío o falla, espera remoto.
  Future<T> readStaleWhileRevalidate<T>({
    required Future<T> Function() local,
    required Future<T> Function() remote,
    required Future<void> Function(T data) cache,
    bool Function(T data)? isEmpty,
  }) async {
    T? localResult;
    var localOk = false;

    try {
      localResult = await local();
      localOk = true;
    } catch (_) {
      localOk = false;
    }

    final snapshot = await _latest();

    Future<T> remoteFuture() async {
      if (snapshot.state == ConnectivityState.offline) {
        return remote().timeout(const Duration(seconds: 15));
      }
      if (snapshot.state == ConnectivityState.lowConnection) {
        return remote().timeout(_lowConnectionTimeout);
      }
      return remote();
    }

    Future<void> runRemoteAndCache() async {
      final result = await remoteFuture();
      await cache(result);
    }

    if (localOk) {
      final shouldWaitRemote =
          isEmpty != null ? isEmpty(localResult as T) : false;
      print('📊 OfflineFirstExecutor.readStaleWhileRevalidate() - localOk=$localOk, shouldWaitRemote=$shouldWaitRemote');
      if (!shouldWaitRemote) {
        // Fire-and-forget: revalida en background.
        // ignore: unawaited_futures
        runRemoteAndCache();
        print('🔄 OfflineFirstExecutor - Returning local data, revalidating in background');
        return localResult as T;
      }
    }

    try {
      print('⏳ OfflineFirstExecutor - Waiting for remote...');
      final result = await remoteFuture();
      print('✅ OfflineFirstExecutor - Got remote result, caching...');
      await cache(result);
      print('✅ OfflineFirstExecutor - Cached, returning result');
      return result;
    } catch (e) {
      print('❌ OfflineFirstExecutor - Remote failed: $e');
      if (localOk) {
        print('🔄 OfflineFirstExecutor - Returning local fallback');
        return localResult as T;
      }
      rethrow;
    }
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
