package com.superapp_sdk.constants

/**
 * A utility class that defines constants for different framework types.
 * These constants are used to identify the framework type in the application.
 */
class FrameworkTypeConstants {

    companion object {
        /**
         * Represents the Flutter Web framework.
         */
        const val FLUTTER_WEB = "flutter_web"

        /**
         * Represents the React Native framework.
         */
        const val REACT_NATIVE = "react_native"

        /**
         * Represents a native Android framework.
         */
        const val NATIVE = "native"

        /**
         * Represents a generic web framework.
         */
        const val WEB = "web"

        /**
         * Represents an unknown or unsupported framework.
         */
        const val UNKNOWN = "unknown"
    }
}