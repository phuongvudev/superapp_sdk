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
   import React, {useEffect} from 'react';
   import {NativeModules, Button, View, Text} from 'react-native';

   const {MiniAppBridge} = NativeModules;

   const App = () => {
     // Access parameters passed from Flutter
     useEffect(() => {
       const params = MiniAppBridge.getParams();
       console.log('Received params:', params);
     }, []);

     const completeTask = () => {
       MiniAppBridge.sendResult({
         status: 'success',
         message: 'Task completed from React Native'
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

## Creating the Native Bridge Module

1. **Create a bridge module in your React Native project**:
   ```kotlin
   // android/app/src/main/java/com/reactnativeminiapp/MiniAppBridgeModule.kt
   package com.reactnativeminiapp

   import com.facebook.react.bridge.ReactApplicationContext
   import com.facebook.react.bridge.ReactContextBaseJavaModule
   import com.facebook.react.bridge.ReactMethod
   import com.facebook.react.bridge.ReadableMap
   import com.facebook.react.bridge.WritableNativeMap
   import com.superapp_sdk.mini_app.MiniAppBridge

   class MiniAppBridgeModule(reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext) {
       private val params = WritableNativeMap()
       
       override fun getName(): String {
           return "MiniAppBridge"
       }

       fun setParams(intentParams: Bundle?) {
           intentParams?.let {
               for (key in it.keySet()) {
                   val value = it.get(key)
                   when (value) {
                       is String -> params.putString(key, value)
                       is Int -> params.putInt(key, value)
                       is Boolean -> params.putBoolean(key, value)
                       is Double -> params.putDouble(key, value)
                   }
               }
           }
       }

       @ReactMethod(isBlockingSynchronousMethod = true)
       fun getParams(): ReadableMap {
           return params
       }

       @ReactMethod
       fun sendResult(result: ReadableMap) {
           val resultMap = result.toHashMap()
           MiniAppBridge.getInstance().sendResult(resultMap as Map<String, Any?>)
           // Close the activity
           currentActivity?.finish()
       }

       @ReactMethod
       fun sendError(errorCode: String, errorMessage: String) {
           MiniAppBridge.getInstance().sendError(errorCode, errorMessage)
           // Close the activity
           currentActivity?.finish()
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
   import com.superapp_sdk.mini_app.MiniAppBridge

   class ReactNativeMiniAppActivity : ReactActivity() {
       private lateinit var bridgeModule: MiniAppBridgeModule
       
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
           
           // Get parameters from intent
           val params = intent.extras
           
           // Initialize the bridge module and pass the parameters
           val reactInstanceManager = reactInstanceManager
           val reactContext = reactInstanceManager.currentReactContext
           
           if (reactContext != null) {
               bridgeModule = reactContext.getNativeModule(MiniAppBridgeModule::class.java)
               bridgeModule.setParams(params)
           } else {
               // Initialize when React context is ready
               reactInstanceManager.addReactInstanceEventListener { context ->
                   bridgeModule = context.getNativeModule(MiniAppBridgeModule::class.java)
                   bridgeModule.setParams(params)
               }
           }
       }
   }
   ```

## Building the React Native Mini App

1. **Bundle the React Native code**:
   ```bash
   npx react-native bundle --platform android --dev false --entry-file index.js --bundle-output android/app/src/main/assets/index.android.bundle --assets-dest android/app/src/main/res/
   ```

2. **Make sure to create the assets directory if it doesn't exist**:
   ```bash
   mkdir -p android/app/src/main/assets
   ```

3. **Build the AAR library**:
   ```bash
   cd android && ./gradlew clean assembleRelease
   ```

4. **Locate the AAR file** in `android/app/build/outputs/aar/app-release.aar`

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

4. **Add React Native dependencies to the main app's `android/app/build.gradle`**:
   ```gradle
   dependencies {
       // Existing dependencies
       
       // React Native dependencies
       implementation "com.facebook.react:react-native:+"
       implementation "androidx.swiperefreshlayout:swiperefreshlayout:1.1.0"
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
    params: {'theme': 'light', 'userId': 'user123'},
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
2. **Design a clean communication interface** between React Native and the main app using the `MiniAppBridge`
3. **Handle lifecycle events properly** to prevent memory leaks
4. **Implement proper error handling** in both JavaScript and native code
5. **Use versioning** to manage compatibility between the main app and mini app
6. **Preload frequently used mini apps** to improve user experience
7. **Pass only serializable data** through the bridge

## Troubleshooting

- **Mini app fails to launch**: Verify the entry path is correct and points to your React Native activity
- **Bridge communication issues**: Ensure the bridge module is properly registered and initialized
- **Black screen after launch**: Check that JS bundle is correctly included in the assets directory
- **Missing React Native dependencies**: Verify all dependencies are included in the main app
- **Parameter passing not working**: Check that parameters are correctly passed from Flutter to native and then to React Native
- **Performance issues**: Consider enabling Hermes JavaScript engine for better performance
- **Bridge not receiving results**: Ensure that `MiniAppBridge.getInstance()` is correctly initialized before use

## References
- [React Native Documentation](https://reactnative.dev/docs/getting-started)
- [React Native Bridge Documentation](https://reactnative.dev/docs/native-modules-android)
- [Android Library Documentation](https://developer.android.com/studio/build/library)
- [Integration With Existing Apps](https://reactnative.dev/docs/integration-with-existing-apps)