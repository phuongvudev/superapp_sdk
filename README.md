# SuperCoreAppSDK

## 📱 Overview

SuperCoreAppSDK is a comprehensive Flutter-based framework for building modular Super Apps with a Main App and Mini App architecture. It enables organizations to create a platform where multiple mini applications can coexist, share resources, and operate independently within a single host application.

## 🏗️ Architecture

The SuperCoreAppSDK follows a modular architecture consisting of:

### Main App (Host Platform)
- Acts as the container and runtime environment for mini apps
- Handles global navigation, authentication, and user management
- Provides shared services (payments, geolocation, etc.) to all mini apps
- Manages mini app lifecycle and communication

### Mini Apps
- Independently developed modules with focused functionality
- Can be built using different technologies:
    - **Flutter Mini Apps**: Native-like performance with Flutter UI
    - **Web Mini Apps**: HTML/CSS/JS applications in WebView
    - **React Native Mini Apps**: JavaScript-based applications
    - **Android Native Mini Apps**: Native Android components in Kotlin/Java
    - **iOS Native Mini Apps**: Native iOS components in Swift/Objective-C
- Dynamically loaded at runtime without main app updates
- Can be updated independently from the main application

## ✨ Key Features & Benefits

- **Modular Development**: Separate teams can work on different mini apps
- **Technology Flexibility**: Support for Flutter, Web, and React Native mini apps
- **Dynamic Updates**: Update mini apps without resubmitting the main app
- **Secure Communication**: Event Bus architecture for safe inter-app communication
- **Shared Resources**: Common services available across all mini apps
- **Independent Deployment**: Deploy mini apps on different schedules
- **Reduced App Size**: Users only download mini apps they need
- **Improved User Experience**: Seamless navigation between mini apps
- **Analytics & Monitoring**: Built-in support for user analytics and performance monitoring
- **Customizable UI**: Main app shell can be customized to match branding
- **Cross-Platform Support**: Works on iOS, Android, and Web

## 📥 Installation

Add the SuperCoreAppSDK to your `pubspec.yaml`:

```yaml
dependencies:
  skit_sdk: ^1.0.0
```

Run the following command:

```bash
flutter pub get
```

Configure your main app in `main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:super_core_app_sdk/super_core_app_sdk.dart';

void main() {
  SuperCoreAppSDK.initialize(
    appConfig: SuperAppConfig(
      appName: 'My Super App',
      miniAppRegistry: 'assets/mini_app_registry.json',
      enableAnalytics: true,
    ),
  );
  
  runApp(MyApp());
}
```

## 🚀 Usage Example

### Setting up the Main App

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Super App',
      home: SuperAppShell(
        appBar: AppBar(title: Text('My Super App')),
        navigationBuilder: (context) => SuperAppNavigation(),
        miniAppContainer: SuperMiniAppContainer(),
        onMiniAppLoaded: (miniApp) {
          print('Mini app ${miniApp.id} loaded successfully');
        },
        onMiniAppError: (miniApp, error) {
          print('Error loading ${miniApp.id}: $error');
        },
      ),
    );
  }
}
```

### Launching a Mini App

```dart
// Navigate to a mini app from the main app
SuperCoreAppSDK.navigateToMiniApp(
  context: context,
  miniAppId: 'wallet',
  params: {'initialView': 'dashboard'}
);

// Or use the navigation widget
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => MiniAppView(
      miniAppId: 'wallet',
      params: {'initialView': 'dashboard'},
    ),
  ),
);
```

## 🧩 Adding New Mini Apps

### 1. Create a Mini App Registry Entry

Add your mini app to the `mini_app_registry.json`:

```json
[
  {
    "id": "wallet",
    "name": "Wallet",
    "description": "Digital wallet for payments",
    "version": "1.0.0",
    "framework": "flutter",
    "entryPath": "https://cdn.example.com/wallet/v1.0.0/main.dart.js",
    "deepLinks": ["myapp://wallet", "myapp://wallet/:id"],
    "supportedEvents": ["onPaymentSuccess", "onPaymentFailure"]
  },
  {
    "id": "shopping",
    "name": "Shopping",
    "description": "Online shopping experience",
    "version": "1.2.1",
    "framework": "web",
    "entryPath": "https://mini-apps.example.com/shopping/index.html",
  }
]
```

### 2. Develop Your Mini App

For Flutter mini apps:

1. Create a new Flutter project
2. Add the Mini App SDK dependency
3. Implement the required interfaces

```dart
import 'package:super_core_mini_app_sdk/super_core_mini_app_sdk.dart';

class MyMiniApp extends MiniAppBase {
  @override
  Widget build(BuildContext context, Map<String, dynamic> params) {
    return MaterialApp(
      home: MyMiniAppHome(),
    );
  }
  
  @override
  void onLaunch(Map<String, dynamic> params) {
    // Handle mini app launch
  }
  
  @override
  void onMessage(MiniAppMessage message) {
    // Handle communication from main app
  }
}

void main() {
  MiniAppRunner.run(MyMiniApp());
}
```

### 3. Deploy Your Mini App

Deploy your mini app according to the framework:

- **Flutter**: Compile to JS and host on a CDN
- **Web**: Deploy HTML/JS/CSS to a web server
- **React Native**: Use CodePush or other dynamic update mechanisms

## 👥 Contributing

We welcome contributions to SuperCoreAppSDK! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

See our [CONTRIBUTING.md](CONTRIBUTING.md) file for detailed guidelines.

## 📄 License

SuperCoreAppSDK is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

For more detailed documentation, see our [docs](docs/) directory.