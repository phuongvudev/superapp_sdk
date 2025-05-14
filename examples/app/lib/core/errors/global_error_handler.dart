import 'dart:isolate';

import 'package:app/core/errors/app_error.dart';
import 'package:app/core/loggers/logger.dart';
import 'package:app/presentation/screens/error_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class GlobalErrorHandler {
  // Singleton instance
  static final GlobalErrorHandler _instance = GlobalErrorHandler._internal();

  factory GlobalErrorHandler() => _instance;

  GlobalErrorHandler._internal();

  // Initialize all error handlers
  void initialize() {
    // Handle Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      // FlutterError.presentError(details);
      handleError(
        details.exception,
        details.stack ?? StackTrace.current,
        'Flutter',
      );
    };

    // Handle errors in the current platform
    PlatformDispatcher.instance.onError = (error, stack) {
      handleError(error, stack, 'Platform');
      return true;
    };

    // Handle errors in the current isolate
    Isolate.current.addErrorListener(
      RawReceivePort((pair) {
        final List<dynamic> errorAndStacktrace = pair;
        handleError(
          errorAndStacktrace.first,
          errorAndStacktrace.last,
          'Isolate',
        );
      }).sendPort,
    );

    // Custom error widget
    ErrorWidget.builder = (FlutterErrorDetails details) {
      return ErrorScreen(details: details);
    };
  }

  void handleError(Object? error, StackTrace stackTrace, String source) {
    if (error is AppError) {
      final logger =
          (error.source == null || error.source!.isEmpty)
              ? AppLogger.globalLogger
              : AppLogger.logger(error.source!);

      switch (error.severity) {
        case ErrorSeverity.critical:
          // Handle critical errors
          logger.fatal(
            '${error.message} (${error.code})',
            error.error,
            error.stackTrace ?? stackTrace,
          );
          break;
        case ErrorSeverity.warning:
          // Handle warning errors
          logger.warning(
            '${error.message} (${error.code})',
            error.error,
            error.stackTrace ?? stackTrace,
          );
          break;
        default:
          // Handle regular errors
          logger.error(
            '${error.message} (${error.code})',
            error.error,
            error.stackTrace ?? stackTrace,
          );
          break;
      }
    } else {
      AppLogger.globalLogger.error(
        '[$source] ${error.toString()}',
        error,
        stackTrace,
      );
    }
  }
}
