import 'package:skit_sdk/kit.dart';

class AppLogger {
  static final AppLogger _instance = AppLogger._internal();

  factory AppLogger() {
    return _instance;
  }

  AppLogger._internal();

  /// Initializes the logger with the default configuration.
  void initLogger() {
    // Initialize the logger here if needed
    LogManager().addLogSinks([
      ConsoleLogSink(LogManager.defaultLoggerName, enableDebugMode: true),
    ]);
  }

  /// Adds a log sink to the global logger.
  static Logger get globalLogger => LogManager().getLogger('GlobalLogger');

  /// Adds a log sink to the default logger.
  static Logger get defaultLogger => LogManager().getLogger('DefaultLogger');

  /// Adds a log sink to the logger with the specified name.
  static Logger logger(String name) =>
      LogManager().getLogger(name, [ConsoleLogSink(name)]);
}
