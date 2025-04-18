import 'package:core/src/brigdes/mini_app/mini_app_method_channel.dart';
import 'package:core/src/models/mini_app_manifest.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// Abstract base class for the Mini App platform interface.
///
/// This class defines the contract for platform-specific implementations
/// to handle launching mini apps. It uses the `PluginPlatformInterface`
/// to ensure proper platform implementation.
abstract class MiniAppPlatform extends PlatformInterface {
  /// Constructs a `MiniAppPlatform` instance.
  ///
  /// This constructor ensures that the platform implementation is verified
  /// using a unique token.
  MiniAppPlatform() : super(token: _token);

  /// A unique token used to verify platform implementations.
  static final Object _token = Object();

  /// The default instance of `MiniAppPlatform`.
  ///
  /// This is initialized to the `MethodChannelMiniApp` implementation.
  static MiniAppPlatform _instance = MiniAppMethodChannel();

  /// Gets the current instance of `MiniAppPlatform`.
  ///
  /// This allows access to the platform-specific implementation.
  static MiniAppPlatform get instance => _instance;

  /// Sets the current instance of `MiniAppPlatform`.
  ///
  /// [instance] - The new platform-specific implementation to use.
  /// Verifies the provided instance using the unique token.
  static set instance(MiniAppPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Launches a native mini app based on the provided manifest.
  ///
  /// [manifest] - The manifest containing metadata about the mini app.
  /// This method must be implemented by platform-specific subclasses.
  Future<void> launchNativeMiniApp(MiniAppManifest manifest);

  /// Launches a web-based mini app based on the provided manifest.
  ///
  /// [manifest] - The manifest containing metadata about the mini app.
  /// This method must be implemented by platform-specific subclasses.
  Future<void> launchWebMiniApp(MiniAppManifest manifest);
}