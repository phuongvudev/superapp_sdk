import 'dart:ui';

import 'package:app/core/errors/app_error.dart';

final class AppException extends AppError {
  final VoidCallback? onRollback;
  final VoidCallback? onRetry;

  AppException({
    required super.message,
    super.code,
    super.stackTrace,
    super.source,
    super.error,
    super.severity,
    this.onRollback,
    this.onRetry,
  });
}
