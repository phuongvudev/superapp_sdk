import 'package:skit_sdk/src/communication/communication.dart';
import 'package:skit_sdk/src/logger/logger.dart';
import 'package:skit_sdk/src/models/app_config_optional.dart';

import 'package:skit_sdk/src/kit/mini_app/mini_app_kit.dart';

/// The main SDK initializer class.
///
/// This class is responsible for setting up and initializing the SDK with
/// the required dependencies and configuration.
class SuperAppKit {
  /// Event bus for handling communication between components.
  final EventBus eventBus;

  /// Mini app launcher for managing and launching mini apps.
  final MiniAppKit miniApp;

  /// Deep link for handling deep link navigation.
  final DeepLink deepLink;

  /// Optional configuration for the SDK.
  final AppOptionalConfig? optionalConfig;

  /// Optional environment configuration for the SDK.
  final Map<String, dynamic>? envConfig;

  SuperAppKit._({
    required this.eventBus,
    required this.miniApp,
    required this.deepLink,
    this.optionalConfig,
    this.envConfig,
  });

  /// Creates a new builder for SuperAppKit
  static SuperAppKitBuilder builder() => SuperAppKitBuilder();
}

/// Builder class for creating SuperAppKit instances
class SuperAppKitBuilder with LoggerMixin {
  Map<String, dynamic>? _envConfig;
  AppOptionalConfig? _optionalConfig;
  EventBus? _eventBus;
  MiniAppKit? _miniAppKit;
  String _registryPath = 'assets/data/mini_app/mini_apps.json';
  bool isDebug = false;

  /// Sets the environment configuration map
  SuperAppKitBuilder withEnvConfig(Map<String, dynamic> envConfig) {
    _envConfig = envConfig;
    return this;
  }

  /// Sets the optional configuration
  SuperAppKitBuilder withOptionalConfig(AppOptionalConfig optionalConfig) {
    _optionalConfig = optionalConfig;
    return this;
  }

  /// Sets a custom EventBus instance
  SuperAppKitBuilder withEventBus(EventBus eventBus) {
    _eventBus = eventBus;
    return this;
  }

  /// Sets a pre-built MiniAppKit instance directly
  SuperAppKitBuilder withMiniApp(MiniAppKit miniAppKit) {
    _miniAppKit = miniAppKit;
    return this;
  }

  /// Sets the path for the mini app registry
  SuperAppKitBuilder withRegistryPath(String path) {
    _registryPath = path;
    return this;
  }

  /// Sets the debug mode

  SuperAppKitBuilder withDebugMode(bool debug) {
    isDebug = debug;
    return this;
  }

  /// Builds and returns a configured SuperAppKit instance
  Future<SuperAppKit> build() async {
    try {
      // Initialize EventBus
      // Use existing EventBus or create a new one using builder pattern
      // with optional encryption settings
      // This allows for secure communication between components
      // while maintaining flexibility in configuration
      final eventBus =
          _eventBus ??
          EventBus(
            encryptor: _optionalConfig?.encryptor,
            encryptionKey: _optionalConfig?.encryptionKey,
          );

      // Use existing MiniAppKit or create a new one using builder pattern
      // with optional registry and pre-loaders
      // This allows for flexibility in mini app management
      final miniApp = _miniAppKit ?? await _buildMiniAppKit();

      // Create a dedicated deep link handler
      // This handler will be responsible for handling deep links
      final deepLinkHandler =
          _optionalConfig?.deepLinkHandler ??
          DefaultDeepLinkHandler(miniApp: miniApp);

      // Initialize the deep link manager with the handler
      // This allows for custom handling of deep links
      final deepLink = DeepLink(
        miniAppMatcher: deepLinkHandler.miniAppMatcher,
        onMiniAppLink: deepLinkHandler.onMiniAppLink,
        onFallbackDeepLink: deepLinkHandler.onFallbackDeepLink,
        onDeepLinkTrack: deepLinkHandler.onDeepLinkTrack,
      );

      final superAppKit = SuperAppKit._(
        eventBus: eventBus,
        miniApp: miniApp,
        deepLink: deepLink,
        optionalConfig: _optionalConfig,
        envConfig: _envConfig,
      );

      if (isDebug) {
        logger.info('Super App Kit initialized successfully.');
        // Log the environment configuration for debugging purposes
        logger.info('Environment configuration: $_envConfig');
        // Log the event bus for debugging purposes
        logger.info('Event bus: $_eventBus');
        // Log the number of mini apps registered
        logger.info(
          'Super App Kit initialized with ${miniApp.registeredMiniApps.length} mini apps.',
        );
        // Log the registry path for debugging purposes
        logger.info('Mini App registry path: $_registryPath');
        // Log the optional configuration for debugging purposes
        logger.info('Optional configuration: $_optionalConfig');
      }

      return superAppKit;
    } catch (error, stackTrace) {
      logger.error('Super App Kit initialization failed', error, stackTrace);
      rethrow;
    }
  }

  /// Helper method to build MiniAppKit using builder pattern
  Future<MiniAppKit> _buildMiniAppKit() async {
    final miniAppBuilder = MiniAppKit.builder().withRegistryPath(_registryPath);

    // Add registry if provided in optional config
    if (_optionalConfig?.miniAppRegistry != null) {
      miniAppBuilder.withRegistry(_optionalConfig!.miniAppRegistry!);
    }

    // Add preloaders if provided
    if (_optionalConfig?.miniAppPreLoaders != null) {
      miniAppBuilder.withPreLoaders(_optionalConfig!.miniAppPreLoaders!);
    }

    return miniAppBuilder.build();
  }
}
