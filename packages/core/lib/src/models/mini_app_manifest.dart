import 'package:core/src/constants/framework_type.dart';
import 'package:flutter/foundation.dart';

/// Represents the manifest of a mini app.
///
/// This class contains metadata about a mini app, such as its ID, name,
/// framework type, entry path, and optional main component.
@immutable
class MiniAppManifest {
  /// Unique identifier for the mini app.
  final String appId;

  /// Display name of the mini app.
  final String name;

  /// Framework type used by the mini app (e.g., Flutter, React Native).
  final FrameworkType framework;

  /// Path to the entry point of the mini app.
  final String entryPath;

  /// Optional name of the main component for the mini app.
  final String? mainComponent;

  /// Optional parameters for the mini app.
  final Map<String, dynamic>? params;

  /// Optional deep links the mini app can handle.
  final List<String>? deepLinks;

  /// Optional list of supported events for the mini app.
  final List<String>? supportedEvents;


  /// Creates a new instance of `MiniAppManifest`.
  ///
  /// [appId] - The unique identifier for the mini app.
  /// [name] - The display name of the mini app.
  /// [framework] - The framework type used by the mini app.
  /// [entryPath] - The path to the entry point of the mini app.
  /// [mainComponent] - The optional name of the main component.
  /// [deepLinks] - The optional list of deep links the mini app can handle.
  const MiniAppManifest({
    required this.appId,
    required this.name,
    required this.framework,
    required this.entryPath,
    this.mainComponent,
    this.params,
    this.deepLinks,
    this.supportedEvents,
  });

  /// Converts the `MiniAppManifest` instance to a JSON-compatible map.
  ///
  /// Returns a map containing the mini app's metadata.
  Map<String, dynamic> toJson() => {
    'id': appId,
    'name': name,
    'framework': framework.name,
    'entryPath': entryPath,
    'mainComponent': mainComponent,
    'params': params,
    'deepLinks': deepLinks,
    'supportedEvents': supportedEvents,
  };

  /// Creates a `MiniAppManifest` instance from a JSON-compatible map.
  ///
  /// [json] - A map containing the mini app's metadata.
  /// Returns a new `MiniAppManifest` instance.
  factory MiniAppManifest.fromJson(Map<String, dynamic> json) {
    return MiniAppManifest(
      appId: json['id'],
      name: json['name'],
      framework: FrameworkTypeX.fromString(json['framework']),
      entryPath: json['entryPath'],
      mainComponent: json['mainComponent'],
      params: json['params'] != null
          ? Map<String, dynamic>.from(json['params'])
          : null,
      deepLinks: json['deepLinks'],
      supportedEvents: json['supportedEvents'],

    );
  }

  /// Creates a copy of the `MiniAppManifest` instance with optional modifications.
  MiniAppManifest copyWith({
    String? appId,
    String? name,
    FrameworkType? framework,
    String? entryPath,
    String? mainComponent,
    Map<String, dynamic>? params,
    List<String>? deepLinks,
    List<String>? supportedEvents,
  }) {
    return MiniAppManifest(
      appId: appId ?? this.appId,
      name: name ?? this.name,
      framework: framework ?? this.framework,
      entryPath: entryPath ?? this.entryPath,
      mainComponent: mainComponent ?? this.mainComponent,
      params: params ?? this.params,
      deepLinks: deepLinks ?? this.deepLinks,
      supportedEvents: supportedEvents ?? this.supportedEvents,
    );
  }
}
