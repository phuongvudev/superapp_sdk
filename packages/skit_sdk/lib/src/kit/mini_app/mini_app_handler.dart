

part of 'mini_app_kit.dart';


interface class MiniAppHandler {
  /// Loads a mini app widget based on its ID
  Future<Widget?> launch(String appId, {Map<String, dynamic>? params}) {
    throw UnimplementedError();
  }

  /// Preloads a mini app based on its ID
  Future<void> preloadMiniApp(String appId) {
    throw UnimplementedError();
  }

  /// Registers a custom preloader for a specific framework
  void registerPreloader(FrameworkType framework, MiniAppPreloader preloader) {
    throw UnimplementedError();
  }

  /// Registers a new mini app manifest
  void registerMiniApp(MiniAppManifest manifest) {
    throw UnimplementedError();
  }

  /// Unregisters a mini app by its ID
  void unregisterMiniApp(String appId) {
    throw UnimplementedError();
  }
}
