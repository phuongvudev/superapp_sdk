import 'package:skit_sdk/kit.dart';

void initLogger() {
  // Initialize the logger here if needed
  LogManager().addLogSinks([ConsoleLogSink(LogManager.defaultLoggerName)]);

}


Logger get globalLogger => LogManager().getLogger('GlobalLogger');