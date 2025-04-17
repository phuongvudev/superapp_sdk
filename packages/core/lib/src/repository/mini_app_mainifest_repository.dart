import 'dart:convert';
import 'dart:io';

import 'package:core/src/logger/logger.dart';
import 'package:core/src/models/mini_app_manifest.dart';

abstract base class MiniAppManifestRepository {
  Future<Map<String, MiniAppManifest>> loadRegistry();
  void saveRegistry(Map<String, MiniAppManifest> registry);
}



final class FileMiniAppManifestRepository implements MiniAppManifestRepository {
  final String filePath;

  FileMiniAppManifestRepository(this.filePath);

  @override
  Future<Map<String, MiniAppManifest>> loadRegistry() async {
    // Load and parse the JSON file
    final file = File(filePath);
    final jsonString = await file.readAsString();
    // Convert json string to a map
    final data = jsonDecode(jsonString) as Map<String, dynamic>;
    // Convert Map<String, dynamic> to Map<String, MiniAppManifest>
    final miniApps = data.map((key, value) => MapEntry(key, MiniAppManifest.fromJson(value)));
    return miniApps;
  }

  @override
  void saveRegistry(Map<String, MiniAppManifest> registry) {
    // TODO: implement saveRegistry
  }


}