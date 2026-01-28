enum ConnectivityState {
  onlineStable,
  lowConnection,
  offline,
}

class ConnectivitySnapshot {
  final ConnectivityState state;
  final int? latencyMs;
  final int consecutiveFailures;
  final double failureRate;
  final DateTime checkedAt;

  const ConnectivitySnapshot({
    required this.state,
    required this.latencyMs,
    required this.consecutiveFailures,
    required this.failureRate,
    required this.checkedAt,
  });

  bool get isOnline => state == ConnectivityState.onlineStable;
  bool get isOffline => state == ConnectivityState.offline;
}
