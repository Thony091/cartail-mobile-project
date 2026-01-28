import 'dart:async';

import '../../features/sync_queue/domain/entities/sync_queue_item.dart';
import '../../features/sync_queue/domain/repositories/sync_queue_repository.dart';
import '../../features/sync_queue/data/datasources/sync_queue_remote_datasource.dart';
import '../connectivity/connectivity_service.dart';
import '../connectivity/connectivity_status.dart';
import '../logging/logger_service.dart';

/// Event emitted when sync queue processing completes or encounters issues
abstract class SyncQueueEvent {
  const SyncQueueEvent();
}

class SyncQueueStarted extends SyncQueueEvent {
  final int pendingCount;
  const SyncQueueStarted(this.pendingCount);
}

class SyncQueueItemSynced extends SyncQueueEvent {
  final String syncId;
  const SyncQueueItemSynced(this.syncId);
}

class SyncQueueItemFailed extends SyncQueueEvent {
  final String syncId;
  final String error;
  final bool isRetryable;

  const SyncQueueItemFailed(
    this.syncId,
    this.error, {
    required this.isRetryable,
  });
}

class SyncQueueCompleted extends SyncQueueEvent {
  final int syncedCount;
  final int failedCount;

  const SyncQueueCompleted({
    required this.syncedCount,
    required this.failedCount,
  });
}

/// Mental map (sync loop):
///
///  on connectivity ONLINE_STABLE
///      -> fetch pending queue
///      -> process in batches of 5 concurrently
///         -> execute remote
///         -> mark synced OR schedule retry w/ backoff
///      -> purge synced items
///
class SyncQueueProcessor {
  SyncQueueProcessor({
    required SyncQueueRepository repository,
    required SyncQueueRemoteDatasource remoteDatasource,
    required ConnectivityService connectivityService,
    SyncQueueBackoffPolicy? backoffPolicy,
  })  : _repository = repository,
        _remoteDatasource = remoteDatasource,
        _connectivityService = connectivityService,
        _backoffPolicy = backoffPolicy ?? const SyncQueueBackoffPolicy(),
        _pendingRetries = {};

  final SyncQueueRepository _repository;
  final SyncQueueRemoteDatasource _remoteDatasource;
  final ConnectivityService _connectivityService;
  final SyncQueueBackoffPolicy _backoffPolicy;

  /// Tracks pending retry timers to avoid duplicate retries
  final Map<String, Timer> _pendingRetries;

  /// Stream controller for sync queue events
  final StreamController<SyncQueueEvent> _eventController =
      StreamController<SyncQueueEvent>.broadcast();

  StreamSubscription<ConnectivitySnapshot>? _subscription;
  bool _isRunning = false;

  /// Batch size for concurrent sync operations
  static const int _batchSize = 5;

  /// TTL for sync queue items (7 days)
  static const Duration _itemTtl = Duration(days: 7);

  /// Stream of sync queue events
  Stream<SyncQueueEvent> get eventStream => _eventController.stream;

  Future<void> start() async {
    _subscription ??= _connectivityService.stream.listen(_onConnectivity);
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
    // Cancel all pending retry timers
    for (final timer in _pendingRetries.values) {
      timer.cancel();
    }
    _pendingRetries.clear();
    await _eventController.close();
  }

  Future<void> _onConnectivity(ConnectivitySnapshot snapshot) async {
    if (snapshot.state != ConnectivityState.onlineStable) return;
    if (_isRunning) return;
    _isRunning = true;
    try {
      await _processQueue();
    } finally {
      _isRunning = false;
    }
  }

  Future<void> _processQueue() async {
    final pending = await _repository.getPending();
    if (pending.isEmpty) return;

    _logDebug('[SyncQueue] Processing ${pending.length} pending items in batches of $_batchSize');
    _eventController.add(SyncQueueStarted(pending.length));

    int syncedCount = 0;
    int failedCount = 0;

    // Process items in batches to avoid blocking
    for (int i = 0; i < pending.length; i += _batchSize) {
      final batch = pending.sublist(
        i,
        (i + _batchSize < pending.length) ? i + _batchSize : pending.length,
      );

      // Process batch concurrently
      final results = await Future.wait(
        batch.map((item) => _processItem(item)),
        eagerError: false,
      );

      // Count results
      for (final result in results) {
        if (result) {
          syncedCount++;
        } else {
          failedCount++;
        }
      }
    }

    await _repository.purgeSynced();
    _logDebug('[SyncQueue] Batch processing complete - $syncedCount synced, $failedCount failed');
    _eventController.add(
      SyncQueueCompleted(syncedCount: syncedCount, failedCount: failedCount),
    );
  }

  /// Returns true if item was successfully synced, false if failed or retrying
  Future<bool> _processItem(SyncQueueItem item) async {
    // Check if item has exceeded TTL (7 days)
    final itemAge = DateTime.now().difference(item.createdAt);
    if (itemAge > _itemTtl) {
      await _repository.markFailed(
        item.syncId,
        'Item expired: created ${itemAge.inDays} days ago',
      );
      _logDebug('[SyncQueue] Item ${item.syncId} expired (${itemAge.inDays} days old)');
      _eventController.add(
        SyncQueueItemFailed(
          item.syncId,
          'Item expired',
          isRetryable: false,
        ),
      );
      return false;
    }

    try {
      await _repository.markProcessing(item.syncId);
      await _remoteDatasource.execute(item);
      await _repository.markSynced(item.syncId);
      _logDebug('[SyncQueue] Item ${item.syncId} synced successfully');
      _eventController.add(SyncQueueItemSynced(item.syncId));
      return true;
    } catch (err) {
      final nextRetry = item.retryCount + 1;
      if (nextRetry >= _backoffPolicy.maxRetries) {
        await _repository.markFailed(item.syncId, err.toString());
        _logDebug('[SyncQueue] Item ${item.syncId} failed after ${_backoffPolicy.maxRetries} retries: $err');
        _eventController.add(
          SyncQueueItemFailed(item.syncId, err.toString(), isRetryable: false),
        );
        return false;
      }

      // Schedule retry instead of blocking
      await _repository.incrementRetry(item.syncId, err.toString());
      final delay = _backoffPolicy.delayFor(nextRetry);
      _logDebug('[SyncQueue] Item ${item.syncId} scheduled retry #$nextRetry in ${delay.inSeconds}s');
      _eventController.add(
        SyncQueueItemFailed(item.syncId, err.toString(), isRetryable: true),
      );

      // Cancel existing retry if any
      _pendingRetries[item.syncId]?.cancel();

      // Schedule new retry
      _pendingRetries[item.syncId] = Timer(delay, () async {
        _pendingRetries.remove(item.syncId);
        await _processItem(item);
      });
      return false;
    }
  }

  void _logDebug(String message) {
    logDebug('[SyncQueue]', message);
  }
}

class SyncQueueBackoffPolicy {
  final int maxRetries;
  final Duration baseDelay;

  const SyncQueueBackoffPolicy({
    this.maxRetries = 5,
    this.baseDelay = const Duration(seconds: 3),
  });

  Duration delayFor(int retryCount) {
    final multiplier = 1 << (retryCount.clamp(1, 6) - 1);
    return Duration(milliseconds: baseDelay.inMilliseconds * multiplier);
  }
}
