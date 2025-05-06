# How to Add a Web Mini App to the Main Application

This guide explains how to integrate a web-based mini app into your main application using the SDK.

## Creating the Web Mini App

1. **Create a basic web application structure**:
   ```
   webapp/
   ├── index.html
   ├── css/
   │   └── styles.css
   ├── js/
   │   └── app.js
   └── assets/
       └── images/
   ```

2. **Implement your index.html with bridge functionality**:
   ```html
   <!DOCTYPE html>
   <html lang="en">
   <head>
     <meta charset="UTF-8">
     <meta name="viewport" content="width=device-width, initial-scale=1.0">
     <title>Web Mini App</title>
     <link rel="stylesheet" href="css/styles.css">
   </head>
   <body>
     <div id="app">
       <h1>Web Mini App</h1>
       <div id="params-display"></div>
       <button id="complete-btn">Complete Task</button>
     </div>
     
     <script src="js/app.js"></script>
   </body>
   </html>
   ```

3. **Create JavaScript with bridge functionality**:
   ```javascript
   // js/app.js
   document.addEventListener('DOMContentLoaded', () => {
     // Function to receive parameters from the main app
     function getParams() {
       try {
         // For Flutter web view
         if (window.flutter_inappwebview) {
           return JSON.parse(window.flutter_inappwebview.callHandler('getParams'));
         }
         // For native WebView
         else if (window.MiniAppBridge) {
           return window.MiniAppBridge.getParams();
         }
         // For development environment
         else {
           console.log("Bridge not detected, using mock parameters");
           return { userId: 'test123', theme: 'light' };
         }
       } catch (e) {
         console.error('Failed to get parameters:', e);
         return {};
       }
     }

     // Function to send results back to main app
     function sendResult(result) {
       try {
         // For Flutter web view
         if (window.flutter_inappwebview) {
           window.flutter_inappwebview.callHandler('sendResult', JSON.stringify(result));
         }
         // For native WebView
         else if (window.MiniAppBridge) {
           window.MiniAppBridge.sendResult(JSON.stringify(result));
         }
         else {
           console.log("Result to be sent:", result);
         }
       } catch (e) {
         console.error('Failed to send result:', e);
       }
     }

     // Function to close the mini app
     function close() {
       try {
         // For Flutter web view
         if (window.flutter_inappwebview) {
           window.flutter_inappwebview.callHandler('close');
         }
         // For native WebView
         else if (window.MiniAppBridge) {
           window.MiniAppBridge.close();
         }
       } catch (e) {
         console.error('Failed to close mini app:', e);
       }
     }

     // Initialize the app with parameters
     const params = getParams();
     const paramsDisplay = document.getElementById('params-display');
     paramsDisplay.textContent = `Parameters: ${JSON.stringify(params)}`;

     // Set up event listeners
     document.getElementById('complete-btn').addEventListener('click', () => {
       sendResult({
         status: 'success',
         message: 'Task completed from Web Mini App',
         timestamp: new Date().toISOString()
       });
       // Optional: close the mini app
       // close();
     });
   });
   ```

4. **Add some basic styling**:
   ```css
   /* css/styles.css */
   body {
     font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Open Sans', sans-serif;
     margin: 0;
     padding: 20px;
     background-color: #f5f5f5;
   }

   #app {
     max-width: 600px;
     margin: 0 auto;
     background-color: white;
     padding: 20px;
     border-radius: 8px;
     box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
   }

   h1 {
     color: #333;
   }

   #params-display {
     margin: 20px 0;
     padding: 10px;
     background-color: #f0f0f0;
     border-radius: 4px;
     word-break: break-all;
   }

   button {
     background-color: #4285f4;
     color: white;
     border: none;
     padding: 10px 16px;
     border-radius: 4px;
     font-size: 16px;
     cursor: pointer;
     transition: background-color 0.3s;
   }

   button:hover {
     background-color: #3367d6;
   }
   ```

## Hosting the Web Mini App

You have several options for hosting your web mini app:

1. **Bundled with the main app**:
   - Place your web files in the `assets/web` directory of your Flutter app
   - Access using the file path like `assets/web/mini_app_name/index.html`

2. **Remote server**:
   - Host on any web server (AWS S3, Firebase Hosting, GitHub Pages, etc.)
   - Access using a full URL like `https://your-domain.com/mini_app_name/`

