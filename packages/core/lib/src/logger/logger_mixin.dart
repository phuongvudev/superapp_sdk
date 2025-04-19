import 'package:core/src/logger/logger.dart';

mixin LoggerMixin {

  /// A logger instance for the default logger.
  Logger get defaultLogger {
    return LogManager().getLogger();
  }

  /// A logger instance for the class that uses this mixin.
  Logger get logger {
    return LogManager().getLogger(runtimeType.toString());
  }
}
