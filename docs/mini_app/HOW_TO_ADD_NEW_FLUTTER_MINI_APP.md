# How to Add a New Flutter Mini App

This guide explains how to create, integrate, and launch a Flutter mini app within your main application.

## Introduction

Flutter mini apps are modular Flutter applications that run within your main app. They provide:
- Code isolation and separation of concerns
- Independent development and testing
- Dynamic updates without requiring main app releases

## Creating a Flutter Mini App

### 1. Set up project structure

```
flutter_mini_app/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── bridge/
│   │   └── mini_app_bridge.dart
│   ├── screens/
│   │   └── home_screen.dart
│   └── models/
├── pubspec.yaml
├── assets/
└── README.md
```

### 2. Create the mini app entry point

```dart
// lib/app.dart
import 'package:flutter/material.dart';
import 'bridge/mini_app_bridge.dart';
import 'screens/home_screen.dart';

class MiniApp extends StatefulWidget {
   final Map<String, dynamic>? params;

   const MiniApp({Key? key, this.params}) : super(key: key);

   @override
   State<MiniApp> createState() => _MiniAppState();
}

class _MiniAppState extends State<MiniApp> {
   late MiniAppBridge _bridge;

   @override
   void initState() {
      super.initState();
      _bridge = MiniAppBridge();
      _bridge.initialize(widget.params ?? {});
   }

   @override
   Widget build(BuildContext context) {
      return MaterialApp(
         debugShowCheckedModeBanner: false,
         theme: ThemeData(
            primarySwatch: Colors.blue,
            useMaterial3: true,
         ),
         home: HomeScreen(bridge: _bridge),
      );
   }
}
```

### 3. Create the bridge for communication

```dart
// lib/bridge/mini_app_bridge.dart
class MiniAppBridge {
   Map<String, dynamic> _params = {};
   Function(Map<String, dynamic>)? _resultCallback;

   void initialize(Map<String, dynamic> params) {
      _params = params;
   }

   Map<String, dynamic> getParams() {
      return _params;
   }

   void setResultCallback(Function(Map<String, dynamic>) callback) {
      _resultCallback = callback;
   }

   void sendResult(Map<String, dynamic> result) {
      if (_resultCallback != null) {
         _resultCallback!(result);
      }
   }
}
```

### 4. Create the main home screen

```dart
// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../bridge/mini_app_bridge.dart';

class HomeScreen extends StatelessWidget {
   final MiniAppBridge bridge;

   const HomeScreen({Key? key, required this.bridge}) : super(key: key);

   @override
   Widget build(BuildContext context) {
      final params = bridge.getParams();

      return Scaffold(
         appBar: AppBar(
            title: Text('Flutter Mini App'),
         ),
         body: Center(
            child: Column(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                  Text('Parameters: ${params.toString()}'),
                  SizedBox(height: 20),
                  ElevatedButton(
                     onPressed: () {
                        bridge.sendResult({'status': 'success', 'data': 'Task completed'});
                        Navigator.pop(context);
                     },
                     child: Text('Complete Task'),
                  ),
               ],
            ),
         ),
      );
   }
}
```

## Setting Up Communication

To enable communication between the main app and mini app, implement the bridge mechanism:

### 1. In the main app

```dart
// Main app side
import 'package:flutter/material.dart';

class MiniAppHost extends StatefulWidget {
   final Widget miniApp;
   final Function(Map<String, dynamic>)? onResult;

   const MiniAppHost({
      Key? key,
      required this.miniApp,
      this.onResult,
   }) : super(key: key);

   @override
   State<MiniAppHost> createState() => _MiniAppHostState();
}

class _MiniAppHostState extends State<MiniAppHost> {
   @override
   Widget build(BuildContext context) {
      return widget.miniApp;
   }
}
```

### 2. Connect the bridge in mini app

```dart
// Inside mini app's main file
void connectBridge(Function(Map<String, dynamic>) onResult) {
   _bridge.setResultCallback((result) {
      onResult(result);
   });
}
```

## Registering the Mini App

Register your Flutter mini app with the SDK:

```dart
// In your main app
await sdk.miniApp.registerMiniApp(
  MiniAppManifest(
    appId: 'my_flutter_mini_app',
    name: 'My Flutter Mini App',
    framework: FrameworkType.flutter,
    entryPath: 'packages/my_flutter_mini_app/lib/main.dart',
    params: {'theme': 'light'}, // Default parameters
  ),
);

// Optionally preload to improve launch performance
await sdk.miniApp.preloadMiniApp('my_flutter_mini_app');
```

## Launching the Mini App

### Basic launch

```dart
Future<void> launchMiniApp() async {
   try {
      final widget = await sdk.miniApp.launch('my_flutter_mini_app');

      if (widget != null) {
         Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => widget),
         );
      }
   } catch (e) {
      print('Failed to launch mini app: $e');
   }
}
```

### Launching with parameters

