import 'package:core/src/constants/framework_type.dart';
import 'package:core/src/models/mini_app_manifest.dart';

abstract class MiniAppPreloaderRegistrar {
  void registerPreloader(FrameworkType framework, MiniAppPreloader preloader);
}


abstract class MiniAppPreloader {
  Future<void> preload(MiniAppManifest manifest);
}

class WebPreloader implements MiniAppPreloader {
  @override
  Future<void> preload(MiniAppManifest manifest) async {
    // Warm up webview, download assets, etc.
    print("Preloading web mini app: ${manifest.id}");
    // ...
  }
}

class NativePreloader implements MiniAppPreloader {
  @override
  Future<void> preload(MiniAppManifest manifest) async {
    // Download native assets, etc.
    print("Preloading native mini app: ${manifest.id}");
    // ...
  }
}

class FlutterWebPreloader implements MiniAppPreloader {
  @override
  Future<void> preload(MiniAppManifest manifest) async {
    // Warm up webview, download assets, etc.
    print("Preloading Flutter web mini app: ${manifest.id}");
    // ...
  }
}

class ReactNativePreloader implements MiniAppPreloader {
  @override
  Future<void> preload(MiniAppManifest manifest) async {
    // Download native assets, etc.
    print("Preloading native mini app: ${manifest.id}");
    // ...
  }
}
