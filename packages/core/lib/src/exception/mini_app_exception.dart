import 'package:core/src/constants/framework_type.dart';

class MiniAppNotFoundException implements Exception {
  final String appId;

  MiniAppNotFoundException(this.appId);

  @override
  String toString() =>
      "MiniAppNotFoundException: Mini app with id '$appId' not found.";
}

class UnsupportedFrameworkException implements Exception {
  final FrameworkType framework;

  UnsupportedFrameworkException(this.framework);

  @override
  String toString() =>
      "UnsupportedFrameworkException: Unsupported mini app framework '$framework'.";
}
