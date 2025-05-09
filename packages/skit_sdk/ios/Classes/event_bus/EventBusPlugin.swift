import Flutter
import UIKit
import CommonCrypto
import MedthodChannelConstants

public class EventBusPlugin: NSObject, FlutterPlugin {

    private var channel: FlutterMethodChannel?
    private var encryptionKey: String? = nil
    private var eventSink: FlutterEventSink?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: MethodChannelConstants.eventBusChannelName, binaryMessenger: registrar.messenger())
        let instance = EventBusPlugin()
        instance.channel = channel
        registrar.addMethodCallDelegate(instance, channel: channel)

        let eventChannel = FlutterEventChannel(name: MethodChannelConstants.eventBusStreamName, binaryMessenger: registrar.messenger())
        eventChannel.setStreamHandler(instance)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case MethodChannelConstants.EventBusMethods.dispatch:
            let type = (call.arguments as? [String: Any])?["type"] as? String ?? ""
            var data = (call.arguments as? [String: Any])?["data"] as? String ?? ""
            if let encryptionKey = encryptionKey {
                data = decrypt(encryptedData: data, encryptionKey: encryptionKey) ?? ""
            }
            let mapData = convertJsonToMap(jsonString: data)
            print("Event received from Flutter type : \(type) data: \(mapData)")

            // Handle the message here (e.g., update native UI)

            // Send a message to Flutter
            let nativeData = ["key": "value from native plugin"]
            let dataToSend: String
            if let encryptionKey = encryptionKey {
                dataToSend = encrypt(data: convertMapToJsonString(nativeData), encryptionKey: encryptionKey) ?? ""
            } else {
                dataToSend = convertMapToJsonString(nativeData)
            }
            channel?.invokeMethod(MethodChannelConstants.Methods.dispatch, arguments: ["type": "nativeData", "data": dataToSend])
            result(nil)
        case MethodChannelConstants.Methods.setEncryptionKey:
            encryptionKey = (call.arguments as? [String: Any])?["key"] as? String
            print("Encryption key set to: \(encryptionKey ?? "")")
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    /// Sends an event to the main app.
    ///
    /// - Parameters:
    ///   - eventType: The type of the event.
    ///   - eventData: The data associated with the event.
    public func sendEventToMainApp(eventType: String, eventData: [String: Any]) {
        guard let eventSink = eventSink else {
            print("EventSink is not available")
            return
        }
        eventSink(["type": eventType, "data": eventData])
    }
}

extension EventBusPlugin: FlutterStreamHandler {
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }
}