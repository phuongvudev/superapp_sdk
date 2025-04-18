import Flutter
import UIKit



public class CorePlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {

    // Register the CorePlugin
    let channel = FlutterMethodChannel(name: "core", binaryMessenger: registrar.messenger())
    let instance = CorePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)


    // Register the EventBusPluginSwift
    let eventBusInstance = EventBusPluginSwift()
    eventBusInstance.register(with: registrar)
    registrar.addMethodCallDelegate(eventBusInstance, channel: channel)

    // Register the MiniAppPlugin
    let miniAppInstance = MiniAppPlugin()
    miniAppInstance.register(with: registrar)
    registrar.addMethodCallDelegate(miniAppInstance, channel: channel)

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
