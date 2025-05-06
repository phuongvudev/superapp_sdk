# How to Add an iOS Native Mini App to the Main Flutter Application

This guide explains how to integrate an iOS native mini app into your Flutter application, covering everything from creating the mini app to launching it from Flutter.

## Creating the iOS Native Mini App

1. **Create a view controller for your mini app**:

```swift
// MiniAppViewController.swift
import UIKit

class MiniAppViewController: UIViewController {
    
    // Property to store parameters passed from Flutter
    var params: [String: Any]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        // Create UI elements
        let titleLabel = UILabel()
        titleLabel.text = "iOS Native Mini App"
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let actionButton = UIButton(type: .system)
        actionButton.setTitle("Complete Task", for: .normal)
        actionButton.addTarget(self, action: #selector(completeTask), for: .touchUpInside)
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Add views
        view.addSubview(titleLabel)
        view.addSubview(actionButton)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            
            actionButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            actionButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20)
        ])
        
        // Handle parameters
        if let params = params {
            print("Received parameters: \(params)")
        }
    }
    
    @objc private func completeTask() {
        // Return data to Flutter
        let result: [String: Any] = [
            "status": "success",
            "data": ["message": "Task completed from iOS Native"]
        ]
        
        // Use bridge to send result back to Flutter
        MiniAppBridge.shared.finishWithResult(result)
        
        // Dismiss the view controller
        dismiss(animated: true)
    }
}
```

## Setting Up the Communication Bridge

1. **Create a bridge class**:

```swift
// MiniAppBridge.swift
import Foundation

class MiniAppBridge {
    static let shared = MiniAppBridge()
    
    private var resultCallback: ((Any?) -> Void)?
    
    private init() {}
    
    func setResultCallback(_ callback: @escaping (Any?) -> Void) {
        self.resultCallback = callback
    }
    
    func finishWithResult(_ result: Any?) {
        resultCallback?(result)
        resultCallback = nil
    }
}
```

2. **Update the MiniAppPlugin class** to handle native mini apps:

```swift
// MiniAppPlugin.swift
import Flutter
import UIKit

public class MiniAppPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: MethodChannelConstants.miniAppChannelName, binaryMessenger: registrar.messenger())
        let instance = MiniAppPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case MethodChannelConstants.MiniAppMethods.openMiniApp:
            guard let args = call.arguments as? [String: Any],
                  let framework = args["framework"] as? String,
                  let appId = args["appId"] as? String,
                  let params = args["params"] as? [String: Any] else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments provided", details: nil))
                return
            }

            switch framework {
            case FrameworkType.native:
                openNativeMiniApp(appId: appId, params: params, result: result)
            case FrameworkType.web:
                openWebMiniApp(appId: appId, result: result)
            default:
                result(FlutterError(code: "INVALID_FRAMEWORK", message: "Unsupported framework: \(framework)", details: nil))
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func openNativeMiniApp(appId: String, params: [String: Any], result: @escaping FlutterResult) {
        // Find the class using the entry path
        let entryPath = params["entryPath"] as? String ?? ""

         guard let viewControllerClass = NSClassFromString(entryPath) as? UIViewController.Type else {
            result(FlutterError(code: "CLASS_NOT_FOUND", message: "View controller class not found: \(appId) with \(entryPath)", details: nil))
            return
        }
        
        // Create an instance of the view controller
        let viewController = viewControllerClass.init()
        
        // Pass parameters if the view controller can accept them
        if let miniAppVC = viewController as? MiniAppViewController {
            miniAppVC.params = params
        }
        
        // Set up the result callback
        MiniAppBridge.shared.setResultCallback(result)
        
        // Present the view controller
        DispatchQueue.main.async {
            UIApplication.shared.keyWindow?.rootViewController?.present(viewController, animated: true)
        }
    }

    private func openWebMiniApp(appId: String, result: @escaping FlutterResult) {
        if let url = URL(string: appId) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            result(nil)
        } else {
            result(FlutterError(code: "INVALID_URL", message: "Invalid URL: \(appId)", details: nil))
        }
    }
}
```

## Registering the Mini App

Register your iOS native mini app in your Flutter code:

```dart
// Register the mini app
await sdk.miniApp.registerMiniApp(
  MiniAppManifest(
    appId: 'payment_mini_app',
    name: 'iOS Payment App',
    framework: FrameworkType.native,
    entryPath: 'MiniAppViewController', // Full class name including module if needed
    params: {'theme': 'light'}, // Default parameters
  ),
);

// Optionally preload the mini app
await sdk.miniApp.preloadMiniApp('payment_mini_app');
```

## Launching the Mini App

Launch the iOS native mini app from your Flutter code:

```dart
Future<void> launchIOSNativeMiniApp() async {
  try {
    final result = await sdk.miniApp.launch(
      'payment_mini_app',
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

1. **Use protocols for consistency**:

```swift
protocol MiniAppViewControllerProtocol {
    var params: [String: Any]? { get set }
}

class MiniAppViewController: UIViewController, MiniAppViewControllerProtocol {
    var params: [String: Any]?
    // Implementation
}
```

2. **Handle lifecycle events properly**:

```swift
override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    
    if isBeingDismissed {
        // Send null result if being dismissed without explicit result
        MiniAppBridge.shared.finishWithResult(nil)
    }
}
```

3. **Validate parameters** before using them:

```swift
if let userId = params?["userId"] as? String {
    // Use userId
} else {
    // Handle missing parameter
    MiniAppBridge.shared.finishWithResult(["error": "Missing userId parameter"])
    dismiss(animated: true)
}
```

4. **Support navigation within mini apps**:

```swift
class NavigableMiniAppViewController: UINavigationController {
    var params: [String: Any]?
    
    convenience init(rootViewController: UIViewController & MiniAppViewControllerProtocol) {
        self.init(rootViewController: rootViewController)
        rootViewController.params = params
    }
}
```

5. **Support different UI modes** (light/dark theme):

```swift
override func viewDidLoad() {
    super.viewDidLoad()
    
    if let theme = params?["theme"] as? String, theme == "dark" {
        view.backgroundColor = .black
        // Configure other UI elements for dark theme
    } else {
        view.backgroundColor = .white
        // Configure UI elements for light theme
    }
}
```

## Troubleshooting

- **Mini app doesn't launch**: Ensure the class name in `entryPath` is correct and accessible. Check for namespace issues.

- **Parameters aren't received**: Verify your view controller correctly implements the parameter handling property.

- **No result returned to Flutter**: Check that `MiniAppBridge.shared.finishWithResult()` is called when your mini app completes its task.

- **Black screen after launch**: Make sure your view controller is setting up its UI correctly in `viewDidLoad`.

- **Mini app crashes**: Check for any initialization errors in your view controller and ensure proper error handling.

- **UI not displaying correctly**: Test on different iOS versions and devices to ensure compatibility.

- **Memory leaks**: Implement proper cleanup in `deinit` and when removing observers.