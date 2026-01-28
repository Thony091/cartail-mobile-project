/// Log levels for controlling verbosity
enum LogLevel {
  debug(0, '🔍 DEBUG'),
  info(1, 'ℹ️ INFO'),
  warning(2, '⚠️ WARNING'),
  error(3, '❌ ERROR');

  final int level;
  final String label;
  const LogLevel(this.level, this.label);
}

/// Represents a single log entry
class LogEntry {
  final LogLevel level;
  final String tag;
  final String message;
  final DateTime timestamp;
  final dynamic error;
  final StackTrace? stackTrace;

  LogEntry({
    required this.level,
    required this.tag,
    required this.message,
    required this.timestamp,
    this.error,
    this.stackTrace,
  });

  @override
  String toString() {
    final time = timestamp.toIso8601String().split('T').last.substring(0, 12);
    final errorStr = error != null ? ' | Error: $error' : '';
    return '$time [${level.label}] [$tag] $message$errorStr';
  }
}

/// Core logging service
abstract class LoggerService {
  void debug(String tag, String message);
  void info(String tag, String message);
  void warning(String tag, String message, {dynamic error, StackTrace? stackTrace});
  void error(String tag, String message, {dynamic error, StackTrace? stackTrace});

  /// Get all log entries (useful for debugging/sending to server)
  List<LogEntry> getLogHistory({LogLevel? minLevel});

  /// Clear log history
  void clearHistory();

  /// Set minimum log level to display
  void setMinLevel(LogLevel level);
}

/// Default implementation with in-memory log history
class LoggerServiceImpl implements LoggerService {
  final List<LogEntry> _history = [];
  LogLevel _minLevel = LogLevel.debug;

  /// Max logs to keep in memory (prevents unbounded growth)
  static const int _maxHistorySize = 1000;

  @override
  void debug(String tag, String message) {
    _log(LogLevel.debug, tag, message);
  }

  @override
  void info(String tag, String message) {
    _log(LogLevel.info, tag, message);
  }

  @override
  void warning(String tag, String message, {dynamic error, StackTrace? stackTrace}) {
    _log(LogLevel.warning, tag, message, error: error, stackTrace: stackTrace);
  }

  @override
  void error(String tag, String message, {dynamic error, StackTrace? stackTrace}) {
    _log(LogLevel.error, tag, message, error: error, stackTrace: stackTrace);
  }

  @override
  List<LogEntry> getLogHistory({LogLevel? minLevel}) {
    final level = minLevel ?? _minLevel;
    return _history.where((entry) => entry.level.level >= level.level).toList();
  }

  @override
  void clearHistory() {
    _history.clear();
  }

  @override
  void setMinLevel(LogLevel level) {
    _minLevel = level;
  }

  void _log(
    LogLevel level,
    String tag,
    String message, {
    dynamic error,
    StackTrace? stackTrace,
  }) {
    if (level.level < _minLevel.level) return;

    final entry = LogEntry(
      level: level,
      tag: tag,
      message: message,
      timestamp: DateTime.now(),
      error: error,
      stackTrace: stackTrace,
    );

    // Add to history
    _history.add(entry);

    // Keep history bounded
    if (_history.length > _maxHistorySize) {
      _history.removeAt(0);
    }

    // Print in debug mode
    assert(() {
      // ignore: avoid_print
      print(entry.toString());
      if (stackTrace != null) {
        // ignore: avoid_print
        print('Stack trace:\n$stackTrace');
      }
      return true;
    }());
  }
}

/// Global logger instance
late final LoggerService globalLogger;

/// Initialize the global logger (call once at app startup)
void initializeLogger() {
  globalLogger = LoggerServiceImpl();
}

/// Convenience functions for quick logging
void logDebug(String tag, String message) => globalLogger.debug(tag, message);
void logInfo(String tag, String message) => globalLogger.info(tag, message);
void logWarning(String tag, String message, {dynamic error, StackTrace? stackTrace}) =>
    globalLogger.warning(tag, message, error: error, stackTrace: stackTrace);
void logError(String tag, String message, {dynamic error, StackTrace? stackTrace}) =>
    globalLogger.error(tag, message, error: error, stackTrace: stackTrace);
