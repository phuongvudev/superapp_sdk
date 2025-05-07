import 'package:skit_sdk/src/constants/framework_type.dart';
import 'package:skit_sdk/src/encrypt/encryptor.dart';
import 'package:skit_sdk/src/repository/mini_app_mainifest_repository.dart';
import 'package:skit_sdk/src/services/mini_app/mini_app_preloader.dart';

/// A class representing optional configuration for the SDK.
///
/// This class allows you to specify optional parameters for initializing
/// the SDK, such as encryption settings, mini app registry, and pre-loaders.
class SDKOptionalConfig {
  /// Optional repository for managing mini app manifests.
  final MiniAppManifestRepository? miniAppRegistry;

  /// Optional map of pre-loaders for different frameworks.
  final Map<FrameworkType, MiniAppPreloader>? miniAppPreLoaders;

  /// Optional encryptor for handling encryption.
  final MapEncryptor? encryptor;

  /// Optional encryption key for secure communication.
  final String? encryptionKey;

  /// Creates an instance of [SDKConfigOptional].
  ///
  /// [miniAppRegistry] - Custom repository for mini app manifests.
  /// [miniAppPreLoaders] - Map of pre-loaders for different frameworks.
  /// [encryptor] - Custom encryptor for encryption and decryption.
  /// [encryptionKey] - Encryption key for secure communication.
  const SDKOptionalConfig({
    this.miniAppRegistry,
    this.miniAppPreLoaders,
    this.encryptor,
    this.encryptionKey,
  });
}