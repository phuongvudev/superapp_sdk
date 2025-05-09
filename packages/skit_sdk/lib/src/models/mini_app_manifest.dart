import 'package:flutter/widgets.dart';
import 'package:skit_sdk/src/constants/framework_type.dart';

/// Type definition for widget builders
typedef WidgetBuilder = Widget? Function(Map<String, dynamic> params);

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

  /// Information about the mini app, such as its version or description.
  /// This is typically used for display purposes.
  /// This field is optional and can be null.
  final String? description;

  /// Optional path to the app icon. Can be used to display the icon in the UI.
  /// This is typically a URL or a local asset path.
  final String? appIcon;

  /// Framework type used by the mini app (e.g., Flutter, React Native).
  final FrameworkType framework;

  /// Path to the entry point of the mini app.
  /// This is typically the main file or component that initializes the app.
  /// With Flutter, using MiniAppWidgetRegistry for registering the main widget is recommended.
  final String entryPath;

  /// Optional name of the main component for the mini app.
  final String? mainComponent;

  /// Optional parameters for the mini app.
  final Map<String, dynamic>? params;

  /// Optional deep links the mini app can handle.
  final List<String>? deepLinks;

  /// Optional list of supported events for the mini app.
  final List<String>? supportedEvents;

  /// Optional builder function for creating the main widget of the mini app.
  /// This is used for Flutter mini apps to register the main widget.
  final WidgetBuilder? appBuilder;

  /// Creates a new instance of `MiniAppManifest`.
  ///
  /// [appId] - The unique identifier for the mini app.
  /// [name] - The display name of the mini app.
  /// [framework] - The framework type used by the mini app.
  /// [entryPath] - The path to the entry point of the mini app.
  /// [mainComponent] - The optional name of the main component.
  /// [deepLinks] - The optional list of deep links the mini app can handle.
  /// [params] - The optional parameters for the mini app.
  /// [supportedEvents] - The optional list of supported events.
  /// [appBuilder] - The optional builder function for creating the main widget.
  /// [description] - The optional description of the mini app.
  /// [appIcon] - The optional path to the app icon.
  MiniAppManifest({
    required this.appId,
    required this.name,
    required this.framework,
    required this.entryPath,
    this.mainComponent,
    this.params,
    this.deepLinks,
    this.supportedEvents,
    this.appBuilder,
    this.description,
    this.appIcon,
  })  : assert(appId.isNotEmpty, 'appId cannot be empty'),
        assert(name.isNotEmpty, 'name cannot be empty'),
        assert(entryPath.isNotEmpty, 'entryPath cannot be empty'),
        assert(
            framework != FrameworkType.unknown, 'framework cannot be unknown'),
        assert(framework == FrameworkType.flutter && appBuilder == null,
            'builder cannot be null when framework is Flutter');

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
        'description': description,
        'appIcon': appIcon,
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
      description: json['description'],
      appIcon: json['appIcon'],
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
    WidgetBuilder? appBuilder,
    String? description,
    String? appIcon,
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
      appBuilder: appBuilder ?? this.appBuilder,
      description: description ?? this.description,
      appIcon: appIcon ?? this.appIcon,
    );
  }
}
