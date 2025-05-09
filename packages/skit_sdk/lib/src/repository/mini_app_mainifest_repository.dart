import 'dart:convert';
import 'dart:io';

import 'package:skit_sdk/src/models/mini_app_manifest.dart';

/// Abstract base class for managing mini app manifests.
///
/// This class defines the contract for loading and saving the registry
/// of mini app manifests.
abstract base class MiniAppManifestRepository {
  /// Loads the registry of mini app manifests.
  ///
  /// Returns a map where the key is the mini app ID and the value is the
  /// corresponding `MiniAppManifest` object.
  Future<Map<String, MiniAppManifest>> loadRegistry();

  /// Saves the registry of mini app manifests.
  ///
  /// [registry] - A map where the key is the mini app ID and the value is the
  /// corresponding `MiniAppManifest` object.
  void saveRegistry(Map<String, MiniAppManifest> registry);
}

/// Implementation of `MiniAppManifestRepository` that uses a file for storage.
///
/// This class reads and writes the mini app manifest registry to a JSON file.
final class FileMiniAppManifestRepository implements MiniAppManifestRepository {
  /// Path to the JSON file storing the mini app manifest registry.
  final String filePath;

  /// Creates a new instance of `FileMiniAppManifestRepository`.
  ///
  /// [filePath] - The path to the JSON file.
  FileMiniAppManifestRepository(this.filePath);

  /// Loads the mini app manifest registry from the JSON file.
  ///
  /// Reads the file, parses the JSON content, and converts it into a map
  /// of mini app manifests.
  @override
  Future<Map<String, MiniAppManifest>> loadRegistry() async {
    final file = File(filePath);
    final jsonString = await file.readAsString();
    final data = jsonDecode(jsonString) as Map<String, dynamic>;
    return data.map((key, value) => MapEntry(key, MiniAppManifest.fromJson(value)));
  }

  /// Saves the mini app manifest registry to the JSON file.
  ///
  /// Converts the registry map into JSON format and writes it to the file.
  @override
  void saveRegistry(Map<String, MiniAppManifest> registry) {
    final file = File(filePath);
    final jsonString = jsonEncode(registry.map((key, value) => MapEntry(key, value.toJson())));
    file.writeAsStringSync(jsonString);
  }
}