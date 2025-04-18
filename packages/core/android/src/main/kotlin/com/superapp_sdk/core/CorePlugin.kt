package com.superapp_sdk.core

import androidx.annotation.NonNull
import com.superapp_sdk.event_bus.EventBusPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** CorePlugin */
class CorePlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "core")
    channel.setMethodCallHandler(this)

    // Initialize the plugin here
    initializePlugin(flutterPluginBinding)
  }

  fun initializePlugin(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    // Register EventBusPlugin
    val eventBusPlugin = EventBusPlugin()
    eventBusPlugin.onAttachedToEngine(flutterPluginBinding)

    // Register MiniAppPlugin
    val miniAppPlugin = MiniAppPlugin()
    miniAppPlugin.onAttachedToEngine(flutterPluginBinding)


  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    if (call.method == "getPlatformVersion") {
      result.success("Android ${android.os.Build.VERSION.RELEASE}")
    } else {
      result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
