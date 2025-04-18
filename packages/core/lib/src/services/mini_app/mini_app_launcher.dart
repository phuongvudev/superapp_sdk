import 'dart:async';
import 'package:core/src/brigdes/mini_app/mini_app_platform_interface.dart';
import 'package:core/src/constants/framework_type.dart';
import 'package:core/src/exception/mini_app_exception.dart';
import 'package:core/src/models/mini_app_manifest.dart';
import 'package:core/src/repository/mini_app_mainifest_repository.dart';
import 'package:core/src/services/mini_app/mini_app_preloader.dart';
import 'package:flutter/material.dart';

class MiniAppLauncher implements MiniAppPreloaderRegistrar {
  static MiniAppLauncher? _instance;

  /// Singleton instance of `MiniAppLauncher`
  static FutureOr<MiniAppLauncher> getInstance(
      [MiniAppManifestRepository? registry]) {
    _instance ??= MiniAppLauncher._internal(registry);
    return _instance!;
  }

  /// Private constructor for initializing the launcher
  MiniAppLauncher._internal([MiniAppManifestRepository? registry]) {
    _registry =
        registry ?? FileMiniAppManifestRepository('path/to/mini_apps.json');
    _loadRegistry();
  }

  late final Map<String, MiniAppManifest> _loadedRegistry;

  /// Platform-specific implementation for launching mini apps
  final MiniAppPlatform _platform = MiniAppPlatform.instance;

  /// Repository for managing mini app manifests
  late final MiniAppManifestRepository _registry;

  /// Constructor for initializing with a custom manifest repository
  MiniAppLauncher([MiniAppManifestRepository? registry]) {
    _registry = registry ??
        FileMiniAppManifestRepository('assets/data/mini_app/mini_apps.json');
  }

  /// Preloaders for different framework types
  final Map<FrameworkType, MiniAppPreloader> _preLoaders = {
    FrameworkType.web: WebPreloader(),
    FrameworkType.flutterWeb: WebPreloader(),
    FrameworkType.native: NativePreloader(),
    FrameworkType.reactNative: ReactNativePreloader(),
  };

  /// Loads the mini app registry from the repository
  Future<void> _loadRegistry() async {
    _loadedRegistry = await _registry.loadRegistry();
  }

  /// Loads a mini app widget based on its ID
  Future<Widget?> loadMiniAppWidget(String appId) async {
    try {
      final manifest = _loadedRegistry[appId];
      if (manifest == null) {
        return const Center(child: Text("Mini App not found"));
      }
      switch (manifest.framework) {
        case FrameworkType.flutterWeb:
        case FrameworkType.web:
          await _platform.launchWebMiniApp(manifest);
          return null;
        case FrameworkType.native:
        case FrameworkType.reactNative:
          await _platform.launchNativeMiniApp(manifest);
          return null;

        default:
          throw UnsupportedFrameworkException(manifest.framework);
      }
    } on MiniAppNotFoundException catch (e) {
      // Handle case where the mini app is not found
      print("Error loading mini app: $e");
      return Center(child: Text("Mini app not found: ${e.appId}"));
    } on UnsupportedFrameworkException catch (e) {
      // Handle case where the framework is unsupported
      print("Error loading mini app: $e");
      return Center(
          child: Text("Unsupported mini app framework: ${e.framework}"));
    } catch (e) {
      // Handle unexpected errors
      print("Unexpected error loading mini app: $e");
      return const Center(child: Text("Unexpected error loading mini app"));
    }
  }

  /// Preloads a mini app based on its ID
  Future<void> preloadMiniApp(String appId) async {
    final registry = await _registry.loadRegistry();
    final manifest = registry[appId];
    if (manifest == null) return;

    final preloader = _preLoaders[manifest.framework];
    if (preloader != null) {
      await preloader.preload(manifest);
    }
  }

  /// Registers a custom preloader for a specific framework
  @override
  void registerPreloader(FrameworkType framework, MiniAppPreloader preloader) {
    _preLoaders[framework] = preloader;
  }

  /// Registers a new mini app manifest
  Future<void> registerMiniApp(MiniAppManifest manifest) async {
    _loadedRegistry[manifest.id] = manifest;
  }

  /// Unregisters a mini app by its ID
  Future<void> unregisterMiniApp(String appId) async {
    _loadedRegistry.remove(appId);
  }

  /// Retrieves the list of registered mini apps
  Future<List<MiniAppManifest>> get registeredMiniApps async {
    return _loadedRegistry.values.toList();
  }
}