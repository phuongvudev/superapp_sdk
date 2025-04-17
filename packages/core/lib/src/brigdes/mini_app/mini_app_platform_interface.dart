import 'package:core/src/brigdes/mini_app/mini_app_method_channel.dart';
import 'package:core/src/models/mini_app_manifest.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

abstract class MiniAppPlatform extends PlatformInterface {
  MiniAppPlatform() : super(token: _token);

  static final Object _token = Object();

  static MiniAppPlatform _instance = MethodChannelMiniApp();

  static MiniAppPlatform get instance => _instance;


  static set instance(MiniAppPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> launchNativeMiniApp(MiniAppManifest manifest);

  Future<void> launchWebMiniApp(MiniAppManifest manifest);


}
