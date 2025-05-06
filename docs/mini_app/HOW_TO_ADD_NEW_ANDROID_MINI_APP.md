# How to Add an Android Native Mini App to the Main Flutter Application

This guide explains how to integrate an Android native mini app into your main Flutter application, covering creation, communication, registration, and launch processes.

## Creating the Android Native Mini App

1. **Create an Activity for your mini app**:

```kotlin
// MiniAppActivity.kt
package com.example.miniapp

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import android.widget.Button
import android.widget.TextView
import android.content.Intent

class MiniAppActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_mini_app)

        // Get parameters passed from Flutter
        val params = intent.extras
        
        // Set up UI elements
        val titleTextView = findViewById<TextView>(R.id.titleTextView)
        val completeButton = findViewById<Button>(R.id.completeButton)

        // Use parameters if available
        params?.let {
            val userId = it.getString("userId")
            val theme = it.getString("theme")
            titleTextView.text = "Welcome User: $userId"
            
            // Apply theme if specified
            if (theme == "dark") {
                // Apply dark theme styling
            }
        }

        // Set up complete button to return result to Flutter
        completeButton.setOnClickListener {
            // Create result Intent with data to return to Flutter
            val resultIntent = Intent().apply {
                putExtra("status", "success")
                putExtra("message", "Task completed from Android Native")
            }
            
            // Set result and finish activity
            setResult(RESULT_OK, resultIntent)
            finish()
        }
    }
}
```

2. **Create the layout for your mini app**:

```xml
<!-- res/layout/activity_mini_app.xml -->
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:orientation="vertical"
    android:gravity="center">

    <TextView
        android:id="@+id/titleTextView"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="Android Native Mini App"
        android:textSize="20sp"
        android:layout_marginBottom="20dp" />

    <Button
        android:id="@+id/completeButton"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="Complete Task" />
</LinearLayout>
```

3. **Add the activity to your AndroidManifest.xml**:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.miniapp">
    
    <application>
        <activity
            android:name=".MiniAppActivity"
            android:exported="false"
            android:theme="@style/AppTheme" />
    </application>
</manifest>
```

## Setting Up Communication

The communication bridge between Flutter and Android is already implemented in the `MiniAppPlugin.kt` file. This plugin handles launching Android native mini apps from Flutter.

To enhance the bridge for returning results to Flutter, modify the `MiniAppPlugin.kt` file:

```kotlin
// MiniAppPlugin.kt
// Add this method to launch the activity for result

private fun openApp(
    appId: String,
    params: Map<String, Any>,
    result: Result
) {
    val entryPath = params["entryPath"] as? String
    try {
        val intent = Intent(context, Class.forName(entryPath ?: appId))

        // Add parameters to the intent
        params.forEach { (key, value) ->
            when (value) {
                is String -> intent.putExtra(key, value)
                is Int -> intent.putExtra(key, value)
                is Boolean -> intent.putExtra(key, value)
                is Double -> intent.putExtra(key, value)
                else -> intent.putExtra(key, value.toString())
            }
        }

        // Start activity for result using ActivityResultLauncher
        if (activity != null) {
            // Set up result callback
            MiniAppBridge.getInstance().setResultCallback(result)
            activityResultLauncher.launch(intent)
        } else {
            // Fallback to regular startActivity if activity isn't available
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            context.startActivity(intent)
            result.success(null)
        }
    } catch (e: ClassNotFoundException) {
        result.error(
            "CLASS_NOT_FOUND",
            "Android activity class not found: $appId with entry path $entryPath",
            e.toString()
        )
    } catch (e: Exception) {
        result.error(
            "LAUNCH_FAILED",
            "Failed to launch Android mini app ($appId/$entryPath): ${e.message}",
            e.toString()
        )
    }
}
```

## Exporting the Mini App as a Library

1. **Configure your mini app project as a library**:

```gradle
// build.gradle
apply plugin: 'com.android.library'

