import 'package:core/src/brigdes/mini_app/mini_app_platform_interface.dart';
import 'package:core/src/models/mini_app_manifest.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Implementation of `MiniAppPlatform` using method channels.
///
/// This class provides a bridge to communicate with the native platform
/// for launching mini apps. It uses a method channel to send and receive
/// messages between Dart and the native platform.
class MiniAppMethodChannel extends MiniAppPlatform {
  /// The method channel used for communication with the native platform.
  ///
  /// This channel is used to invoke methods on the native side and receive
  /// responses. The channel name is `miniapp_bridge`.
  @visibleForTesting
  final methodChannel = const MethodChannel('miniapp_bridge');

  /// Launches a native mini app based on the provided manifest.
  ///
  /// [manifest] - The manifest containing metadata about the mini app.
  /// Throws an `UnimplementedError` as this method is not yet implemented.
  @override
  Future<void> launchNativeMiniApp(MiniAppManifest manifest) {
    // TODO: Implement the logic to launch a native mini app.
    throw UnimplementedError();
  }

  /// Launches a web-based mini app based on the provided manifest.
  ///
  /// [manifest] - The manifest containing metadata about the mini app.
  /// Throws an `UnimplementedError` as this method is not yet implemented.
  @override
  Future<void> launchWebMiniApp(MiniAppManifest manifest) {
    // TODO: Implement the logic to launch a web-based mini app.
    throw UnimplementedError();
  }
}