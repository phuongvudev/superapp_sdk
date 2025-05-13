part of 'logger.dart';

mixin LoggerMixin {
  /// A logger instance for the default logger.
  Logger get defaultLogger {
    return LogManager().getLogger(LogManager.defaultLoggerName, [
      ConsoleLogSink(LogManager.defaultLoggerName),
    ]);
  }

  /// A logger instance for the class that uses this mixin.
  Logger get logger {
    final name = runtimeType.toString();
    return LogManager().getLogger(name, [ConsoleLogSink(name)]);
  }

  Logger loggerWithOutput(String name, {List<LogSink>? sinks}) {
    return LogManager().getLogger(name, sinks);
  }
}
