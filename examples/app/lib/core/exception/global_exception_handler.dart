import 'package:app/core/errors/global_error_handler.dart';
import 'package:flutter/material.dart';
import 'package:app/core/errors/app_error.dart';

class GlobalExceptionHandler {
  // Singleton instance
  static final GlobalExceptionHandler _instance =
      GlobalExceptionHandler._internal();

  factory GlobalExceptionHandler() => _instance;

  GlobalExceptionHandler._internal();

  // Keep reference to navigator key to show dialogs without context
  late final GlobalKey<NavigatorState> navigatorKey;

  // Optional: Keep reference to scaffold messenger key for snack bars
  late final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;

  void initialize({
    required GlobalKey<NavigatorState> navigatorKey,
    required GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey,
  }) {
    this.navigatorKey = navigatorKey;
    this.scaffoldMessengerKey = scaffoldMessengerKey;
  }

  /// Handles an exception and shows appropriate UI feedback
  void handleException(Object? exception, [StackTrace? stackTrace]) {
    // First, ensure it gets logged by the error handler
    GlobalErrorHandler().handleError(
      exception,
      stackTrace ?? StackTrace.empty,
      'ExceptionHandler',
    );

    // Then handle UI feedback based on the error type
    _showUserFeedback(exception);
  }

  void _showUserFeedback(Object? exception) {
    final context = navigatorKey.currentContext;

    if (context == null) return;

    // Determine error type and show appropriate UI
    if (exception is AppError) {
      switch (exception.severity) {
        case ErrorSeverity.critical:
          _showErrorDialog(context, exception.message, isRecoverable: false);
          break;
        case ErrorSeverity.error:
          _showErrorDialog(context, exception.message, isRecoverable: true);
          break;
        case ErrorSeverity.warning:
          _showSnackBar(exception.message);
          break;
      }
    } else {
      // Generic error handling
      _showSnackBar("An unexpected error occurred");
    }
  }

  void _showErrorDialog(
    BuildContext context,
    String message, {
    bool isRecoverable = true,
  }) {
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
                // Close dialog
                Navigator.of(context).pop();
                // Add recovery logic here if needed
                if (!isRecoverable) {
                  // For critical errors, you might want to restart the app
                  // or navigate to a safe screen
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/', (route) => false);
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
    if (messenger != null) {
      messenger.showSnackBar(SnackBar(content: Text(message)));
    }
  }
}
