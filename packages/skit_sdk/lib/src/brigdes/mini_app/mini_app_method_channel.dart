import 'package:flutter/widgets.dart';
import 'package:skit_sdk/src/brigdes/mini_app/mini_app_platform_interface.dart';
import 'package:skit_sdk/src/constants/method_channel.dart';
import 'package:skit_sdk/src/exception/mini_app_exception.dart';
import 'package:skit_sdk/src/models/mini_app_manifest.dart';
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
  Future<void> launchMiniApp(MiniAppManifest manifest) async {
    try {
      await methodChannel.invokeMethod('openMiniApp', manifest.toJson());
    } on PlatformException catch (e) {
      // Handle the exception and throw a custom error message
      // to provide more context about the failure.
      switch (e.code) {
        case 'CLASS_NOT_FOUND':
          throw ClassNotFoundException(manifest.entryPath, e.message);
        case 'LAUNCH_FAILED':
          throw LaunchFailedException(manifest.appId, e.message);
        default:
          throw Exception('Failed to launch native mini app: ${e.message}');
      }
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

  /// Launches a Flutter mini app based on the provided manifest.
  ///
  /// /// [registry] - The registry containing widget builders for mini apps.
  /// /// [manifest] - The manifest containing metadata about the mini app.
  @override
  Widget? launchFlutterMiniApp(MiniAppManifest manifest) {
    try {
      final widgetBuilder = manifest.appBuilder!;
      return widgetBuilder(manifest.params ?? {});
    } catch (e) {
      throw LaunchFailedException(manifest.appId, e.toString());
    }
  }
}
