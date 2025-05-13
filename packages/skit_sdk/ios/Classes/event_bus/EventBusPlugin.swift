import Flutter
import UIKit
import CommonCrypto

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
            channel?.invokeMethod(MethodChannelConstants.EventBusMethods.dispatch, arguments: ["type": "nativeData", "data": dataToSend])
            result(nil)
        case MethodChannelConstants.EventBusMethods.setEncryptionKey:
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

    private func encrypt(data: String, encryptionKey: String) -> String? {
        guard let dataToEncrypt = data.data(using: .utf8),
              let keyData = encryptionKey.data(using: .utf8) else {
            return nil
        }

        let keyLength = kCCKeySizeAES256
        var key = Data(count: keyLength)
        let actualKeyLength = min(keyData.count, keyLength)

        keyData.copyBytes(to: &key, count: actualKeyLength)

        let ivSize = kCCBlockSizeAES128
        var iv = Data(count: ivSize)
        let result = iv.withUnsafeMutableBytes { ivBytes in
            SecRandomCopyBytes(kSecRandomDefault, ivSize, ivBytes.baseAddress!)
        }

        if result != errSecSuccess {
            return nil
        }

        let bufferSize = dataToEncrypt.count + kCCBlockSizeAES128
        var buffer = Data(count: bufferSize)
        var numBytesEncrypted = 0

        let cryptStatus = key.withUnsafeBytes { keyBytes in
            dataToEncrypt.withUnsafeBytes { dataBytes in
                iv.withUnsafeBytes { ivBytes in
                    buffer.withUnsafeMutableBytes { bufferBytes in
                        CCCrypt(
                            CCOperation(kCCEncrypt),
                            CCAlgorithm(kCCAlgorithmAES),
                            CCOptions(kCCOptionPKCS7Padding),
                            keyBytes.baseAddress, keyLength,
                            ivBytes.baseAddress,
                            dataBytes.baseAddress, dataToEncrypt.count,
                            bufferBytes.baseAddress, bufferSize,
                            &numBytesEncrypted
                        )
                    }
                }
            }
        }

        if cryptStatus == CCCryptorStatus(kCCSuccess) {
            buffer.count = numBytesEncrypted
            let ivAndEncryptedData = iv + buffer
            return ivAndEncryptedData.base64EncodedString()
        }

        return nil
    }

    private func decrypt(encryptedData: String, encryptionKey: String) -> String? {
        guard let encryptedDataWithIV = Data(base64Encoded: encryptedData),
              let keyData = encryptionKey.data(using: .utf8) else {
            return nil
        }

        let keyLength = kCCKeySizeAES256
        var key = Data(count: keyLength)
        let actualKeyLength = min(keyData.count, keyLength)

        keyData.copyBytes(to: &key, count: actualKeyLength)

        let ivSize = kCCBlockSizeAES128
        let iv = encryptedDataWithIV.prefix(ivSize)
        let encryptedBytes = encryptedDataWithIV.suffix(from: ivSize)

        let bufferSize = encryptedBytes.count + kCCBlockSizeAES128
        var buffer = Data(count: bufferSize)
        var numBytesDecrypted = 0

        let cryptStatus = key.withUnsafeBytes { keyBytes in
            encryptedBytes.withUnsafeBytes { encryptedBytesPointer in
                iv.withUnsafeBytes { ivBytes in
                    buffer.withUnsafeMutableBytes { bufferBytes in
                        CCCrypt(
                            CCOperation(kCCDecrypt),
                            CCAlgorithm(kCCAlgorithmAES),
                            CCOptions(kCCOptionPKCS7Padding),
                            keyBytes.baseAddress, keyLength,
                            ivBytes.baseAddress,
                            encryptedBytesPointer.baseAddress, encryptedBytes.count,
                            bufferBytes.baseAddress, bufferSize,
                            &numBytesDecrypted
                        )
                    }
                }
            }
        }

        if cryptStatus == CCCryptorStatus(kCCSuccess) {
            buffer.count = numBytesDecrypted
            return String(data: buffer, encoding: .utf8)
        }

        return nil
    }

    private func convertJsonToMap(jsonString: String) -> [String: Any] {
        guard let data = jsonString.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
              let map = jsonObject as? [String: Any] else {
            return [:]
        }
        return map
    }

    private func convertMapToJsonString(_ map: [String: Any]) -> String {
        guard let data = try? JSONSerialization.data(withJSONObject: map, options: []),
              let jsonString = String(data: data, encoding: .utf8) else {
            return "{}"
        }
        return jsonString
    }
}
