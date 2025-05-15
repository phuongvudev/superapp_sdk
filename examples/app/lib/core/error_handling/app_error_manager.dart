import 'dart:isolate';

import 'package:app/core/error_handling/app_error.dart';
import 'package:app/core/loggers/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppErrorManager {
  // Singleton instance
  static final AppErrorManager _instance = AppErrorManager._internal();

  factory AppErrorManager() => _instance;

  AppErrorManager._internal();

  late final GlobalKey<NavigatorState> navigatorKey;
  late final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;

  void initialize({
    required GlobalKey<NavigatorState> navigatorKey,
    required GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey,
  }) {
    this.navigatorKey = navigatorKey;
    this.scaffoldMessengerKey = scaffoldMessengerKey;

    // Flutter framework errors
    FlutterError.onError = (details) {
      handleError(details.exception, details.stack ?? StackTrace.current, 'Flutter');
    };

    // Platform errors
    PlatformDispatcher.instance.onError = (error, stack) {
      handleError(error, stack, 'Platform');
      return true;
    };

    // Isolate errors
    Isolate.current.addErrorListener(
      RawReceivePort((pair) {
        final List<dynamic> errorAndStacktrace = pair;
        handleError(errorAndStacktrace.first, errorAndStacktrace.last, 'Isolate');
      }).sendPort,
    );

    // Custom error widget
    ErrorWidget.builder = (details) {
      return Scaffold(body: Center(child: Text('An error occurred!')));
    };
  }

  void handleError(Object? error, StackTrace stackTrace, String source) {
    _logError(error, stackTrace, source);
    _showUserFeedback(error);
  }

  void _logError(Object? error, StackTrace stackTrace, String source) {
    if (error is AppError) {
      final logger = (error.source == null || error.source!.isEmpty)
          ? AppLogger.globalLogger
          : AppLogger.logger(error.source!);

      switch (error.severity) {
        case ErrorSeverity.critical:
          logger.fatal('${error.message} (${error.code})', error.error, error.stackTrace ?? stackTrace);
          break;
        case ErrorSeverity.warning:
          logger.warning('${error.message} (${error.code})', error.error, error.stackTrace ?? stackTrace);
          break;
        default:
          logger.error('${error.message} (${error.code})', error.error, error.stackTrace ?? stackTrace);
          break;
      }
    } else {
      AppLogger.globalLogger.error('[$source] ${error.toString()}', error, stackTrace);
    }
  }

  void _showUserFeedback(Object? error) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    if (error is AppException) {
      switch (error.severity) {
        case ErrorSeverity.critical:
          _showErrorDialog(context, error.message, isRecoverable: false);
          break;
        case ErrorSeverity.error:
          _showErrorDialog(context, error.message, isRecoverable: true);
          break;
        case ErrorSeverity.warning:
          _showSnackBar(error.message);
          break;
      }
    } else {
      _showSnackBar("An unexpected error occurred");
    }
  }

  void _showErrorDialog(BuildContext context, String message, {bool isRecoverable = true}) {
    showDialog(
      context: context,
      barrierDismissible: isRecoverable,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isRecoverable ? "Error" : "Critical Error"),
          content: Text(message),
          actions: [
            if (isRecoverable)
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Dismiss"),
              ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (!isRecoverable) {
                  Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                }
              },
              child: Text(isRecoverable ? "Retry" : "Restart App"),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(String message) {
    final messenger = scaffoldMessengerKey.currentState;
    messenger?.showSnackBar(SnackBar(content: Text(message)));
  }
}