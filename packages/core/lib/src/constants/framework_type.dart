enum FrameworkType {
  flutterWeb,
  reactNative,
  native,
  web,
  unknown,
}

extension FrameworkTypeX on FrameworkType {
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
