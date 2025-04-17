import 'dart:async';
import 'dart:io';
import 'package:core/src/brigdes/mini_app/mini_app_platform_interface.dart';
import 'package:core/src/constants/framework_type.dart';
import 'package:core/src/exception/mini_app_exception.dart';
import 'package:core/src/models/mini_app_manifest.dart';
import 'package:core/src/repository/mini_app_mainifest_repository.dart';
import 'package:core/src/services/mini_app/mini_app_preloader.dart';
import 'package:flutter/material.dart';

class MiniAppLauncher implements MiniAppPreloaderRegistrar {
  static MiniAppLauncher? _instance;

  static FutureOr<MiniAppLauncher> getInstance(
      [MiniAppManifestRepository? registry]) {
    _instance ??= MiniAppLauncher._internal(registry);
    return _instance!;
  }

  MiniAppLauncher._internal([MiniAppManifestRepository? registry]) {
    _registry =
        registry ?? FileMiniAppManifestRepository('path/to/mini_apps.json');
    _loadRegistry();
  }

  late final Map<String, MiniAppManifest> _loadedRegistry;


  final MiniAppPlatform _platform = MiniAppPlatform.instance;

  late final MiniAppManifestRepository _registry;

  MiniAppLauncher([MiniAppManifestRepository? registry]) {
    _registry = registry ??
        FileMiniAppManifestRepository('assets/data/mini_app/mini_apps.json');
  }

  final Map<FrameworkType, MiniAppPreloader> _preLoaders = {
    FrameworkType.web: WebPreloader(),
    FrameworkType.flutterWeb: WebPreloader(),
    FrameworkType.native: NativePreloader(),
    FrameworkType.reactNative: ReactNativePreloader(),
  };


  Future<void> _loadRegistry() async {
    _loadedRegistry = await _registry.loadRegistry();
  }

  Future<Widget?> loadMiniAppWidget(String appId) async {
    try {
      final manifest =  _loadedRegistry[appId];
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
      print("Error loading mini app: $e");
      return Center(child: Text("Mini app not found: ${e.appId}"));
    } on UnsupportedFrameworkException catch (e) {
      print("Error loading mini app: $e");
      return Center(
          child: Text("Unsupported mini app framework: ${e.framework}"));
    } catch (e) {
      print("Unexpected error loading mini app: $e");
      return const Center(child: Text("Unexpected error loading mini app"));
    }
  }

  Future<void> preloadMiniApp(String appId) async {
    final registry = await _registry.loadRegistry();
    final manifest = registry[appId];
    if (manifest == null) return;

    final preloader = _preLoaders[manifest.framework];
    if (preloader != null) {
      await preloader.preload(manifest);
    }
  }

  @override
  void registerPreloader(FrameworkType framework, MiniAppPreloader preloader) {
    _preLoaders[framework] = preloader;
  }

  Future<void> registerMiniApp(MiniAppManifest manifest) async {
    _loadedRegistry[manifest.id] = manifest;
  }

  Future<void> unregisterMiniApp(String appId) async {
    _loadedRegistry.remove(appId);
  }

  Future<List<MiniAppManifest>> get registeredMiniApps async{
    return _loadedRegistry.values.toList();
  }
}
