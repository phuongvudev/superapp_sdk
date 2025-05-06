# How to Add a Mini App to an Existing Application

This guide explains how to implement a mini app within your main application and how to launch it properly.

## Contents
- [Introduction](#introduction)
- [Setup](#setup)
- [Creating a Mini App](#creating-a-mini-app)
- [Registering a Mini App](#registering-a-mini-app)
- [Launching a Mini App](#launching-a-mini-app)
- [Complete Example](#complete-example)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)

## Introduction

Mini apps are lightweight applications that run within a host (main) application. They provide:
- Modular feature development
- Dynamic updates without main app releases
- Feature isolation and separation of concerns

## Setup

Initialize the SDK in your main application:

```dart
// Get reference to the SDK
final sdk = SKit();

// Initialize the SDK with configuration
await sdk.initialize(
  config: {'apiKey': 'your_api_key'},
  optionalConfig: SDKOptionalConfig(
    encryptor: AESEncryptor('your_encryption_key'),
    miniAppRegistry: CustomMiniAppRepository(), // Optional
    miniAppPreLoaders: {
      FrameworkType.flutter: FlutterPreloader(),
    },
  ),
);
```

## Creating a Mini App

Define your mini app using the `MiniAppManifest` class:

```dart
final miniAppManifest = MiniAppManifest(
  appId: 'payment_mini_app',
  name: 'Payment Service',
  framework: FrameworkType.flutter, // Or other supported framework
  entryPath: 'assets/mini_apps/payment',
  mainComponent: 'PaymentFlow',
  params: {'theme': 'light'},
  deepLinks: ['myapp://payment/*'],
);
```

## Registering a Mini App

Register your mini app with the SDK:

```dart
// Register the mini app
await sdk.miniApp.registerMiniApp(miniAppManifest);

// For preloading (optional - improves launch performance)
await sdk.miniApp.preloadMiniApp('payment_mini_app');
```

## Launching a Mini App

There are several ways to launch a mini app:

### Direct Launch

```dart
final widget = await sdk.miniApp.launch('payment_mini_app');

if (widget != null) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => widget),
  );
}
```

### With Parameters

```dart
final widget = await sdk.miniApp.launch(
  'payment_mini_app',
  params: {'amount': '100.00', 'currency': 'USD'}
);
```

### Using Event Bus

```dart
// In the main app
sdk.eventBus.dispatch(
  Event('openMiniApp', {'appId': 'payment_mini_app'})
);

// Set up listener in your app initialization
sdk.eventBus.on('openMiniApp', (data) {
  final appId = data['appId'];
  sdk.miniApp.launch(appId).then((widget) {
    if (widget != null) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => widget));
    }
  });
});
```

### Using Deep Links

```dart
// Configure deep link handling in your main app
final uri = Uri.parse('myapp://payment/checkout?amount=99.99');
sdk.deepLink.handleDeepLink(uri);
```

## Complete Example

Here's a complete example showing how to integrate and launch a mini app:

```dart
import 'package:flutter/material.dart';
import 'package:core/core.dart';

class MainApp extends StatefulWidget {
  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final SKit sdk = SKit();
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initializeSDK();
  }

  Future<void> _initializeSDK() async {
    await sdk.initialize(
      config: {'apiKey': 'your_api_key'},
    );

    // Register mini app
    await sdk.miniApp.registerMiniApp(
      MiniAppManifest(
        appId: 'payment_mini_app',
        name: 'Payment Service',
        framework: FrameworkType.flutter,
        entryPath: 'assets/mini_apps/payment',
      ),
    );

    setState(() {
      _initialized = true;
    });
  }

  void _openPaymentMiniApp() async {
    if (!_initialized) return;

    final widget = await sdk.miniApp.launch(
      'payment_mini_app',
      params: {'amount': '100.00'}
    );

    if (widget != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => widget),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Main App')),
      body: Center(
        child: ElevatedButton(
          onPressed: _openPaymentMiniApp,
          child: Text('Open Payment Mini App'),
        ),
      ),
    );
  }
}
```

## Best Practices

1. **Preload frequently used mini apps**:
   ```dart
   await sdk.miniApp.preloadMiniApp('payment_mini_app');
   ```

2. **Handle errors gracefully**:
   ```dart
   try {
     final widget = await sdk.miniApp.launch('payment_mini_app');
     // Handle widget
   } catch (e) {
     print('Failed to launch mini app: $e');
     // Show fallback UI
   }
   ```

3. **Implement proper versioning** for mini apps to ensure compatibility.

4. **Use deep linking** for seamless navigation between main app and mini apps.

5. **Consider security** by using the provided encryption capabilities for sensitive data.

6. **Customize mini app registry** if you need special storage handling:
   ```dart
   class CustomMiniAppRepository implements MiniAppManifestRepository {
     // Custom implementation
   }
   ```

## Troubleshooting

- If the mini app fails to load, verify the entry path is correct.
- Ensure the framework type matches the mini app implementation.
- Check logs for any errors during the launch process.
- Verify the mini app is properly registered before attempting to launch.
- For native platform issues, check that method channel implementations are working correctly.
- If using encrypted communication, ensure encryption keys match between components.
- When launching web mini apps, verify that the proper method channel is available.