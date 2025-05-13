import Flutter
import UIKit



public class CorePlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {

    // Register the CorePlugin
    let channel = FlutterMethodChannel(name: "core", binaryMessenger: registrar.messenger())
    let instance = CorePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)


    // Register the EventBusPluginSwift
    EventBusPlugin.register(with: registrar)

    // Register the MiniAppPlugin
    MiniAppPlugin.register(with: registrar)

  }



  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
