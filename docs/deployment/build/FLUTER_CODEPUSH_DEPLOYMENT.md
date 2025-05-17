# CodePush Deployment via Shortbird for Flutter

This document provides a step-by-step guide to implement CodePush using Shortbird for a Flutter application.

---

## Prerequisites
- A Flutter project set up and ready for deployment.
- Shortbird account with access to CodePush services.
- Installed `flutter` and `dart` CLI tools.
- Installed `shortbird` CLI tool.

---

## Steps to Implement CodePush

### 1. **Install the Required Dependencies**
Add the `shortbird_flutter` package to your `pubspec.yaml` file:
```yaml
dependencies:
  shortbird_flutter: ^latest_version
```
Run the following command to fetch the package:
```bash
flutter pub get
```

---

### 2. **Configure Shortbird in Your Project**
Initialize Shortbird in your Flutter project by adding the following code to your `main.dart` file:
```dart
import 'package:shortbird_flutter/shortbird_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Shortbird.initialize(
    appId: 'your-app-id', // Replace with your Shortbird App ID
    apiKey: 'your-api-key', // Replace with your Shortbird API Key
  );

  runApp(MyApp());
}
```

---

### 3. **Set Up CodePush in Shortbird**
1. Log in to the [Shortbird Dashboard](https://shortbird.io/).
2. Create a new app or select an existing one.
3. Navigate to the **CodePush** section and generate a deployment key for your app.
4. Add the deployment key to your `main.dart` file:
   ```dart
   await Shortbird.setDeploymentKey('your-deployment-key');
   ```

---

### 4. **Release a CodePush Update**
1. Build the Flutter app bundle:
   ```bash
   flutter build appbundle
   ```
2. Use the `shortbird` CLI to release the update:
   ```bash
   shortbird codepush release --app-id your-app-id --bundle-path build/app/outputs/bundle/release/app-release.aab
   ```

---

### 5. **Check for Updates in the App**
Add the following code to check for and apply updates dynamically:
```dart
Shortbird.checkForUpdates().then((update) {
  if (update != null) {
    Shortbird.applyUpdate(update);
  }
});
```

---

## Best Practices
- Test updates thoroughly before releasing them to production.
- Use staging deployments for testing before rolling out to all users.
- Monitor update metrics in the Shortbird dashboard.

---

## Troubleshooting
- **Update Not Applied**: Ensure the deployment key matches the one in the Shortbird dashboard.
- **Build Errors**: Verify the `shortbird_flutter` package version compatibility with your Flutter SDK.
- **CLI Issues**: Update the `shortbird` CLI to the latest version.

For more details, refer to the official [Shortbird Documentation](https://docs.shorebird.dev/).