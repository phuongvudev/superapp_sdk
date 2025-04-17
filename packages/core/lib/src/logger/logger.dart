import 'package:core/src/logger/log_level.dart';
import 'package:core/src/logger/log_sink.dart';

class LogManager {
  static const String defaultLoggerName = "DEFAULT";

  static final LogManager _instance = LogManager._internal();

  factory LogManager() => _instance;

  LogManager._internal();

  final Map<String, Logger> _loggers = {};

  final List<LogSink> _globalLogSinks = [];

  void addLogSinks(List<LogSink> targets) {
    _globalLogSinks.addAll(targets);
  }

  void removeLogSink(LogSink target) {
    _globalLogSinks.remove(target);
  }

  Logger getLogger([String name = defaultLoggerName]) {
    return _loggers.putIfAbsent(name, () => Logger(name, _globalLogSinks));
  }
}

class Logger {
  final String name;
  final List<LogSink> _logSinks;

  Logger(this.name, this._logSinks);

  void info(String message) {
    _writeLog(LogLevel.info, message);
  }

  void error(String message,
      [dynamic error, StackTrace stackTrace = StackTrace.empty]) {
    _writeLog(  LogLevel.error, message, error, stackTrace);
  }

  void warning(String message) {
    _writeLog(LogLevel.warning, message);
  }

  void debug(String message) {
    _writeLog(LogLevel.debug, message);
  }

  void verbose(String message) {
    _writeLog(LogLevel.verbose, message);
  }

  void fatal(String message,
      [dynamic error, StackTrace stackTrace = StackTrace.empty]) {
    _writeLog(LogLevel.fatal, message, error, stackTrace);
  }

  void wtf(String message,
      [dynamic error, StackTrace stackTrace = StackTrace.empty]) {
    _writeLog(LogLevel.wtf, message, error, stackTrace);
  }

  void _writeLog(LogLevel level, String message,
      [dynamic error, StackTrace stackTrace = StackTrace.empty]) {
    if (level.index >= LogLevel.info.index) {
      for (var sink in _logSinks) {
        sink.log(level, message, error: error, stackTrace: stackTrace);
      }
    }


  }
}