android {
    compileSdkVersion 33
    
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 33
    }
    
    buildTypes {
        release {
            minifyEnabled false
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}

dependencies {
    implementation 'androidx.appcompat:appcompat:1.6.1'
    implementation 'com.google.android.material:material:1.9.0'
    // Add other dependencies as needed
}
```

2. **Build the library**:

```bash
./gradlew assembleRelease
```

The AAR file will be generated in the `build/outputs/aar/` directory.

3. **Add the library to your Flutter project**:

Create a `libs` directory in the `android/` folder of your Flutter project and copy the AAR file there.

4. **Update your Flutter project's settings.gradle**:

```gradle
// android/settings.gradle
include ':app', ':mini_app_library'
project(':mini_app_library').projectDir = new File(rootDir, 'libs/mini_app_library')
```

5. **Add the dependency to your app's build.gradle**:

```gradle
// android/app/build.gradle
dependencies {
    implementation project(':mini_app_library')
}
```

## Registering the Mini App in Flutter

Register the Android native mini app in your Flutter application:

```dart
// Register the mini app
await sdk.miniApp.registerMiniApp(
  MiniAppManifest(
    appId: 'android_payment_app',  // A unique identifier for the mini app
    name: 'Android Payment App',   // Display name
    framework: FrameworkType.native, // Specify that this is a native mini app
    entryPath: 'com.example.miniapp.MiniAppActivity', // Full class name of your activity
    params: {'theme': 'light'},    // Default parameters
  ),
);

// Optionally preload the mini app for better performance
await sdk.miniApp.preloadMiniApp('android_payment_app');
```

## Launching the Mini App

Launch the Android native mini app from your Flutter code:

```dart
Future<void> launchAndroidNativeMiniApp() async {
  try {
    final result = await sdk.miniApp.launch(
      'android_payment_app',
      params: {'userId': '12345', 'amount': '99.99'}
    );
    
    if (result != null) {
      print('Mini app returned data: $result');
      // Process the returned data
    }
  } catch (e) {
    print('Failed to launch mini app: $e');
    // Handle errors
  }
}
```

## Best Practices

1. **Implement a consistent interface** across all your mini apps:

```kotlin
// Consider creating a common base activity for mini apps
abstract class BaseMiniAppActivity : AppCompatActivity() {
    protected val params: Bundle?
        get() = intent.extras
    
    protected fun completeWithResult(resultData: Map<String, Any>) {
        val resultIntent = Intent()
        resultData.forEach { (key, value) ->
            when (value) {
                is String -> resultIntent.putExtra(key, value)
                is Int -> resultIntent.putExtra(key, value)
                is Boolean -> resultIntent.putExtra(key, value)
                is Double -> resultIntent.putExtra(key, value.toFloat())
                else -> resultIntent.putExtra(key, value.toString())
            }
        }
        setResult(RESULT_OK, resultIntent)
        finish()
    }
}
```

2. **Validate parameters** before using them:

```kotlin
val userId = params?.getString("userId") ?: run {
    // Handle missing parameter
    completeWithResult(mapOf("error" to "Missing userId parameter"))
    return
}
```

3. **Support multiple themes** for consistent UI:

```kotlin
// Apply theme based on parameter
val theme = params?.getString("theme") ?: "light"
if (theme == "dark") {
    setTheme(R.style.DarkTheme)
} else {
    setTheme(R.style.LightTheme)
}
```

4. **Handle activity lifecycle properly**:

```kotlin
override fun onDestroy() {
    super.onDestroy()
    // Clean up resources
}
```

## Troubleshooting

- **Mini app doesn't launch**: Verify the class name in `entryPath` is correct and the activity is properly declared in AndroidManifest.xml.

- **Parameters aren't received**: Check that parameters are correctly passed from Flutter and accessed in the activity.

- **Crashes on launch**: Verify the activity class path and ensure all required libraries are included.

- **UI issues**: Test on different Android versions and device sizes to ensure compatibility.

- **ClassNotFoundException**: Make sure the AAR file is correctly added and the class path is accurate.

- **Mini app closes without returning data**: Ensure the activity properly sets a result before finishing.

- **Memory leaks**: Check for retained references to activities or contexts in your mini app.

- **Permissions issues**: If your mini app requires specific permissions, make sure they're declared in the AndroidManifest.xml.

## References
- [Flutter Plugin Development](https://flutter.dev/docs/development/packages-and-plugins/developing-packages)
- [Android Activity Lifecycle](https://developer.android.com/guide/components/activities/activity-lifecycle)
- [Android Intents and Intent Filters](https://developer.android.com/guide/components/intents-filters)
- [Flutter Platform Channels](https://flutter.dev/docs/development/platform-integration/platform-channels)
- [Android Gradle Plugin](https://developer.android.com/studio/releases/gradle-plugin)
- [Android Library Projects](https://developer.android.com/studio/projects/android-library)
- [Android Manifest File](https://developer.android.com/guide/topics/manifest/manifest-intro)
- [Android UI Design Guidelines](https://developer.android.com/design)
- [Android Material Design](https://material.io/develop/android)