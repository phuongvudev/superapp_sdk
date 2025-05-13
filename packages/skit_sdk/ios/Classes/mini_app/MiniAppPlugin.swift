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
