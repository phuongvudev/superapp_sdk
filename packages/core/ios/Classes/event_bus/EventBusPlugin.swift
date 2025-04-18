import Flutter
import UIKit
import CommonCrypto
import MedthodChannelConstants


public class EventBusPluginSwift: NSObject, FlutterPlugin {

    private var channel: FlutterMethodChannel?
    private var encryptionKey: String? = nil

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: MethodChannelConstants.eventBusChannelName, binaryMessenger: registrar.messenger())
        let instance = EventBusPluginSwift()
        instance.channel = channel
        registrar.addMethodCallDelegate(instance, channel: channel)
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
    private func encrypt(data: String, encryptionKey: String) -> String? {
        guard let keyData = encryptionKey.data(using: .utf8),
              let dataData = data.data(using: .utf8) else {
            return nil
        }
        let keyBytes = [UInt8](keyData)
        let dataBytes = [UInt8](dataData)

        let keyLength = kCCKeySizeAES256
        guard keyBytes.count >= keyLength else {
            print("Encryption key must be at least 32 bytes (256 bits) long.")
            return nil
        }

        let ivSize = kCCBlockSizeAES128
        var ivBytes = [UInt8](repeating: 0, count: ivSize)
        let dataLength = dataBytes.count
        let bufferSize = dataLength + ivSize
        var buffer = [UInt8](repeating: 0, count: bufferSize)

        var numBytesEncrypted: Int = 0
        let cryptStatus = CCCrypt(CCOperation(kCCEncrypt),
                                  CCAlgorithm(kCCAlgorithmAES128),
                                  CCOptions(kCCOptionPKCS7Padding),
                                  keyBytes, keyLength,
                                  &ivBytes,
                                  dataBytes, dataLength,
                                  &buffer, bufferSize,
                                  &numBytesEncrypted)

        guard cryptStatus == kCCSuccess else {
            print("Encryption failed with status: \(cryptStatus)")
            return nil
        }

        let encryptedData = Data(bytes: buffer, count: numBytesEncrypted)
        return encryptedData.base64EncodedString()
    }

    private func decrypt(encryptedData: String, encryptionKey: String) -> String? {
           guard let keyData = encryptionKey.data(using: .utf8),
                   let data = Data(base64Encoded: encryptedData) else {
               return nil
           }

           let keyBytes = [UInt8](keyData)
           let dataBytes = [UInt8](data)

           let keyLength = kCCKeySizeAES256
           guard keyBytes.count >= keyLength else {
               print("Decryption key must be at least 32 bytes (256 bits) long.")
               return nil
           }

           let ivSize = kCCBlockSizeAES128
           var ivBytes = [UInt8](repeating: 0, count: ivSize)
           let dataLength = dataBytes.count
           let bufferSize = dataLength + ivSize
           var buffer = [UInt8](repeating: 0, count: bufferSize)

           var numBytesDecrypted: Int = 0
           let cryptStatus = CCCrypt(CCOperation(kCCDecrypt),
                                     CCAlgorithm(kCCAlgorithmAES128),
                                     CCOptions(kCCOptionPKCS7Padding),
                                     keyBytes, keyLength,
                                     &ivBytes,
                                     dataBytes, dataLength,
                                     &buffer, bufferSize,
                                     &numBytesDecrypted)

           guard cryptStatus == kCCSuccess else {
               print("Decryption failed with status: \(cryptStatus)")
               return nil
           }

           return String(bytes: buffer, encoding: .utf8)
       }

    private func convertJsonToMap(jsonString: String) -> [String: Any]? {
        guard let data = jsonString.data(using: .utf8) else { return nil }
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        } catch {
            print("Error converting JSON to map: \(error)")
            return nil
        }
    }

    private func convertMapToJsonString(_ map: [String: Any]) -> String {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: map, options: [])
            return String(data: jsonData, encoding: .utf8) ?? ""
        } catch {
            print("Error converting map to JSON string: \(error)")
            return ""
        }
    }
}