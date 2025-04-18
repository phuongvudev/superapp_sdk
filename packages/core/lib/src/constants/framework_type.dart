/// Enum representing the different framework types supported by the system.
///
/// This is used to categorize mini apps based on their underlying framework.
enum FrameworkType {
  /// Represents a Flutter web-based mini app.
  flutterWeb,

  /// Represents a React Native mini app.
  reactNative,

  /// Represents a native mini app.
  native,

  /// Represents a generic web-based mini app.
  web,

  /// Represents an unknown or unsupported framework type.
  unknown,
}

/// Extension on the `FrameworkType` enum to provide additional functionality.
///
/// This includes methods for converting between string representations
/// and the `FrameworkType` values.
extension FrameworkTypeX on FrameworkType {
  /// Returns the string representation of the framework type.
  ///
  /// This is useful for serialization or display purposes.
  String get name {
    switch (this) {
      case FrameworkType.flutterWeb:
        return 'flutter_web';
      case FrameworkType.reactNative:
        return 'react_native';
      case FrameworkType.native:
        return 'native';
      case FrameworkType.web:
        return 'web';
      default:
        return 'unknown';
    }
  }

  /// Converts a string representation to a `FrameworkType` value.
  ///
  /// [value] - The string representation of the framework type.
  /// Returns the corresponding `FrameworkType` value, or `FrameworkType.unknown`
  /// if the string does not match any known framework type.
  static FrameworkType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'flutter_web':
        return FrameworkType.flutterWeb;
      case 'react_native':
        return FrameworkType.reactNative;
      case 'native':
        return FrameworkType.native;
      case 'web':
        return FrameworkType.web;
      default:
        return FrameworkType.unknown;
    }
  }
}