package com.superapp_sdk.mini_app

import android.content.Context
import android.content.Intent
import androidx.annotation.NonNull
import com.superapp_sdk.constants.FrameworkTypeConstants
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import com.superapp_sdk.constants.MethodChannelConstants

class MiniAppPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    /**
     * Called when the plugin is attached to the Flutter engine.
     * Sets up the MethodChannel for communication between Flutter and native Android.
     */
    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, MethodChannelConstants.METHOD_CHANNEL_MINI_APP)
        channel.setMethodCallHandler(this)
    }

    /**
     * Handles method calls from Flutter.
     * Supports opening mini apps based on the specified framework type.
     */
    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "openMiniApp" -> {
                val framework = call.argument<String>("framework") ?: ""
                val appId = call.argument<String>("appId") ?: ""
                val params = call.argument<Map<String, Any>>("params") ?: emptyMap()

                // Route the request based on the framework type
                when (framework) {
                    FrameworkTypeConstants.REACT_NATIVE -> openReactNativeApp(appId, params, result)
                    FrameworkTypeConstants.NATIVE -> openAndroidNativeApp(appId, params, result)
                    FrameworkTypeConstants.UNKNOWN -> result.error(
                        "INVALID_FRAMEWORK",
                        "Unsupported framework: $framework",
                        null
                    )
                    else -> result.error(
                        "INVALID_FRAMEWORK",
                        "Unsupported framework: $framework",
                        null
                    )
                }
                result.success(null)
            }

            else -> result.notImplemented()
        }
    }

    /**
     * Opens a React Native mini app.
     * @param appId The ID of the React Native app to open.
     * @param params Additional parameters to pass to the app.
     */
    private fun openReactNativeApp(appId: String, params: Map<String, Any>,  @NonNull result: Result) {
        val intent = Intent(context, ReactNativeActivity::class.java)
        intent.putExtra("appId", appId)
        intent.putExtra("params", HashMap(params))
        context.startActivity(intent)
    }

    /**
     * Opens a native Android mini app.
     * @param appId The fully qualified class name of the native activity to open.
     * @param params Additional parameters to pass to the activity.
     */
    private fun openAndroidNativeApp(appId: String, params: Map<String, Any>, @NonNull result: Result) {
        val entryPath = params["entryPath"] as? String
        try {
            val intent = Intent(context, Class.forName(entryPath ?: appId))

            // Add parameters to the intent
            params.forEach { (key, value) ->
                when (value) {
                    is String -> intent.putExtra(key, value)
                    is Int -> intent.putExtra(key, value)
                    is Boolean -> intent.putExtra(key, value)
                    is Double -> intent.putExtra(key, value)
                    else -> intent.putExtra(key, value.toString())
                }
            }

            // Start activity for result using ActivityResultLauncher
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            context.startActivity(intent)

            // Handle the result
            // Note: For complex result handling, consider implementing
            // registerForActivityResult or using a result callback system

            result.success(null)
        } catch (e: ClassNotFoundException) {
            result.error(
                "CLASS_NOT_FOUND",
                "Android activity class not found: $appId with entry path $entryPath",
                e.toString()
            )
        } catch (e: Exception) {
            result.error(
                "LAUNCH_FAILED",
                "Failed to launch Android mini app ($appId/$entryPath): ${e.message}",
                e.toString()
            )
        }
    }

    /**
     * Called when the plugin is detached from the Flutter engine.
     * Cleans up the MethodChannel.
     */
    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}