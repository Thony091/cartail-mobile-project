import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/theme/modern_app_theme.dart';
import '../../core/connectivity/connectivity_providers.dart';
import '../../core/connectivity/connectivity_status.dart';
import '../../core/logging/logger_providers.dart';

/// Dashboard para monitorear conectividad
/// Muestra estado actual y logs
class ConnectivityMonitoringDashboard extends ConsumerStatefulWidget {
  const ConnectivityMonitoringDashboard({super.key});

  @override
  ConsumerState<ConnectivityMonitoringDashboard> createState() =>
      _ConnectivityMonitoringDashboardState();
}

class _ConnectivityMonitoringDashboardState
    extends ConsumerState<ConnectivityMonitoringDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connectivity Monitor'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Status'),
            Tab(text: 'Logs'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStatusTab(),
          _buildLogsTab(),
        ],
      ),
    );
  }

  Widget _buildStatusTab() {
    return ref.watch(connectivitySnapshotProvider).when(
      data: (snapshot) => SingleChildScrollView(
        padding: const EdgeInsets.all(ModernAppTheme.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Connectivity Status Card
            _buildStatusCard(snapshot),
            const SizedBox(height: ModernAppTheme.paddingLarge),

            // Metrics Card
            _buildMetricsCard(snapshot),
            const SizedBox(height: ModernAppTheme.paddingLarge),

            // Details Card
            _buildDetailsCard(snapshot),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildStatusCard(ConnectivitySnapshot snapshot) {
    final (color, icon, title) = switch (snapshot.state) {
      ConnectivityState.onlineStable => (
          ModernAppTheme.successGreen,
          Icons.cloud_done_rounded,
          'Online Stable'
        ),
      ConnectivityState.lowConnection => (
          ModernAppTheme.warningOrange,
          Icons.cloud_queue_rounded,
          'Low Connection'
        ),
      ConnectivityState.offline => (
          ModernAppTheme.dangerRed,
          Icons.cloud_off_rounded,
          'Offline'
        ),
    };

    return Container(
      padding: const EdgeInsets.all(ModernAppTheme.paddingMedium),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.1), color.withValues(alpha: 0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: ModernAppTheme.cardRadius,
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 40),
          const SizedBox(width: ModernAppTheme.paddingMedium),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: ModernAppTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                'Last checked: ${snapshot.checkedAt.toLocal().toString().substring(11, 19)}',
                style: TextStyle(
                  fontSize: 12,
                  color: ModernAppTheme.mediumGray,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsCard(ConnectivitySnapshot snapshot) {
    return Container(
      padding: const EdgeInsets.all(ModernAppTheme.paddingMedium),
      decoration: BoxDecoration(
        color: ModernAppTheme.backgroundLight,
        borderRadius: ModernAppTheme.cardRadius,
        border: Border.all(color: ModernAppTheme.borderLight, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Metrics', style: ModernAppTheme.titleSmall),
          const SizedBox(height: ModernAppTheme.paddingMedium),
          _buildMetricRow(
            'Latency',
            snapshot.latencyMs != null ? '${snapshot.latencyMs}ms' : 'N/A',
            color: _getLatencyColor(snapshot.latencyMs),
          ),
          _buildMetricRow(
            'Failure Rate',
            '${(snapshot.failureRate * 100).toStringAsFixed(1)}%',
            color: _getFailureRateColor(snapshot.failureRate),
          ),
          _buildMetricRow(
            'Consecutive Failures',
            snapshot.consecutiveFailures.toString(),
            color: snapshot.consecutiveFailures > 2
                ? ModernAppTheme.dangerRed
                : ModernAppTheme.successGreen,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(ConnectivitySnapshot snapshot) {
    return Container(
      padding: const EdgeInsets.all(ModernAppTheme.paddingMedium),
      decoration: BoxDecoration(
        color: ModernAppTheme.backgroundLight,
        borderRadius: ModernAppTheme.cardRadius,
        border: Border.all(color: ModernAppTheme.borderLight, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Details', style: ModernAppTheme.titleSmall),
          const SizedBox(height: ModernAppTheme.paddingMedium),
          _buildDetailRow('State', snapshot.state.toString()),
          _buildDetailRow('Checked At', snapshot.checkedAt.toLocal().toString()),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, {required Color color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: color,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, color: ModernAppTheme.mediumGray),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color _getLatencyColor(int? latency) {
    if (latency == null) return ModernAppTheme.mediumGray;
    if (latency < 200) return ModernAppTheme.successGreen;
    if (latency < 600) return ModernAppTheme.warningOrange;
    return ModernAppTheme.dangerRed;
  }

  Color _getFailureRateColor(double rate) {
    if (rate < 0.2) return ModernAppTheme.successGreen;
    if (rate < 0.5) return ModernAppTheme.warningOrange;
    return ModernAppTheme.dangerRed;
  }

  Widget _buildLogsTab() {
    return ref.watch(logHistoryProvider).when(
      data: (logs) => Padding(
        padding: const EdgeInsets.all(ModernAppTheme.paddingSmall),
        child: logs.isEmpty
            ? const Center(child: Text('No logs yet'))
            : ListView.builder(
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  final log = logs[logs.length - 1 - index]; // Newest first
                  return _buildLogEntry(log);
                },
              ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildLogEntry(dynamic log) {
    // log is a LogEntry from logger_service.dart
    final levelColor = _getLevelColor(log.level.label);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ModernAppTheme.paddingSmall,
        vertical: ModernAppTheme.paddingSmall,
      ),
      margin: const EdgeInsets.only(bottom: ModernAppTheme.paddingSmall),
      decoration: BoxDecoration(
        color: levelColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(color: levelColor, width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                log.level.label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: levelColor,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: ModernAppTheme.paddingSmall),
              Expanded(
                child: Text(
                  log.tag,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                _formatTime(log.timestamp),
                style: const TextStyle(
                  fontSize: 11,
                  color: ModernAppTheme.mediumGray,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            log.message,
            style: const TextStyle(fontSize: 12),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Color _getLevelColor(String level) {
    if (level.contains('ERROR')) return ModernAppTheme.dangerRed;
    if (level.contains('WARNING')) return ModernAppTheme.warningOrange;
    if (level.contains('INFO')) return ModernAppTheme.primaryBlue;
    return ModernAppTheme.mediumGray;
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
