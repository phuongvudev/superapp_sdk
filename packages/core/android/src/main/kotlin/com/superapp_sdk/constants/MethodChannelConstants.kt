package com.superapp_sdk.constants

/**
 * A utility class that defines constants for MethodChannel names.
 * These constants are used for communication between Flutter and native Android.
 */
class MethodChannelConstants {

    companion object {
        /**
         * The MethodChannel name for the Event Bus plugin.
         * Used to handle event bus communication between Flutter and native Android.
         */
        const val METHOD_CHANNEL_EVENT_BUS = "com.supperapp_sdk/event_bus"

        /**
         * The MethodChannel name for the Mini App plugin.
         * Used to handle mini app interactions between Flutter and native Android.
         */
        const val METHOD_CHANNEL_MINI_APP = "com.supperapp_sdk/mini_app"

        /**
         * The EventChannel name for the Event Bus plugin.
         * Used to stream events from native Android to Flutter.
         */
        const val EVENT_CHANNEL_EVENT_BUS = "com.supperapp_sdk/event_bus_stream"
    }
}