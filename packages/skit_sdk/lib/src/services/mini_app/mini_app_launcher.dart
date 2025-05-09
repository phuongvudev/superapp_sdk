import 'dart:async';
import 'package:skit_sdk/src/brigdes/mini_app/mini_app_platform_interface.dart';
import 'package:skit_sdk/src/constants/framework_type.dart';
import 'package:skit_sdk/src/exception/mini_app_exception.dart';
import 'package:skit_sdk/src/logger/logger_mixin.dart';
import 'package:skit_sdk/src/models/mini_app_manifest.dart';
import 'package:skit_sdk/src/repository/mini_app_mainifest_repository.dart';
import 'package:skit_sdk/src/services/mini_app/mini_app_preloader.dart';
import 'package:flutter/material.dart';

class MiniAppLauncher with LoggerMixin implements MiniAppPreloaderRegistrar {
  late final Map<String, MiniAppManifest> _loadedRegistry;

  /// Platform-specific implementation for launching mini apps
  final MiniAppPlatform _platform = MiniAppPlatform.instance;

  /// Repository for managing mini app manifests
  late final MiniAppManifestRepository _registry;

  /// Pre-loaders for different framework types
  late final Map<FrameworkType, MiniAppPreloader> _preLoaders;

  /// Constructor for initializing with a custom manifest repository
  /// [registry] - Optional custom repository for loading mini app manifests.
  /// [preLoaders] - Optional map of pre-loaders for different frameworks.
  /// If not provided, a default file-based repository is used. With the path is "assets/data/mini_app/mini_apps.json"
  MiniAppLauncher(
      {MiniAppManifestRepository? registry,
      Map<FrameworkType, MiniAppPreloader>? preLoaders}) {
    _registry = registry ??
        FileMiniAppManifestRepository('assets/data/mini_app/mini_apps.json');
    _preLoaders = preLoaders ??
        {
          FrameworkType.web: WebPreloader(),
          FrameworkType.flutterWeb: WebPreloader(),
          FrameworkType.native: NativePreloader(),
          FrameworkType.reactNative: ReactNativePreloader(),
          FrameworkType.flutter: FlutterNativePreloader(),
        };
  }

  /// Loads the mini app registry from the repository
  Future<void> _loadRegistry() async {
    _loadedRegistry = await _registry.loadRegistry();
  }

  /// Loads a mini app widget based on its ID
  Future<Widget?> launch(String appId, {Map<String, dynamic>? params}) async {
    try {
      var manifest = _loadedRegistry[appId];
      if (manifest == null) {
        return const Center(child: Text("Mini App not found"));
      }
      if (params != null) {
        manifest = manifest.copyWith(params: params);
      }
      switch (manifest.framework) {
        case FrameworkType.flutterWeb:
        case FrameworkType.web:
          await _platform.launchWebMiniApp(manifest);
          return null;
        case FrameworkType.native:
        case FrameworkType.reactNative:
          await _platform.launchMiniApp(manifest);
          return null;
        case FrameworkType.flutter:
          return _platform.launchFlutterMiniApp(manifest);

        default:
          throw UnsupportedFrameworkException(manifest.framework);
      }
    } on MiniAppNotFoundException catch (e) {
      // Handle case where the mini app is not found
      logger.error("Mini app not found: ${e.appId}", e);
      return Center(child: Text("Mini app not found: ${e.appId}"));
    } on UnsupportedFrameworkException catch (e) {
      // Handle case where the framework is unsupported
      logger.error("Unsupported mini app framework: ${e.framework}", e);
      return Center(
          child: Text("Unsupported mini app framework: ${e.framework}"));
    } catch (e, stackTrace) {
      // Handle unexpected errors
      logger.error("Unexpected error loading mini app: $e", e, stackTrace);
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
    _loadedRegistry[manifest.appId] = manifest;
  }

  /// Unregisters a mini app by its ID
  Future<void> unregisterMiniApp(String appId) async {
    _loadedRegistry.remove(appId);
  }

  /// Retrieves the list of registered mini apps
  List<MiniAppManifest> get registeredMiniApps {
    return _loadedRegistry.values.toList();
  }
}
