package com.superapp_sdk.mini_app

import android.content.Context
import android.content.Intent
import android.util.Log
import androidx.activity.ComponentActivity
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.contract.ActivityResultContracts
import com.superapp_sdk.constants.FrameworkTypeConstants
import com.superapp_sdk.constants.MethodChannelConstants
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class MiniAppPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

    companion object {
        const val RESULT_CODE_KEY = "resultCode"
        const val DATA_KEY = "data"
    }

    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private var activity: ComponentActivity? = null
    private lateinit var activityResultLauncher: ActivityResultLauncher<Intent>

    /**
     * Called when the plugin is attached to the Flutter engine.
     * Sets up the MethodChannel for communication between Flutter and native Android.
     */
    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(
            flutterPluginBinding.binaryMessenger,
            MethodChannelConstants.METHOD_CHANNEL_MINI_APP
        )
        channel.setMethodCallHandler(this)
    }

    /**
     * Handles method calls from Flutter.
     * Supports opening mini apps based on the specified framework type.
     */
    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "openMiniApp" -> {
                val framework = call.argument<String>("framework") ?: ""
                val appId = call.argument<String>("appId") ?: ""
                val params = call.argument<Map<String, Any>>("params") ?: emptyMap()

                // Route the request based on the framework type
                when (framework) {
                    FrameworkTypeConstants.REACT_NATIVE,
                    FrameworkTypeConstants.NATIVE -> openApp(appId, params, result)

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
     * Opens a native Android mini app.
     * @param appId The fully qualified class name of the native activity to open.
     * @param params Additional parameters to pass to the activity.
     */
    private fun openApp(
        appId: String,
        params: Map<String, Any>,
        result: Result
    ) {
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
            if (activity != null) {
                // Set up result callback
                MiniAppBridge.getInstance().setResultCallback(result)
                activityResultLauncher.launch(intent)
            } else {
                // Fallback to regular startActivity if activity isn't available
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                context.startActivity(intent)
                result.success(null)
            }
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
    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    // Implement ActivityAware methods
    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity as? ComponentActivity
        registerActivityResultLauncher()
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity as? ComponentActivity
        registerActivityResultLauncher()
    }

    private fun registerActivityResultLauncher() {
        activity?.let { it ->
            activityResultLauncher = it.registerForActivityResult(
                ActivityResultContracts.StartActivityForResult()
            ) { activityResult ->
                try {
                    // Handle the result and send back to Flutter
                    val resultData = HashMap<String, Any?>()
                    resultData[RESULT_CODE_KEY] = activityResult.resultCode

                    val map: Map<String, Any?>? = activityResult.data?.extras?.let {
                        it.keySet().associateWith { key ->
                            it.get(key)
                        }
                    }
                    resultData[DATA_KEY] = map

                    // Send the result back to Flutter
                    MiniAppBridge.getInstance().sendResult(resultData)
                } catch (e: Exception) {
                    Log.e("registerActivityResult", "Error processing activity result", e)
                    MiniAppBridge.getInstance().sendError(
                        "ACTIVITY_RESULT_ERROR",
                        "Error processing activity result: ${e.message}"
                    )
                } finally {
                    MiniAppBridge.getInstance().setResultCallback(null);
                }
            }
        }
    }

}