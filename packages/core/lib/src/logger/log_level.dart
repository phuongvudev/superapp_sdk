enum LogLevel {
  verbose,
  debug,
  info,
  warning,
  error,
  fatal,
  wtf,
}

extension LogLevelExtension on LogLevel {
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