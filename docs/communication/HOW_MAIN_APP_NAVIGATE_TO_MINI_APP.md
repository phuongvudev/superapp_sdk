# Main App to Mini App Navigation

## Overview

This document outlines the navigation mechanisms between the Main App and Mini Apps, including the technical implementation, communication flow, and supported navigation patterns. The goal is to provide a comprehensive guide for developers to understand how to navigate to Mini Apps seamlessly, whether through deep links or programmatic calls.

## Why choose Deep Link Navigation?

### Seamless User Experience
- Deep links allow users to navigate directly to specific content within Mini Apps without going through multiple screens
- Enables quick access from external sources like notifications, emails, or other apps
- Creates a more intuitive and engaging way for users to interact with Mini Apps

### Technical Implementation
- Deep links use URI schemes (e.g., `miniapp://shopping_cart/checkout?id=123`) that include Mini App ID and parameters
- Mini App manifests define acceptable deep link patterns that the Main App can recognize
- The deep link dispatcher captures incoming links and matches them against registered patterns
- Parameters are extracted from URIs and passed to the Mini App launcher

### Flexibility and Robustness
- Supports various Mini App frameworks (Flutter, Web, Native) with framework-specific handling
- Modular approach allows easy addition of new Mini Apps without changing core navigation logic
- Includes built-in error handling, parameter validation, and fallback options
- Can be extended with pre-loading capabilities for improved performance

## Key Features
- **Deep Link Navigation**: Directly navigate to Mini Apps using URI schemes.
- **Programmatic Navigation**: Launch Mini Apps through method calls.
- **Framework Support**: Different navigation methods for various Mini App frameworks (Flutter, React Native, Web, Native).
- **Parameter Passing**: Support for passing parameters to Mini Apps via deep links or method calls.
- **Error Handling**: Robust error handling for navigation failures.
- **Pre-loading Mini Apps**: Preload Mini Apps for improved performance.
- **Best Practices**: Guidelines for defining deep links, validating parameters, and handling navigation failures.
- **Security Considerations**: Recommendations for validating deep links and sanitizing input parameters.
- **Navigation Lifecycle**: Overview of the steps involved in navigating to a Mini App.
- **Mini App Registry**: Centralized registry for Mini Apps, including their manifests and deep link patterns.

## Navigation Architecture

The Main App navigation to Mini Apps is built on a flexible architecture that supports multiple navigation methods:

```
┌──────────────────────────────────────────┐
│                MAIN APP                  │
│                                          │
│  ┌─────────────┐      ┌───────────────┐  │
│  │    SKit     │──────┤   EventBus    │  │
│  └──────┬──────┘      └───────────────┘  │
│         │                                │
│  ┌──────▼──────┐    ┌─────────────────┐  │
│  │ DeepLink    │    │  MiniApp        │  │
│  │ Dispatcher  │────┤  Launcher       │  │
│  └─────────────┘    └────────┬────────┘  │
└──────────────────────────────┬───────────┘
                               │
                  ┌────────────▼───────────┐
                  │    Mini App Registry   │
                  └────────────┬───────────┘
                               │
                       ┌───────▼────────┐
                       │    MINI APP    │
                       └────────────────┘
```

## Navigation Methods

### 1. Deep Link Navigation

Deep linking provides a powerful way to navigate directly to Mini Apps using URI schemes.

#### Implementation Flow

1. User or system triggers a deep link (e.g., `miniapp://app_id?param=value`)
2. `DeepLinkDispatcher` captures the link via `AppLinks`
3. The dispatcher matches the link against registered Mini App patterns
4. Parameters are extracted from the URI
5. `MiniAppKit` launches the appropriate Mini App with extracted parameters

```dart
// Example deep link structure
miniapp://<app_id>/<path>?param1=value1&param2=value2
```

#### Code Sample

```dart
// Handling deep links in Main App
void initializeDeepLinkHandling() {
  final deepLinkDispatcher = DeepLinkDispatcher(
    miniAppKit: miniAppKit,
  );
  
  // The dispatcher automatically registers for deep link events
  // and handles incoming links based on registered Mini App patterns
}
```

### 2. Programmatic Navigation

The Main App can directly navigate to Mini Apps through the `MiniAppKit`.

#### Implementation Flow

