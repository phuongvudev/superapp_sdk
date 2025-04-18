package com.superapp_sdk.event_bus

import android.annotation.TargetApi
import android.os.Build
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import android.util.Log
import com.superapp_sdk.constants.MethodChannelConstants
import org.json.JSONObject
import java.util.Base64
import javax.crypto.Cipher
import javax.crypto.spec.IvParameterSpec
import javax.crypto.spec.SecretKeySpec

/**
 * A Flutter plugin for handling event bus communication between Flutter and native Android.
 * This plugin supports encrypted data transmission and event dispatching.
 */
class EventBusPlugin : FlutterPlugin, MethodCallHandler {
    /// The MethodChannel for communication between Flutter and native Android.
    private lateinit var channel: MethodChannel
    private var encryptionKey: String? = null

    /**
     * Called when the plugin is attached to the Flutter engine.
     * Sets up the MethodChannel for communication.
     */
    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, MethodChannelConstants.METHOD_CHANNEL_EVENT_BUS)
        channel.setMethodCallHandler(this)
    }

    /**
     * Handles method calls from Flutter.
     * Supported methods:
     * - "dispatch": Dispatches an event from Flutter to native Android.
     * - "setEncryptionKey": Sets the encryption key for secure communication.
     */
    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "dispatch" -> {
                val type = call.argument<String>("type") ?: ""
                var data = call.argument<String>("data") ?: ""
                if (encryptionKey != null) {
                    data = decrypt(data, encryptionKey!!)
                }
                val mapData = convertJsonToMap(data)
                Log.d("EventBusPlugin", "Event received from Flutter. Type: $type, Data: $mapData")

                // Example: Handle the event or update native UI here.

                // Send a response back to Flutter.
                val nativeData = mapOf("key" to "value from native plugin")
                val dataToSend = if (encryptionKey != null) {
                    encrypt(JSONObject(nativeData).toString(), encryptionKey!!)
                } else {
                    JSONObject(nativeData).toString()
                }
                channel.invokeMethod("dispatch", mapOf("type" to "nativeData", "data" to dataToSend))
                result.success(null)
            }
            "setEncryptionKey" -> {
                encryptionKey = call.argument<String>("key")
                Log.d("EventBusPlugin", "Encryption key set: $encryptionKey")
                result.success(null)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    /**
     * Converts a JSON string to a Map.
     * @param jsonString The JSON string to convert.
     * @return A Map representation of the JSON data.
     */
    private fun convertJsonToMap(jsonString: String): Map<String, Any> {
        val map = mutableMapOf<String, Any>()
        val jsonObject = JSONObject(jsonString)
        val keys = jsonObject.keys()
        while (keys.hasNext()) {
            val key = keys.next()
            val value = jsonObject.get(key)
            map[key] = value
        }
        return map
    }

    /**
     * Encrypts a string using AES encryption.
     * @param data The data to encrypt.
     * @param encryptionKey The encryption key.
     * @return The encrypted string in Base64 format.
     */
    @TargetApi(Build.VERSION_CODES.O)
    private fun encrypt(data: String, encryptionKey: String): String {
        val key = SecretKeySpec(encryptionKey.toByteArray(Charsets.UTF_8), "AES")
        val iv = IvParameterSpec(ByteArray(16)) // Fixed IV for simplicity.
        val cipher = Cipher.getInstance("AES/CBC/PKCS5Padding")
        cipher.init(Cipher.ENCRYPT_MODE, key, iv)
        val encryptedBytes = cipher.doFinal(data.toByteArray(Charsets.UTF_8))
        return Base64.getEncoder().encodeToString(encryptedBytes)
    }

    /**
     * Decrypts a Base64-encoded string using AES decryption.
     * @param encryptedData The encrypted data in Base64 format.
     * @param encryptionKey The encryption key.
     * @return The decrypted string.
     */
    @TargetApi(Build.VERSION_CODES.O)
    private fun decrypt(encryptedData: String, encryptionKey: String): String {
        val key = SecretKeySpec(encryptionKey.toByteArray(Charsets.UTF_8), "AES")
        val iv = IvParameterSpec(ByteArray(16)) // Fixed IV for simplicity.
        val cipher = Cipher.getInstance("AES/CBC/PKCS5Padding")
        cipher.init(Cipher.DECRYPT_MODE, key, iv)
        val decryptedBytes = cipher.doFinal(Base64.getDecoder().decode(encryptedData))
        return String(decryptedBytes, Charsets.UTF_8)
    }

    /**
     * Called when the plugin is detached from the Flutter engine.
     * Cleans up the MethodChannel.
     */
    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}