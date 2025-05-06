# How to Add an Android Native Mini App to the Main Flutter Application

This guide explains how to integrate an Android native mini app into a Flutter-based main application. The Android native mini app should be exported as a library and registered in the Flutter main app.

---

## Exporting the Android Native Mini App as a Library

1. **Configure the Android native mini app as a library**:
   - Update the `build.gradle` file of the mini app:
     ```gradle
     apply plugin: 'com.android.library'

     android {
         compileSdkVersion 33
         defaultConfig {
             minSdkVersion 21
             targetSdkVersion 33
         }
     }
     ```

2. **Build the library**:
   - Run the following command to generate the `.aar` file:
     ```bash
     ./gradlew assembleRelease
     ```
   - The `.aar` file will be located in the `build/outputs/aar/` directory.

3. **Add the `.aar` file to the Flutter project**:
   - Place the `.aar` file in the `android/libs` directory of the Flutter project.
   - Update the `settings.gradle` file in the Flutter project:
     ```gradle
     include ':androidMiniApp'
     project(':androidMiniApp').projectDir = new File('libs/androidMiniApp')
     ```

4. **Add the dependency in the `app/build.gradle`**:
   ```gradle
   implementation project(':androidMiniApp')
   ```

---

## Registering the Mini App in Flutter

1. **Define the mini app manifest**:
   Use the `MiniAppManifest` class to register the Android native mini app in the Flutter main app:
   ```dart
   await sdk.miniApp.registerMiniApp(
     MiniAppManifest(
       appId: 'android_native_mini_app',
       name: 'Android Native Mini App',
       framework: FrameworkType.native,
       entryPath: 'com.example.miniapp.MainActivity',
       params: {'theme': 'dark'},
     ),
   );
   ```

---

## Launching the Mini App

Use the `sdk.miniApp.launch` method to launch the Android native mini app from Flutter:

```dart
Future<void> launchAndroidMiniApp() async {
   try {
      final result = await sdk.miniApp.launch('android_native_mini_app');
      if (result != null) {
         print('Mini app returned data: $result');
      } else {
         print('Mini app launched successfully with no return data.');
      }
   } catch (e) {
      print('Failed to launch mini app: $e');
   }
}
```

---

## Best Practices

1. **Export the mini app as a library** to simplify integration.
2. **Preload frequently used mini apps**:
   ```dart
   await sdk.miniApp.preloadMiniApp('android_native_mini_app');
   ```
3. **Handle errors gracefully** during communication and launching.
4. **Use versioning** to ensure compatibility between the main app and mini apps.

---

## Troubleshooting

- Verify the `.aar` file is correctly added to the Flutter project.
- Ensure the `sdk.miniApp` methods are properly implemented in the Flutter app.
- Check logs for errors during initialization or launch.
- Confirm the mini app is registered before launching.
