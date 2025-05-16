# How the Main App Handles Deep Links

This document explains the architecture and implementation of deep link handling in the Main App, focusing on how deep links are processed and used to navigate to Mini Apps.

---

## Overview

Deep linking allows the Main App to navigate directly to specific Mini Apps or features using URI schemes. The system captures, validates, and processes deep links to ensure seamless navigation.

---

## Deep Link Handling Flow

1. **Trigger**: A deep link is triggered (e.g., `miniapp://app_id?param=value`).
2. **Capture**: The `DeepLink` class captures the link using `AppLinks` or platform-specific deep link listeners.
3. **Validation**: The deep link is validated against registered patterns in the Mini App Registry.
4. **Parameter Extraction**: Query parameters and path segments are extracted from the URI.
5. **Navigation**: The appropriate Mini App is launched using the `MiniAppKit`.

---

## Implementation

### Deep Link Structure

A typical deep link follows this structure:

```
miniapp://<app_id>/<path>?param1=value1&param2=value2
```

### Code Example: Deep Link Initialization

```dart
// Initialize deep link handling in the Main App
void initializeDeepLinkHandling() {
  final deepLink = DeepLink(
    miniAppKit: miniAppKit,
  );

  // Automatically register for deep link events
  deepLink.registerListener((Uri uri) {
    final appId = uri.host;
    final params = _extractDeepLinkParameters(uri);

    // Launch the Mini App
    miniAppKit.launch(appId, params: params);
  });
}

// Extract query parameters from a deep link URI
Map<String, dynamic> _extractDeepLinkParameters(Uri uri) {
  final parameters = <String, dynamic>{};
  uri.queryParameters.forEach((key, value) {
    parameters[key] = value;
  });
  return parameters;
}
```

---

## Mini App Registry Integration

The Mini App Registry stores deep link patterns for all registered Mini Apps. During deep link handling, the dispatcher matches the incoming URI against these patterns.

### Example: Registering a Mini App

```dart
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

---

## Error Handling

The system includes robust error handling for invalid or unsupported deep links:

- **Invalid Deep Link**: If the URI does not match any registered pattern, an error is logged, and fallback UI is shown.
- **Missing Parameters**: If required parameters are missing, the user is notified with an error message.

### Example: Handling Errors

```dart
try {
  await miniAppKit.launch(appId, params: params);
} catch (e) {
  showErrorDialog("Failed to open the requested feature");
}
```

---

## Best Practices

1. **Define Clear Patterns**: Use specific and unique patterns for each Mini App.
2. **Validate Input**: Ensure all required parameters are present and sanitized.
3. **Fallback UI**: Provide user-friendly feedback for invalid or unsupported deep links.
4. **Centralized Registry**: Maintain a centralized Mini App Registry for managing deep link patterns.

---

## Security Considerations

- Validate deep links to prevent malicious links.
- Sanitize input parameters to avoid injection attacks.
- Add authentication for sensitive Mini Apps.

This document provides a comprehensive guide to implementing and managing deep link handling in the Main App.