3. **Content Delivery Network (CDN)**:
   - Deploy to a CDN for better performance
   - Access using the CDN URL

## Registering the Web Mini App

```dart
// Register a web mini app with the SDK
await sdk.miniApp.registerMiniApp(
  MiniAppManifest(
    appId: 'web_mini_app',
    name: 'Web Mini App',
    framework: FrameworkType.web,  // Use FrameworkType.web for standard web apps
    entryPath: 'https://your-domain.com/mini_app_name/', // Or 'assets/web/mini_app_name/index.html' for bundled apps
    params: {'theme': 'light', 'userId': 'user123'},
    deepLinks: ['myapp://web_mini_app'], // Optional deep links
  ),
);

// Optional preloading for better performance
await sdk.miniApp.preloadMiniApp('web_mini_app');
```

For a Flutter Web mini app:

```dart
await sdk.miniApp.registerMiniApp(
  MiniAppManifest(
    appId: 'flutter_web_mini_app',
    name: 'Flutter Web Mini App',
    framework: FrameworkType.flutterWeb,
    entryPath: 'https://your-domain.com/flutter_web_mini_app/',
    params: {'theme': 'light', 'userId': 'user123'},
  ),
);
```

## Launching the Mini App

```dart
Future<void> launchWebMiniApp() async {
  try {
    final result = await sdk.miniApp.launch('web_mini_app', params: {
      'currentDate': DateTime.now().toIso8601String(),
      'customParam': 'valueFromHost',
    });
    
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

## Supporting Deep Links

1. **Register deep links when defining the mini app**:
   ```dart
   MiniAppManifest(
     // Other parameters...
     deepLinks: ['myapp://web_mini_app', 'myapp://web_mini_app/:id'],
   )
   ```

2. **Handle deep links in your web mini app**:
   ```javascript
   // In your app.js file
   function handleDeepLink() {
     // For Flutter web view
     if (window.flutter_inappwebview) {
       const deepLink = window.flutter_inappwebview.callHandler('getDeepLink');
       processDeepLink(deepLink);
     }
     // For native WebView
     else if (window.MiniAppBridge) {
       const deepLink = window.MiniAppBridge.getDeepLink();
       processDeepLink(deepLink);
     }
   }

   function processDeepLink(deepLink) {
     if (deepLink) {
       console.log('Processing deep link:', deepLink);
       // Your deep link handling logic here
     }
   }

   // Call when page loads
   handleDeepLink();
   ```

## Best Practices

1. **Responsive Design**
   - Design your web mini app to work on all screen sizes
   - Use responsive CSS and media queries

2. **Offline Support**
   - Consider implementing service workers for offline capability
   - Cache essential resources

3. **Bridge Communication**
   - Keep bridge methods simple and consistent
   - Handle errors gracefully if bridge is not available

4. **Performance**
   - Minimize asset sizes (compress images, minify JS/CSS)
   - Avoid heavy frameworks if not needed
   - Consider lazy loading for non-critical resources

5. **Security**
   - Follow content security policy best practices
   - Validate all data received from the bridge
   - Use HTTPS for remotely hosted mini apps

6. **Versioning**
   - Include version information in your mini app
   - Consider a strategy for updates

7. **Testing**
   - Test in both development and production environments
   - Test with various parameter combinations
   - Test offline behavior

## Troubleshooting

- **Mini app fails to load**: Verify the entry path is correct and accessible
- **Bridge communication issues**: Check for JavaScript errors in the browser console
- **Parameters not being received**: Ensure params are properly passed and JSON-serializable
- **Rendering issues**: Test on different device sizes and browsers
- **Mixed content warnings**: Ensure all resources use HTTPS if the main app uses HTTPS
- **Slow loading**: Check network requests, consider preloading, and optimize asset sizes
- **JavaScript errors**: Look for errors in the console and check for compatibility issues

## References
- [WebView Flutter Documentation](https://pub.dev/packages/webview_flutter)
- [InAppWebView Flutter Documentation](https://pub.dev/packages/flutter_inappwebview)
- [Web Content Optimization](https://web.dev/fast/)
- [Progressive Web Apps](https://web.dev/progressive-web-apps/)
- [JavaScript Bridge Communication](https://developer.android.com/develop/ui/views/layout/webapps/webview#UsingJavaScript)