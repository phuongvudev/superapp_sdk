
part of 'logger.dart';
/// Enum representing different log levels for logging purposes.
enum LogLevel {
  /// Verbose log level, used for detailed debugging information.
  verbose,

  /// Debug log level, used for general debugging information.
  debug,

  /// Info log level, used for informational messages.
  info,

  /// Warning log level, used for non-critical issues or warnings.
  warning,

  /// Error log level, used for critical errors or exceptions.
  error,

  /// Fatal log level, used for severe errors that may cause application failure.
  fatal,

  /// WTF log level, used for unexpected or critical issues.
  wtf,
}

/// Extension on the `LogLevel` enum to provide additional functionality.
extension LogLevelExtension on LogLevel {
  /// Returns a display-friendly name for each log level.
  ///
  /// This is useful for formatting log messages with human-readable log levels.
  String get displayName {
    switch (this) {
      case LogLevel.verbose:
        return "VERBOSE";
      case LogLevel.debug:
        return "DEBUG";
      case LogLevel.info:
        return "INFO";
      case LogLevel.warning:
        return "WARNING";
      case LogLevel.error:
        return "ERROR";
      case LogLevel.fatal:
        return "FATAL";
      case LogLevel.wtf:
        return "WTF";
    }
  }
}
