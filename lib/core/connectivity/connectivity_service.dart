import 'dart:async';
import 'dart:collection';

import 'package:dio/dio.dart';

import '../logging/logger_service.dart';
import 'connectivity_status.dart';

/// Mental map (offline-first):
///
///      [Timer] -> probe.check() -> metrics -> state -> stream
///            \-> high intermittency? -> FORCE OFFLINE
///
/// This service does not depend on UI or repositories; it only emits state.
class ConnectivityService {
  ConnectivityService({
    required ConnectivityProbe probe,
    ConnectivityServiceConfig? config,
  })  : _probe = probe,
        _config = config ?? const ConnectivityServiceConfig();

  final ConnectivityProbe _probe;
  final ConnectivityServiceConfig _config;

  final StreamController<ConnectivitySnapshot> _controller =
      StreamController<ConnectivitySnapshot>.broadcast();

  Timer? _timer;
  bool _started = false;

  int _consecutiveFailures = 0;
  final Queue<bool> _recentResults = Queue<bool>();
  ConnectivityState? _previousState;

  Stream<ConnectivitySnapshot> get stream => _controller.stream;

  Future<void> start() async {
    if (_started) return;
    _started = true;
    await _tick();
    _timer = Timer.periodic(_config.probeInterval, (_) => _tick());
  }

  Future<void> stop() async {
    _timer?.cancel();
    _timer = null;
    _started = false;
  }

  Future<void> _tick() async {
    final now = DateTime.now();
    final result = await _probe.check();

    // Log probe result
    if (_config.enableLogging) {
      if (result.isOnline) {
        logDebug('[Connectivity]', 'Probe OK - latency: ${result.latencyMs}ms');
      } else {
        logDebug('[Connectivity]', 'Probe FAILED - ${result.error}');
      }
    }

    _recentResults.add(result.isOnline);
    if (_recentResults.length > _config.windowSize) {
      _recentResults.removeFirst();
    }

    if (result.isOnline) {
      _consecutiveFailures = 0;
    } else {
      _consecutiveFailures += 1;
    }

    final failureRate = _recentResults.isEmpty
        ? 1.0
        : _recentResults.where((ok) => !ok).length / _recentResults.length;

    final shouldForceOffline =
        failureRate >= _config.intermitentFailureRateThreshold ||
            _consecutiveFailures >= _config.maxConsecutiveFailures;

    final ConnectivityState state;
    if (shouldForceOffline) {
      state = ConnectivityState.offline;
    } else if (!result.isOnline) {
      state = ConnectivityState.offline;
    } else if (result.latencyMs != null &&
        result.latencyMs! >= _config.highLatencyThresholdMs) {
      state = ConnectivityState.lowConnection;
    } else {
      state = ConnectivityState.onlineStable;
    }

    // Log metrics and state changes
    if (_config.enableLogging) {
      logDebug(
        '[Connectivity]',
        'Metrics - failure rate: ${(failureRate * 100).toStringAsFixed(1)}%, consecutive failures: $_consecutiveFailures',
      );
      if (_previousState != null && _previousState != state) {
        logDebug('[Connectivity]', 'State changed: $_previousState → $state');
      }
    }

    _previousState = state;

    _controller.add(
      ConnectivitySnapshot(
        state: state,
        latencyMs: result.latencyMs,
        consecutiveFailures: _consecutiveFailures,
        failureRate: failureRate,
        checkedAt: now,
      ),
    );
  }
}

class ConnectivityServiceConfig {
  final Duration probeInterval;
  final int windowSize;
  final int maxConsecutiveFailures;
  final double intermitentFailureRateThreshold;
  final int highLatencyThresholdMs;
  final bool enableLogging;

  const ConnectivityServiceConfig({
    this.probeInterval = const Duration(seconds: 8),
    this.windowSize = 8,
    this.maxConsecutiveFailures = 3,
    this.intermitentFailureRateThreshold = 0.45,
    this.highLatencyThresholdMs = 2000,
    this.enableLogging = false,
  });
}

class ConnectivityProbeResult {
  final bool isOnline;
  final int? latencyMs;
  final String? error;

  const ConnectivityProbeResult({
    required this.isOnline,
    required this.latencyMs,
    this.error,
  });
}

abstract class ConnectivityProbe {
  Future<ConnectivityProbeResult> check();
}

/// Simple HTTP probe using Dio to validate reachability.
///
/// Only 2xx/3xx status codes are treated as online.
/// 4xx (client errors like auth failures) and 5xx are treated as offline.
class HttpConnectivityProbe implements ConnectivityProbe {
  HttpConnectivityProbe({
    required Dio dio,
    required String path,
  })  : _dio = dio,
        _path = path;

  final Dio _dio;
  final String _path;

  @override
  Future<ConnectivityProbeResult> check() async {
    final start = DateTime.now();
    try {
      final response = await _dio.get(
        _path,
        options: Options(
          receiveTimeout: const Duration(seconds: 6),
          sendTimeout: const Duration(seconds: 6),
          // Accept any status code to avoid Dio throwing exceptions
          validateStatus: (status) => true,
        ),
      );
      final latency = DateTime.now().difference(start).inMilliseconds;

      // Only 2xx and 3xx status codes indicate a healthy connection
      // 4xx (auth failures, 404, etc) and 5xx are treated as offline
      final isOnline = response.statusCode != null && response.statusCode! < 400;

      return ConnectivityProbeResult(
        isOnline: isOnline,
        latencyMs: latency,
        error: isOnline ? null : 'HTTP ${response.statusCode}',
      );
    } catch (err) {
      return ConnectivityProbeResult(
        isOnline: false,
        latencyMs: null,
        error: err.toString(),
      );
    }
  }
}
