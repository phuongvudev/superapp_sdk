import 'package:skit_sdk/src/communication/event_bus.dart';
  import 'package:skit_sdk/src/communication/external/deep_link.dart';
import 'package:skit_sdk/src/configs/sdk_config_optional.dart';
  import 'package:skit_sdk/src/logger/logger_mixin.dart';
  import 'package:skit_sdk/src/services/mini_app/mini_app_launcher.dart';

  /// The main SDK initializer class.
  ///
  /// This class is responsible for setting up and initializing the SDK with
  /// the required dependencies and configuration.
  class SKit with LoggerMixin {
    /// Event bus for handling communication between components.
    late final EventBus eventBus;

    /// Mini app launcher for managing and launching mini apps.
    late final MiniAppLauncher miniApp;

    /// Deep link dispatcher for handling deep link navigation.
    late final DeepLinkDispatcher deepLink;

    late final SDKOptionalConfig? optionalConfig;

    /// Initializes the SDK with the provided dependencies and configuration.
    ///
    /// [config] - A map containing the SDK configuration.
    /// [optionalConfig] - An instance of [SDKConfigOptional] for optional settings.
    Future<void> initialize({
      required Map<String, dynamic> config,
      SDKOptionalConfig? optionalConfig,
    }) async {
      try {
        // Store the optional configuration for later use.
        this.optionalConfig = optionalConfig;

        // Initialize the event bus with optional encryption settings.
        eventBus = EventBus(
          encryptor: optionalConfig?.encryptor,
          encryptionKey: optionalConfig?.encryptionKey,
        );

        // Initialize the mini app launcher with optional registry and pre-loaders.
        miniApp = MiniAppLauncher(
          registry: optionalConfig?.miniAppRegistry,
          preLoaders: optionalConfig?.miniAppPreLoaders,
        );

        // Initialize the deep link dispatcher with the mini app launcher.
        deepLink = DeepLinkDispatcher(
          miniAppLauncher: miniApp,
        );

        // Set up additional dependencies based on the configuration.
        _setupDependencies(config);

        // Log successful initialization.
        _logInitializationSuccess();
      } catch (e, stackTrace) {
        // Log initialization failure and rethrow the error.
        _logInitializationFailure(e, stackTrace);
        rethrow;
      }
    }

    /// Sets up dependencies based on the provided configuration.
    ///
    /// [config] - A map containing configuration values such as API keys
    /// and endpoints.
    void _setupDependencies(Map<String, dynamic> config) {
      if (config.containsKey('apiKey')) {
        // Set up the API key.
      }
      if (config.containsKey('endpoint')) {
        // Set up the endpoint.
      }
    }

    /// Logs a message indicating successful SDK initialization.
    void _logInitializationSuccess() {
      logger.info('SDK initialized successfully.');
    }

    /// Logs a message indicating SDK initialization failure.
    ///
    /// [error] - The error that occurred during initialization.
    /// [stackTrace] - The stack trace of the error.
    void _logInitializationFailure(Object error, StackTrace stackTrace) {
      logger.error('SDK initialization failed: $error', error, stackTrace);
    }
  }