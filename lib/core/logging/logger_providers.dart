import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'logger_service.dart';

/// Provider for the logger service
final loggerProvider = Provider<LoggerService>((ref) {
  return LoggerServiceImpl();
});

/// Provider to get log history
final logHistoryProvider = FutureProvider<List<LogEntry>>((ref) async {
  final logger = ref.watch(loggerProvider);
  return logger.getLogHistory();
});

/// Provider for minimum log level
final logLevelProvider = StateProvider<LogLevel>((ref) {
  return LogLevel.info;
});
