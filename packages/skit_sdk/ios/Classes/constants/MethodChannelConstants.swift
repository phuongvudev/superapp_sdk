struct MethodChannelConstants {
    static let eventBusChannelName = "com.supperapp_sdk/event_bus"
    static let eventBusStreamName = "com.supperapp_sdk/event_bus_stream"

    struct EventBusMethods {
        static let dispatch = "dispatch"
        static let setEncryptionKey = "setEncryptionKey"
        static let dispatchReactNative = "dispatchReactNative"
    }

    static let miniAppChannelName = "com.supperapp_sdk/mini_app"

    struct MiniAppMethods {
        static let openMiniApp = "openMiniApp"
    }
}