# Dynamic App Icons with Flutter

This guide explains how to implement dynamic app icons in iOS and Android applications built with Flutter.

## Overview

Dynamic app icons allow your application to change its home screen icon programmatically. This feature can be used for:
- Theming options
- Seasonal variations
- User customization
- Feature highlighting

## iOS Implementation

iOS natively supports alternate app icons since iOS 10.3 through the `setAlternateIconName` API.

### Configuration

1. Add your alternate icons to your asset catalog or app bundle
2. Configure `Info.plist` with the following:

```xml
<key>CFBundleIcons</key>
<dict>
    <key>CFBundlePrimaryIcon</key>
    <dict>
        <key>CFBundleIconFiles</key>
        <array>
            <string>AppIcon</string>
        </array>
        <key>UIPrerenderedIcon</key>
        <false/>
    </dict>
    <key>CFBundleAlternateIcons</key>
    <dict>
        <key>dark-icon</key>
        <dict>
            <key>CFBundleIconFiles</key>
            <array>
                <string>dark-icon</string>
            </array>
            <key>UIPrerenderedIcon</key>
            <false/>
        </dict>
        <key>holiday-icon</key>
        <dict>
            <key>CFBundleIconFiles</key>
            <array>
                <string>holiday-icon</string>
            </array>
            <key>UIPrerenderedIcon</key>
            <false/>
        </dict>
    </dict>
</dict>
```

3. For each alternate icon, provide images in the required sizes:
    - 120x120px (@2x for iPhone/iPad)
    - 180x180px (@3x for iPhone)

### Flutter Implementation

Use platform channels to access the native APIs:

```dart
import 'dart:io';
import 'package:flutter/services.dart';

class DynamicIconManager {
  static const platform = MethodChannel('app/dynamic_icon');
  
  static Future<bool> changeAppIcon(String iconName) async {
    if (!Platform.isIOS) return false;
    
    try {
      final bool result = await platform.invokeMethod('changeAppIcon', {
        'iconName': iconName,
      });
      return result;
    } on PlatformException catch (e) {
      print("Failed to change app icon: '${e.message}'");
      return false;
    }
  }
  
  static Future<bool> resetAppIcon() async {
    return changeAppIcon(null); // null resets to default icon
  }
}
```

iOS native code (Swift):

```swift
@objc func changeAppIcon(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
  guard let args = call.arguments as? [String: Any],
        let iconName = args["iconName"] as? String? else {
    result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
    return
  }
  
  if !UIApplication.shared.supportsAlternateIcons {
    result(FlutterError(code: "UNSUPPORTED", message: "Device does not support alternate icons", details: nil))
    return
  }
  
  UIApplication.shared.setAlternateIconName(iconName) { error in
    if let error = error {
      result(FlutterError(code: "FAILED", message: error.localizedDescription, details: nil))
    } else {
      result(true)
    }
  }
}
```

## Android Implementation

Android doesn't natively support changing the app icon, but we can use activity aliases to achieve similar functionality.

### Configuration

1. Add alternate icons to your `res/mipmap` directories
2. Configure your `AndroidManifest.xml` with activity aliases:

```xml
<manifest ...>
    <application ...>
        <!-- Default activity -->
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:enabled="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
        
        <!-- Dark icon alias -->
        <activity-alias
            android:name=".MainActivity.DarkIcon"
            android:enabled="false"
            android:icon="@mipmap/ic_launcher_dark"
            android:roundIcon="@mipmap/ic_launcher_dark_round"
            android:targetActivity=".MainActivity">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity-alias>
        
        <!-- Holiday icon alias -->
        <activity-alias
            android:name=".MainActivity.HolidayIcon"
            android:enabled="false"
            android:icon="@mipmap/ic_launcher_holiday"
            android:roundIcon="@mipmap/ic_launcher_holiday_round"
            android:targetActivity=".MainActivity">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity-alias>
    </application>
</manifest>
```

### Flutter Implementation

Create a platform channel implementation:

```dart
Future<bool> changeAppIcon(String iconName) async {
  if (!Platform.isAndroid) return false;
  
  try {
    final bool result = await platform.invokeMethod('changeAppIcon', {
      'iconName': iconName,
    });
    return result;
  } on PlatformException catch (e) {
    print("Failed to change app icon: '${e.message}'");
    return false;
  }
}
```

Android native code (Kotlin):

```kotlin
private fun changeAppIcon(iconName: String?): Boolean {
  val packageManager = activity.packageManager
  val componentName = when (iconName) {
    "dark" -> ComponentName(activity, "com.example.app.MainActivity.DarkIcon")
    "holiday" -> ComponentName(activity, "com.example.app.MainActivity.HolidayIcon")
    else -> ComponentName(activity, "com.example.app.MainActivity")
  }
  
  // Disable all activity-alias components first
  packageManager.setComponentEnabledSetting(
    ComponentName(activity, "com.example.app.MainActivity"), 
    PackageManager.COMPONENT_ENABLED_STATE_DISABLED, 
    PackageManager.DONT_KILL_APP
  )
  packageManager.setComponentEnabledSetting(
    ComponentName(activity, "com.example.app.MainActivity.DarkIcon"), 
    PackageManager.COMPONENT_ENABLED_STATE_DISABLED, 
    PackageManager.DONT_KILL_APP
  )
  packageManager.setComponentEnabledSetting(
    ComponentName(activity, "com.example.app.MainActivity.HolidayIcon"), 
    PackageManager.COMPONENT_ENABLED_STATE_DISABLED, 
    PackageManager.DONT_KILL_APP
  )
  
  // Enable the selected component
  packageManager.setComponentEnabledSetting(
    componentName,
    PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
    PackageManager.DONT_KILL_APP
  )
  
  return true
}
```

## Complete Flutter Implementation

Here's a complete implementation using a Flutter package:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_dynamic_icons/flutter_dynamic_icons.dart';

class IconSelectionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select App Icon')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => DynamicIconManager.changeAppIcon(null),
              child: Text('Default Icon'),
            ),
            ElevatedButton(
              onPressed: () => DynamicIconManager.changeAppIcon('dark-icon'),
              child: Text('Dark Icon'),
            ),
            ElevatedButton(
              onPressed: () => DynamicIconManager.changeAppIcon('holiday-icon'),
              child: Text('Holiday Icon'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Limitations

### iOS
- Cannot change app icon without user confirmation dialog
- Limited to predefined alternate icons
- Requires iOS 10.3+

### Android
- Slower icon change process (may take minutes to appear)
- May not work consistently across all devices/launchers
- Icon cache issues may require app restart or device reboot

## Best Practices

1. **Maintain consistent branding**: Alternate icons should still be recognizable
2. **Test on multiple devices**: Icon appearance varies across launchers
3. **Handle failures gracefully**: Icon changes can fail for various reasons
4. **Inform users**: Let users know the icon change might not be immediate
5. **Provide feedback**: Confirm when icon changes are successful

## Troubleshooting

### Icon not changing on Android
- Clear launcher cache and restart
- Some launchers may not support dynamic icons
- Try rebooting the device

### iOS permissions issues
- Ensure Info.plist is correctly configured
- Verify icon assets are in the correct location and format

### Icon appears distorted
- Ensure all required sizes are provided
- Follow platform-specific design guidelines

## Alternative Packages

If direct implementation is too complex, consider these Flutter packages:
- `flutter_launcher_icons`: For static icon generation
- `dynamic_app_icon`: Cross-platform dynamic icon support
- `flutter_app_badger`: For adding notification badges (alternative to changing the whole icon)