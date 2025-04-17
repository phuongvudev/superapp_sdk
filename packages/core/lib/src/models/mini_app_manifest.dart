import 'package:core/src/constants/framework_type.dart';
import 'package:flutter/foundation.dart';

@immutable
class MiniAppManifest {
  final String id;
  final String name;
  final FrameworkType framework;
  final String entryPath;
  final String? mainComponent;

  const MiniAppManifest({
    required this.id,
    required this.name,
    required this.framework,
    required this.entryPath,
    this.mainComponent,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'framework': framework.name,
        'entryPath': entryPath,
        'mainComponent': mainComponent,
      };

  factory MiniAppManifest.fromJson(Map<String, dynamic> json) {
    return MiniAppManifest(
      id: json['id'],
      name: json['name'],
      framework: FrameworkTypeX.fromString(json['framework']),
      entryPath: json['entryPath'],
      mainComponent: json['mainComponent'],
    );
  }
}
