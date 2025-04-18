import 'package:core/src/brigdes/mini_app/mini_app_platform_interface.dart';
import 'package:core/src/constants/method_channel.dart';
import 'package:core/src/models/mini_app_manifest.dart';
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
  /// responses.
  final methodChannel =
      const MethodChannel(MethodChannelConstants.methodChannelMiniApp);

  /// Launches a native mini app based on the provided manifest.
  ///
  /// [manifest] - The manifest containing metadata about the mini app.
  @override
  Future<void> launchNativeMiniApp(MiniAppManifest manifest) async {
    try {
      await methodChannel.invokeMethod('openMiniApp', manifest.toJson());
    } on PlatformException catch (e) {
      throw Exception('Failed to launch native mini app: ${e.message}');
    }
  }

  /// Launches a web-based mini app based on the provided manifest.
  ///
  /// [manifest] - The manifest containing metadata about the mini app.
  @override
  Future<void> launchWebMiniApp(MiniAppManifest manifest) async {
    try {
      await methodChannel.invokeMethod('openMiniApp', manifest.toJson());
    } on PlatformException catch (e) {
      throw Exception('Failed to launch web mini app: ${e.message}');
    }
  }
}
