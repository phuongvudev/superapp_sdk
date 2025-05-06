# How to Add a React Native Mini App to the Main Application

This guide explains how to integrate a React Native mini app into your main application, treating it as a native app within the SDK.

## Creating the React Native Mini App

1. **Create a new React Native project**:
   ```bash
   npx react-native init ReactNativeMiniApp
   ```

2. **Implement your React Native mini app functionality**:
   ```javascript
   // App.js
   import React from 'react';
   import {NativeModules, Button, View, Text} from 'react-native';

   const {MiniAppBridge} = NativeModules;

   const App = () => {
     const completeTask = () => {
       MiniAppBridge.finishWithResult({
         status: 'success',
         data: {message: 'Task completed from React Native'}
       });
     };

     return (
       <View style={{flex: 1, justifyContent: 'center', alignItems: 'center'}}>
         <Text>React Native Mini App</Text>
         <Button title="Complete Task" onPress={completeTask} />
       </View>
     );
   };

   export default App;
   ```

## Creating the Native Bridge

1. **Create a bridge module in your React Native project**:
   ```kotlin
   // android/app/src/main/java/com/reactnativeminiapp/MiniAppBridgeModule.kt
   package com.reactnativeminiapp

   import com.facebook.react.bridge.ReactApplicationContext
   import com.facebook.react.bridge.ReactContextBaseJavaModule
   import com.facebook.react.bridge.ReactMethod
   import com.facebook.react.bridge.ReadableMap

   class MiniAppBridgeModule(reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext) {
       
       override fun getName(): String {
           return "MiniAppBridge"
       }

       @ReactMethod
       fun finishWithResult(result: ReadableMap) {
           resultCallback?.let {
               it.onResult(result.toHashMap())
               resultCallback = null
           }
       }

       companion object {
           private var resultCallback: ResultCallback? = null

           fun setResultCallback(callback: ResultCallback) {
               resultCallback = callback
           }
       }

       interface ResultCallback {
           fun onResult(result: Any?)
       }
   }
   ```

2. **Register the bridge module**:
   ```kotlin
   // android/app/src/main/java/com/reactnativeminiapp/MiniAppPackage.kt
   package com.reactnativeminiapp

   import com.facebook.react.ReactPackage
   import com.facebook.react.bridge.NativeModule
   import com.facebook.react.bridge.ReactApplicationContext
   import com.facebook.react.uimanager.ViewManager

   class MiniAppPackage : ReactPackage {
       
       override fun createNativeModules(reactContext: ReactApplicationContext): List<NativeModule> {
           return listOf(MiniAppBridgeModule(reactContext))
       }

       override fun createViewManagers(reactContext: ReactApplicationContext): List<ViewManager<*, *>> {
           return emptyList()
       }
   }
   ```

## Configuring as a Library

1. **Modify `android/build.gradle`**:
   ```gradle
   buildscript {
       // Keep existing build script configuration
   }
   
   apply plugin: 'com.android.library'  // Changed from 'com.android.application'
   ```

2. **Update `android/app/build.gradle`**:
   ```gradle
   android {
       compileSdkVersion 33
       
       defaultConfig {
           // Remove applicationId since libraries don't have one
           minSdkVersion 21
           targetSdkVersion 33
       }
   }
   ```

3. **Create an activity to host the React Native component**:
   ```kotlin
   // android/app/src/main/java/com/reactnativeminiapp/ReactNativeMiniAppActivity.kt
   package com.reactnativeminiapp

   import android.os.Bundle
   import com.facebook.react.ReactActivity
   import com.facebook.react.ReactActivityDelegate
   import com.facebook.react.defaults.DefaultNewArchitectureEntryPoint
   import com.facebook.react.defaults.DefaultReactActivityDelegate

   class ReactNativeMiniAppActivity : ReactActivity() {
       
       override fun getMainComponentName(): String {
           return "ReactNativeMiniApp"
       }

       override fun createReactActivityDelegate(): ReactActivityDelegate {
           return DefaultReactActivityDelegate(
               this,
               mainComponentName,
               DefaultNewArchitectureEntryPoint.getFabricEnabled()
           )
       }

       override fun onCreate(savedInstanceState: Bundle?) {
           super.onCreate(savedInstanceState)
           // Get parameters from intent if needed
           val params = intent.getBundleExtra("params")
       }
   }
   ```

## Building the React Native Mini App

1. **Bundle the React Native code**:
   ```bash
   npx react-native bundle --platform android --dev false --entry-file index.js --bundle-output android/app/src/main/assets/index.android.bundle --assets-dest android/app/src/main/res/
   ```

2. **Build the AAR library**:
   ```bash
   cd android && ./gradlew clean assembleRelease
   ```

3. **Locate the AAR file** in `android/app/build/outputs/aar/app-release.aar`

## Integrating into the Main App

1. **Add the AAR to the main app**:
   - Create a `libs` directory in your main app's Android project
   - Copy the AAR file into this directory

2. **Update the main app's `settings.gradle`**:
   ```gradle
   include ':reactNativeMiniApp'
   project(':reactNativeMiniApp').projectDir = new File('libs/reactNativeMiniApp')
   ```

3. **Add the dependency in the main app's `app/build.gradle`**:
   ```gradle
   dependencies {
       implementation project(':reactNativeMiniApp')
       implementation "com.facebook.react:react-native:+" // Add React Native dependency
   }
   ```

## Registering the React Native Mini App

```dart
// Register the React Native mini app with the SDK
await sdk.miniApp.registerMiniApp(
MiniAppManifest(
appId: 'react_native_mini_app',
name: 'React Native Mini App',
framework: FrameworkType.reactNative,
entryPath: 'com.reactnativeminiapp.ReactNativeMiniAppActivity',
params: {'theme': 'light'},
),
);

// Optional preloading for better performance
await sdk.miniApp.preloadMiniApp('react_native_mini_app');
```

## Launching the Mini App

```dart
Future<void> launchReactNativeMiniApp() async {
   try {
      final result = await sdk.miniApp.launch('react_native_mini_app');
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

## Best Practices

1. **Bundle JS files with the AAR** to ensure they're available when needed
2. **Design a robust communication bridge** between React Native and the main app
3. **Handle lifecycle events properly** to prevent memory leaks
4. **Implement proper error handling** in both JavaScript and native code
5. **Use versioning** to manage compatibility between the main app and mini app
6. **Preload frequently used mini apps** to improve user experience

## Troubleshooting

- **Mini app fails to launch**: Verify the entry path is correct and points to your React Native activity
- **Bridge communication issues**: Ensure the bridge module is properly registered
- **Black screen after launch**: Check that JS bundle is correctly included in the assets
- **Missing React Native dependencies**: Verify all dependencies are included in the main app
- **Crashes on certain devices**: Test on multiple API levels and screen sizes
- **Performance issues**: Consider enabling Hermes JavaScript engine for better performance