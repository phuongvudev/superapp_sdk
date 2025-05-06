package com.superapp_sdk.mini_app

import io.flutter.plugin.common.MethodChannel.Result

class MiniAppBridge private constructor() {
    private var resultCallback: Result? = null

    companion object {
        private val instance = MiniAppBridge()

        fun getInstance(): MiniAppBridge {
            return instance
        }
    }

    fun setResultCallback(callback: Result?) {
        resultCallback = callback
    }

    fun sendResult(resultData: Map<String, Any?>?) {
        resultCallback?.success(resultData)
        resultCallback = null
    }

    fun sendError(errorCode: String, errorMessage: String) {
        resultCallback?.error(errorCode, errorMessage, null)
        resultCallback = null
    }
}