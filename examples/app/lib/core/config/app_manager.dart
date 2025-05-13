import 'package:app/communication/app_deep_link_handler.dart';
import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';
import 'package:skit_sdk/kit.dart';

@singleton
final class AppManager with LoggerMixin {
  late final SuperAppKit _superAppKit;

  ///Getter for the SuperAppKit instance
  SuperAppKit get superAppKit => _superAppKit;

  /// Initialize the SDK with provided configuration
  @PostConstruct(preResolve: true)
  Future<void> initialize() async {
    try {
      // First build the Mini App
      // This is a pre-built MiniApp instance that will be used in the SuperAppKit
      // The registry path is where the mini app manifests are stored
      // This is a JSON file that contains the list of mini apps and their metadata
      final miniApp =
          await MiniAppKit.builder()
              .withRegistryPath('assets/data/mini_app/mini_apps.json')
              .build();

      // Create a custom deep link handler for better control
      // This handler will be responsible for handling deep links
      // and routing them to the appropriate mini app
      final customDeepLinkHandler = AppDeepLinkHandler(miniApp: miniApp);

      // Use the builder pattern to create the SuperAppKit with our custom MiniApp
      // and the custom deep link handler
      // The config parameter is a map that contains the configuration for the SDK
      _superAppKit =
          await SuperAppKit.builder()
              .withEnvConfig( {})
              .withMiniApp(miniApp)
              .withOptionalConfig(
                    AppOptionalConfig(deepLinkHandler: customDeepLinkHandler),
              )
              .build();

      logger.info('App manager initialized successfully');
    } catch (e, stackTrace) {
      logger.error('Failed to initialize app manager', e, stackTrace);
      rethrow;
    }
  }

  /// Launch a mini app by its ID
  Future<Widget?> launchMiniApp(String appId, {Map<String, dynamic>? params}) {
    return _superAppKit.miniApp.launch(appId, params: params);
  }

  /// Preload a mini app by its ID
  Future<void> preloadMiniApp(String appId) {
    return _superAppKit.miniApp.preloadMiniApp(appId);
  }

  /// Register a mini app manifest
  void registerMiniApp(MiniAppManifest manifest) {
    _superAppKit.miniApp.registerMiniApp(manifest);
  }

  /// Register a preloader for a specific framework
  void registerPreloader(FrameworkType framework, MiniAppPreloader preloader) {
    _superAppKit.miniApp.registerPreloader(framework, preloader);
  }

  /// Unregister a mini app by its ID
  void unregisterMiniApp(String appId) {
    _superAppKit.miniApp.unregisterMiniApp(appId);
  }
}
