import 'package:core/src/brigdes/mini_app/mini_app_platform_interface.dart';
import 'package:core/src/models/mini_app_manifest.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';


class MethodChannelMiniApp extends MiniAppPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('miniapp_bridge');

  @override
  Future<void> launchNativeMiniApp(MiniAppManifest manifest) {
    // TODO: implement launchNativeMiniApp
    throw UnimplementedError();
  }

  @override
  Future<void> launchWebMiniApp(MiniAppManifest manifest) {
    // TODO: implement launchWebMiniApp
    throw UnimplementedError();
  }
}
