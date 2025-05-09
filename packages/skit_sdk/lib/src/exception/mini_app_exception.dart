import 'package:skit_sdk/src/constants/framework_type.dart';

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

/// Exception thrown when a class is not found.
class ClassNotFoundException implements Exception {
  /// The class name that was not found.
  final String className;
  final String? message;

  /// Creates a new instance of `ClassNotFoundException`.
  ///
  /// [className] - The name of the class that could not be found.
  ClassNotFoundException(this.className, [this.message]);

  /// Returns a string representation of the exception.
  ///
  /// This includes the class name that caused the exception.
  @override
  String toString() => "ClassNotFoundException: Class '$className' not found."
      "${message != null ? " $message" : ""}";
}

/// Exception thrown when a mini app fails to launch.
/// This exception is used to indicate that the mini app could not be
/// successfully launched, possibly due to an error in the launch process.
class LaunchFailedException implements Exception {
  final String appId;

  /// The error message associated with the launch failure.
  final String? message;

  /// Creates a new instance of `LaunchFailedException`.
  ///
  /// [message] - The error message associated with the launch failure.
  LaunchFailedException(this.appId, [this.message]);

  /// Returns a string representation of the exception.
  ///
  /// This includes the error message that caused the exception.
  @override
  String toString() =>
      "LaunchFailedException: Launch failed. ${message != null ? " $message" : ""}";
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