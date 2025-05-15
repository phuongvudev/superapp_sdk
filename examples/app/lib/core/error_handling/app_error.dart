enum ErrorSeverity { warning, error, critical }

typedef OnExceptionCallback = void Function();

abstract class BaseError {
  final String message;
  final StackTrace? stackTrace;

  const BaseError({required this.message, this.stackTrace});

  @override
  String toString() => "$runtimeType: $message";
}

class AppError extends BaseError {
  final String code;
  final ErrorSeverity severity;
  final String? source;
  final Object? error;

  const AppError({
    required super.message,
    this.code = 'unknown',
    this.severity = ErrorSeverity.error,
    this.source,
    this.error,
    super.stackTrace,
  });
}

class AppException extends BaseError {
  final String code;
  final ErrorSeverity severity;
  final String? source;
  final Object? error;
  final OnExceptionCallback? onRollback;
  final OnExceptionCallback? onRetry;

  AppException({
    required super.message,
    super.stackTrace,
    this.code = 'unknown',
    this.severity = ErrorSeverity.error,
    this.source,
    this.error,
    this.onRollback,
    this.onRetry,
  });
}