1. Main App code calls `MiniAppKit.launch()` with Mini App ID
2. Optional parameters are passed as a map
3. The launcher looks up the Mini App manifest from the registry
4. Based on the framework type, appropriate loading mechanism is used
5. The Mini App is launched with the provided parameters

#### Code Sample

```dart
// Navigating to a Mini App programmatically
Future<void> navigateToMiniApp(String appId, Map<String, dynamic> params) async {
  final miniAppWidget = await miniAppKit.launch(appId, params: params);
  if (miniAppWidget != null) {
    // For Flutter-based Mini Apps that return a widget
    Navigator.push(context, MaterialPageRoute(builder: (context) => miniAppWidget));
  }
  // For other types (web, native), launch() handles the navigation internally
}
```

## Mini App Framework Types and Navigation

The system supports various framework types with different navigation mechanisms:

### Flutter Mini Apps

- Direct widget integration into the Main App's widget tree
- Seamless navigation with shared Flutter context

### Web-Based Mini Apps (including Flutter Web)

- Loaded via web views
- Launched through platform-specific implementations
- Communication through JavaScript bridge

### Native Mini Apps

- Launched as separate activities/view controllers
- Communication through platform channels
- Independent UI but with shared data context

### React Native Mini Apps

- Custom integration through native modules
- Bridge for communication between React Native and Main App

## Mini App Registry and Discovery

```dart
// Mini App registration example
void registerMiniApp() {
  final manifest = MiniAppManifest(
    appId: 'shopping_cart',
    name: 'Shopping Cart',
    framework: FrameworkType.flutter,
    entryPath: 'packages/shopping_cart',
    deepLinks: ['cart://*', 'miniapp://shopping_cart/*'],
  );
  
  miniAppKit.registerMiniApp(manifest);
}
```

## Parameter Passing

Parameters can be passed to Mini Apps in two ways:

### Deep Link Parameters

- Extracted from query parameters in the URI
- Additional data can be encoded in path segments

```dart
// Example parameter extraction from deep links
Map<String, dynamic> _extractDeepLinkParameters(Uri uri) {
  final parameters = <String, dynamic>{};
  // Extract query parameters
  uri.queryParameters.forEach((key, value) {
    parameters[key] = value;
  });
  return parameters;
}
```

### Direct Parameter Passing

- Passed as a map during programmatic navigation
- Parameters are attached to the Mini App manifest

```dart
// Example of direct parameter passing
miniAppKit.launch(
  'shopping_cart',
  params: {
    'productId': '12345',
    'openCheckout': true,
  },
);
```

## Navigation Lifecycle

1. **Navigation Request**: From deep link or programmatic call
2. **Mini App Resolution**: Look up in the registry by ID or deep link pattern
3. **Preparation**: Optional preloading of resources
4. **Parameter Processing**: Extract and format navigation parameters
5. **Launch**: Framework-specific launch process
6. **Return Flow**: Return data from Mini App to Main App (if needed)

## Error Handling

The system includes robust error handling for navigation failures:

- `MiniAppNotFoundException`: When the requested Mini App is not found
- `UnsupportedFrameworkException`: When the framework is not supported
- General exception handling with fallback UI

```dart
try {
  await miniAppKit.launch(appId, params: params);
} catch (e) {
  // Handle navigation errors with appropriate UI feedback
  showErrorDialog("Failed to open the requested feature");
}
```

## Pre-loading Mini Apps

For improved performance, Mini Apps can be preloaded before navigation:

```dart
// Preload Mini Apps that might be needed soon
Future<void> preloadFrequentlyUsedMiniApps() async {
  await miniAppKit.preloadMiniApp('shopping_cart');
  await miniAppKit.preloadMiniApp('payment');
}
```

## Best Practices

1. **Define Clear Deep Link Patterns**: Use specific patterns for each Mini App
2. **Validate Parameters**: Ensure required parameters are provided
3. **Handle Navigation Failures**: Provide clear feedback on errors
4. **Use Preloading**: Preload frequently used Mini Apps for better performance
5. **Support Back Navigation**: Ensure proper back stack management

## Security Considerations

- Validate deep links before processing to prevent malicious links
- Sanitize input parameters to prevent injection attacks
- Consider adding authentication for sensitive Mini Apps

This document provides an overview of the navigation mechanisms between the Main App and Mini Apps, focusing on the technical implementation and patterns supported by the current architecture.
