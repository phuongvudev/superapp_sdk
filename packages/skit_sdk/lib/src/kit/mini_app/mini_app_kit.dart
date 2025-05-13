import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:skit_sdk/src/brigdes/mini_app/mini_app_platform_interface.dart';
import 'package:skit_sdk/src/constants/framework_type.dart';
import 'package:skit_sdk/src/exception/mini_app_exception.dart';
import 'package:skit_sdk/src/logger/logger.dart';
import 'package:skit_sdk/src/models/mini_app_manifest.dart';
import 'package:flutter/widgets.dart';

part 'mini_app_preloader.dart';

part 'mini_app_handler.dart';

part 'mini_app_mainifest_repository.dart';

class MiniAppKit
    with LoggerMixin
    implements MiniAppPreloaderRegistrar, MiniAppHandler {
  final Map<String, MiniAppManifest> _loadedRegistry;

  /// Platform-specific implementation for launching mini apps
  final MiniAppPlatform _platform;

  /// Repository for managing mini app manifests
  final MiniAppManifestRepository _registry;

  /// Pre-loaders for different framework types
  final Map<FrameworkType, MiniAppPreloader> _preLoaders;

  /// Private constructor used by the builder
  MiniAppKit._({
    required MiniAppManifestRepository registry,
    required Map<FrameworkType, MiniAppPreloader> preLoaders,
    MiniAppPlatform? platform,
    Map<String, MiniAppManifest>? initialRegistry,
  }) : _registry = registry,
       _preLoaders = preLoaders,
       _platform = platform ?? MiniAppPlatform.instance,
       _loadedRegistry = initialRegistry ?? {};

  /// Creates a new builder for MiniAppKit
  static MiniAppKitBuilder builder() => MiniAppKitBuilder();

  /// Loads a mini app widget based on its ID
  @override
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
        child: Text("Unsupported mini app framework: ${e.framework}"),
      );
    } catch (e, stackTrace) {
      // Handle unexpected errors
      logger.error("Unexpected error loading mini app: $e", e, stackTrace);
      return const Center(child: Text("Unexpected error loading mini app"));
    }
  }

  /// Preloads a mini app based on its ID
  @override
  Future<void> preloadMiniApp(String appId) async {
    final manifest = _loadedRegistry[appId];
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
  @override
  void registerMiniApp(MiniAppManifest manifest) {
    _loadedRegistry[manifest.appId] = manifest;
  }

  /// Unregisters a mini app by its ID
  @override
  void unregisterMiniApp(String appId) {
    _loadedRegistry.remove(appId);
  }

  /// Retrieves the list of registered mini apps
  List<MiniAppManifest> get registeredMiniApps {
    return _loadedRegistry.values.toList();
  }
}

/// Builder for creating MiniAppKit instances
class MiniAppKitBuilder with LoggerMixin {
  MiniAppManifestRepository? _registry;
  Map<FrameworkType, MiniAppPreloader>? _preLoaders;
  MiniAppPlatform? _platform;
  String _registryPath = 'assets/data/mini_app/mini_apps.json';

  /// Sets a custom manifest repository
  MiniAppKitBuilder withRegistry(MiniAppManifestRepository registry) {
    _registry = registry;
    return this;
  }

  /// Sets the path for the file-based registry
  MiniAppKitBuilder withRegistryPath(String path) {
    _registryPath = path;
    return this;
  }

  /// Sets custom preloaders for different framework types
  MiniAppKitBuilder withPreLoaders(
    Map<FrameworkType, MiniAppPreloader> preLoaders,
  ) {
    _preLoaders = preLoaders;
    return this;
  }

  /// Sets a custom platform implementation
  MiniAppKitBuilder withPlatform(MiniAppPlatform platform) {
    _platform = platform;
    return this;
  }

  /// Adds a single preloader for a specific framework
  MiniAppKitBuilder addPreloader(
    FrameworkType framework,
    MiniAppPreloader preloader,
  ) {
    _preLoaders ??= {};
    _preLoaders![framework] = preloader;
    return this;
  }

  /// Builds and returns a configured MiniAppKit instance
  Future<MiniAppKit> build() async {
    try {
      // Create default registry if not provided
      final registry =
          _registry ?? AssetMiniAppManifestRepository(_registryPath);

      // Create default preloaders if not provided
      final preLoaders =
          _preLoaders ??
          {
            FrameworkType.web: WebPreloader(),
            FrameworkType.flutterWeb: WebPreloader(),
            FrameworkType.native: NativePreloader(),
            FrameworkType.reactNative: ReactNativePreloader(),
            FrameworkType.flutter: FlutterNativePreloader(),
          };

      // Load the registry
      final loadedRegistry = await registry.loadRegistry();

      logger.info('MiniAppKit initialized with ${loadedRegistry.length} apps');

      // Create the MiniAppKit instance with pre-loaded registry
      return MiniAppKit._(
        registry: registry,
        preLoaders: preLoaders,
        platform: _platform,
        initialRegistry: loadedRegistry,
      );
    } catch (error, stackTrace) {
      logger.error('Failed to build MiniAppKit', error, stackTrace);
      rethrow;
    }
  }
}