```dart
final widget = await sdk.miniApp.launch(
  'my_flutter_mini_app',
  params: {
    'userId': 'user123',
    'amount': 99.99,
    'theme': 'dark',
  },
);

if (widget != null) {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => MiniAppHost(
        miniApp: widget,
        onResult: (result) {
          print('Mini app returned: $result');
          // Process result here
        },
      ),
    ),
  );
}
```

### Using deep links

```dart
// Set up deep link handling
final deepLinks = ['myapp://mini_app/profile/:id'];

await sdk.miniApp.registerMiniApp(
  MiniAppManifest(
    appId: 'my_flutter_mini_app',
    name: 'My Flutter Mini App',
    framework: FrameworkType.flutter,
    entryPath: 'packages/my_flutter_mini_app/lib/main.dart',
    deepLinks: deepLinks,
  ),
);

// Handle deep link in your main app
final uri = Uri.parse('myapp://mini_app/profile/123');
sdk.deepLink.handleDeepLink(uri);
```

## Complete Example

Here's a complete example of integrating a Flutter mini app:

```dart
// Main app code
import 'package:flutter/material.dart';
import 'package:core_sdk/core_sdk.dart';

class MainAppShell extends StatefulWidget {
   @override
   State<MainAppShell> createState() => _MainAppShellState();
}

class _MainAppShellState extends State<MainAppShell> {
   final sdk = SKit();
   String? _result;

   @override
   void initState() {
      super.initState();
      _initSDK();
   }

   Future<void> _initSDK() async {
      await sdk.initialize(
         config: {'apiKey': 'your_api_key'},
      );

      await sdk.miniApp.registerMiniApp(
         MiniAppManifest(
            appId: 'my_flutter_mini_app',
            name: 'My Flutter Mini App',
            framework: FrameworkType.flutter,
            entryPath: 'packages/my_flutter_mini_app/lib/main.dart',
         ),
      );

      // Preload for better performance
      await sdk.miniApp.preloadMiniApp('my_flutter_mini_app');
   }

   Future<void> _launchMiniApp() async {
      try {
         final widget = await sdk.miniApp.launch(
            'my_flutter_mini_app',
            params: {'userId': 'user123', 'timestamp': DateTime.now().toString()},
         );

         if (widget != null) {
            final result = await Navigator.push(
               context,
               MaterialPageRoute(
                  builder: (context) => MiniAppHost(
                     miniApp: widget,
                     onResult: (result) {
                        setState(() {
                           _result = result.toString();
                        });
                     },
                  ),
               ),
            );
         }
      } catch (e) {
         print('Failed to launch mini app: $e');
         // Handle error
      }
   }

   @override
   Widget build(BuildContext context) {
      return Scaffold(
         appBar: AppBar(title: Text('Mini App Launcher')),
         body: Center(
            child: Column(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                  ElevatedButton(
                     onPressed: _launchMiniApp,
                     child: Text('Launch Flutter Mini App'),
                  ),
                  if (_result != null)
                     Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text('Result: $_result'),
                     ),
               ],
            ),
         ),
      );
   }
}
```

## Best Practices

1. **Optimize performance**
   - Keep mini app packages lightweight
   - Use assets efficiently
   - Consider preloading for frequently used mini apps

2. **Follow design guidelines**
   - Support both light and dark themes
   - Use responsive layouts
   - Consider accessibility guidelines

3. **Handle state properly**
   - Use appropriate state management
   - Clean up resources when mini app is closed
   - Don't assume the mini app will stay in memory

4. **Communication**
   - Keep parameters simple and serializable
   - Handle communication errors gracefully
   - Don't rely on platform-specific features without checking availability

5. **Error handling**
   - Implement proper error boundaries
   - Log errors for debugging
   - Provide fallback UI for error states

6. **Version management**
   - Implement versioning for your mini apps
   - Ensure backward compatibility with the main app
   - Use semantic versioning for better tracking

## Troubleshooting

- **Mini app fails to load**: Verify the entry path is correct and the mini app is properly registered.

- **Parameters not received**: Check the parameter passing mechanism and ensure proper serialization.

- **Black screen or UI issues**: Check for theme conflicts or layout issues. Ensure all dependencies are compatible.

- **Communication issues**: Verify the bridge implementation and check for any missing callbacks.

- **Performance problems**: Profile the mini app to identify bottlenecks. Optimize asset loading and initialization.

- **Crashes on specific devices**: Test on multiple device configurations and implement proper error handling.

- **Memory leaks**: Ensure proper disposal of controllers, animations, and other resources when the mini app is closed.

## References

- [Flutter Documentation](https://docs.flutter.dev/)
- [Flutter Package Development](https://flutter.dev/docs/development/packages-and-plugins/developing-packages)
- [State Management in Flutter](https://flutter.dev/docs/development/data-and-backend/state-mgmt/intro)
- [Flutter Performance Best Practices](https://flutter.dev/docs/perf/rendering/best-practices)
- [Flutter Accessibility](https://flutter.dev/docs/development/accessibility-and-localization/accessibility)