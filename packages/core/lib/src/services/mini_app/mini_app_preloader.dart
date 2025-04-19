import 'package:core/src/constants/framework_type.dart';
import 'package:core/src/models/mini_app_manifest.dart';

/// Interface for registering preloader implementations for different frameworks.
///
/// This allows associating a specific `MiniAppPreloader` with a `FrameworkType`.
abstract class MiniAppPreloaderRegistrar {
  /// Registers a preloader for a specific framework type.
  ///
  /// [framework] - The framework type (e.g., Flutter, React Native).
  /// [preloader] - The preloader implementation for the specified framework.
  void registerPreloader(FrameworkType framework, MiniAppPreloader preloader);
}

/// Interface for preloading mini apps.
///
/// A preloader is responsible for preparing a mini app for execution,
/// such as warming up resources or downloading assets.
abstract class MiniAppPreloader {
  /// Preloads the resources for a mini app based on its manifest.
  ///
  /// [manifest] - The manifest containing metadata about the mini app.
  Future<void> preload(MiniAppManifest manifest);
}

/// Preloader implementation for web-based mini apps.
///
/// This class handles tasks such as warming up the webview or downloading assets.
class WebPreloader implements MiniAppPreloader {
  @override
  Future<void> preload(MiniAppManifest manifest) async {
    // Warm up webview, download assets, etc.
    print("Preloading web mini app: ${manifest.appId}");
    // Additional preloading logic can be added here.
  }
}

/// Preloader implementation for native mini apps.
///
/// This class handles tasks such as downloading native assets.
class NativePreloader implements MiniAppPreloader {
  @override
  Future<void> preload(MiniAppManifest manifest) async {
    // Download native assets, etc.
    print("Preloading native mini app: ${manifest.appId}");
    // Additional preloading logic can be added here.
  }
}

/// Preloader implementation for Flutter web-based mini apps.
///
/// This class handles tasks such as warming up the webview or downloading assets.
class FlutterWebPreloader implements MiniAppPreloader {
  @override
  Future<void> preload(MiniAppManifest manifest) async {
    // Warm up webview, download assets, etc.
    print("Preloading Flutter web mini app: ${manifest.appId}");
    // Additional preloading logic can be added here.
  }
}

/// Preloader implementation for React Native mini apps.
///
/// This class handles tasks such as downloading native assets.
class ReactNativePreloader implements MiniAppPreloader {
  @override
  Future<void> preload(MiniAppManifest manifest) async {
    // Download native assets, etc.
    print("Preloading native mini app: ${manifest.appId}");
    // Additional preloading logic can be added here.
  }
}

/// Preloader implementation for Flutter native mini apps.
///
/// This class handles tasks such as downloading native assets.
class FlutterNativePreloader implements MiniAppPreloader {
  @override
  Future<void> preload(MiniAppManifest manifest) async {
    // Download native assets, etc.
    print("Preloading Flutter native mini app: ${manifest.appId}");
    // Additional preloading logic can be added here.
  }
}