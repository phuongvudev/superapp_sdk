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


class EventBusPlugin: FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel : MethodChannel
    private var encryptionKey: String? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, MethodChannelConstants.METHOD_CHANNEL_EVENT_BUS)
        channel.setMethodCallHandler(this)
    }
    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "dispatch" -> {
                val type = call.argument<String>("type") ?: ""
                var data = call.argument<String>("data") ?: ""
                if (encryptionKey != null) {
                    data = decrypt(data, encryptionKey!!)
                }
                val mapData = convertJsonToMap(data)
                Log.d("MyEventBusPlugin", "Event received from Flutter type : $type data: $mapData")
                // Handle the message here (e.g., update native UI)
                // Send a message to Flutter
                val nativeData = mapOf("key" to "value from native plugin")
                val dataToSend = if(encryptionKey != null) encrypt(JSONObject(nativeData).toString(), encryptionKey!!) else JSONObject(nativeData).toString()
                channel.invokeMethod("dispatch", mapOf("type" to "nativeData", "data" to dataToSend))
                result.success(null)
            }
            "setEncryptionKey" -> {
                encryptionKey = call.argument<String>("key")
                Log.d("MyEventBusPlugin", "encryptionKey received : $encryptionKey")
                result.success(null)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

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

    @TargetApi(Build.VERSION_CODES.O)
    private fun encrypt(data: String, encryptionKey: String): String {
        val key = SecretKeySpec(encryptionKey.toByteArray(Charsets.UTF_8), "AES")
        val iv = IvParameterSpec(ByteArray(16)) // Use a fixed IV for simplicity
        val cipher = Cipher.getInstance("AES/CBC/PKCS5Padding")
        cipher.init(Cipher.ENCRYPT_MODE, key, iv)
        val encryptedBytes = cipher.doFinal(data.toByteArray(Charsets.UTF_8))
        return Base64.getEncoder().encodeToString(encryptedBytes)
    }

    @TargetApi(Build.VERSION_CODES.O)
    private fun decrypt(encryptedData: String, encryptionKey: String): String {
        val key = SecretKeySpec(encryptionKey.toByteArray(Charsets.UTF_8), "AES")
        val iv = IvParameterSpec(ByteArray(16)) // Use a fixed IV for simplicity
        val cipher = Cipher.getInstance("AES/CBC/PKCS5Padding")
        cipher.init(Cipher.DECRYPT_MODE, key, iv)
        val decryptedBytes = cipher.doFinal(Base64.getDecoder().decode(encryptedData))
        return String(decryptedBytes, Charsets.UTF_8)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}