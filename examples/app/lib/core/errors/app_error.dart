class AppError {
  final String code;
  final String message;
  final StackTrace? stackTrace;
  final ErrorSeverity severity;
  final String? source;
  final Object? error;

  const AppError({
    required this.message,
    this.code = 'unknown',
    this.severity = ErrorSeverity.error,
    this.source,
    this.error,
    this.stackTrace,
  });
}

enum ErrorSeverity { warning, error, critical }
