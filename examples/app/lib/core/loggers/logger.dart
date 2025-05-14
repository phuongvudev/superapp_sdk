import 'package:skit_sdk/kit.dart';

class AppLogger {
  static final AppLogger _instance = AppLogger._internal();

  factory AppLogger() {
    return _instance;
  }

  AppLogger._internal();

  void initLogger() {
    // Initialize the logger here if needed
    LogManager().addLogSinks([ConsoleLogSink(LogManager.defaultLoggerName)]);
  }

  static Logger get globalLogger => LogManager().getLogger('GlobalLogger');

  static Logger get defaultLogger => LogManager().getLogger('DefaultLogger');

  static Logger logger(String name) =>
      LogManager().getLogger(name, [ConsoleLogSink(name)]);
}
