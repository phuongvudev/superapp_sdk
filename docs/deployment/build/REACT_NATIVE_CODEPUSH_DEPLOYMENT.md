# CodePush Deployment for React Native

This document provides a step-by-step guide to implement CodePush for a React Native application.

---

## Prerequisites
- A React Native project set up and ready for deployment.
- Installed `react-native-code-push` package.
- Access to the App Center account for managing CodePush deployments.
- Installed `appcenter-cli` tool.

---

## Steps to Implement CodePush

### 1. **Install the Required Dependencies**
Install the `react-native-code-push` package:
```bash
npm install react-native-code-push
```
Link the package to your project:
```bash
npx react-native link react-native-code-push
```

---

### 2. **Configure CodePush in Your Project**
Modify the `MainApplication.java` file (for Android) or `AppDelegate.m` file (for iOS) to include CodePush.

#### Android (`android/app/src/main/java/.../MainApplication.java`):
Add the following import:
```java
import com.microsoft.codepush.react.CodePush;
```
Override the `getJSBundleFile` method:
```java
@Override
protected String getJSBundleFile() {
    return CodePush.getJSBundleFile();
}
```
Add the CodePush instance in the `getPackages` method:
```java
new CodePush(BuildConfig.CODEPUSH_KEY, getApplicationContext(), BuildConfig.DEBUG)
```

#### iOS (`ios/<YourApp>/AppDelegate.m`):
Add the following import:
```objective-c
#import <CodePush/CodePush.h>
```
Modify the `jsCodeLocation` to use CodePush:
```objective-c
jsCodeLocation = [CodePush bundleURL];
```

---

### 3. **Set Up App Center**
1. Log in to [App Center](https://appcenter.ms/).
2. Create a new app for your React Native project.
3. Navigate to the **CodePush** section and generate deployment keys for `Staging` and `Production`.

---

### 4. **Add Deployment Keys**
Add the deployment keys to your `android/app/build.gradle` and `ios/Info.plist` files.

#### Android (`android/app/build.gradle`):
Add the following to the `buildTypes` section:
```gradle
buildConfigField "String", "CODEPUSH_KEY", '"your-deployment-key"'
```

#### iOS (`ios/Info.plist`):
Add the following entry:
```xml
<key>CodePushDeploymentKey</key>
<string>your-deployment-key</string>
```

---

### 5. **Release a CodePush Update**
1. Bundle the JavaScript code:
   ```bash
   npx react-native bundle --platform android --dev false --entry-file index.js --bundle-output ./build/index.android.bundle --assets-dest ./build
   ```
2. Use the `appcenter-cli` to release the update:
   ```bash
   appcenter codepush release-react -a <owner-name>/<app-name> -d Staging
   ```

---

### 6. **Check for Updates in the App**
Add the following code to check for and apply updates dynamically:
```javascript
import CodePush from "react-native-code-push";

class App extends React.Component {
  render() {
    return <YourApp />;
  }
}

export default CodePush({
  checkFrequency: CodePush.CheckFrequency.ON_APP_START,
})(App);
```

---

## Best Practices
- Test updates in the `Staging` environment before releasing to `Production`.
- Monitor update metrics in the App Center dashboard.
- Use rollback functionality if issues are detected.

---

## Troubleshooting
- **Update Not Applied**: Ensure the deployment key matches the one in App Center.
- **Build Errors**: Verify the `react-native-code-push` package version compatibility with your React Native version.
- **CLI Issues**: Update the `appcenter-cli` to the latest version.

For more details, refer to the official [CodePush Documentation](https://microsoft.github.io/code-push/).