import 'package:core/src/constants/framework_type.dart';

/// Exception thrown when a mini app with the specified ID is not found.
///
/// This exception is used to indicate that the requested mini app does not
/// exist in the registry or cannot be located.
class MiniAppNotFoundException implements Exception {
  /// The ID of the mini app that was not found.
  final String appId;

  /// Creates a new instance of `MiniAppNotFoundException`.
  ///
  /// [appId] - The ID of the mini app that could not be found.
  MiniAppNotFoundException(this.appId);

  /// Returns a string representation of the exception.
  ///
  /// This includes the mini app ID that caused the exception.
  @override
  String toString() =>
      "MiniAppNotFoundException: Mini app with id '$appId' not found.";
}

/// Exception thrown when an unsupported framework type is encountered.
///
/// This exception is used to indicate that the specified framework type
/// is not supported by the system.
class UnsupportedFrameworkException implements Exception {
  /// The unsupported framework type.
  final FrameworkType framework;

  /// Creates a new instance of `UnsupportedFrameworkException`.
  ///
  /// [framework] - The framework type that is not supported.
  UnsupportedFrameworkException(this.framework);

  /// Returns a string representation of the exception.
  ///
  /// This includes the unsupported framework type that caused the exception.
  @override
  String toString() =>
      "UnsupportedFrameworkException: Unsupported mini app framework '$framework'.";
}