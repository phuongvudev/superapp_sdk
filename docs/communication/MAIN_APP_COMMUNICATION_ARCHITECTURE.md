# Main App Communication Architecture

The architecture of the Main App is built on an Event Bus communication model which facilitates seamless interaction between the core application and its mini apps. Here's a detailed look at the communication system:

## Communication Flow Diagram

```
┌─────────────────┐                      ┌─────────────────┐
│                 │  1. Create Event     │                 │
│    MAIN APP     ├─────────────────────►│     MINI APP    │
│                 │                      │                 │
└────────┬────────┘                      └────────┬────────┘
         │                                        │
         │                                        │
         │                                        │
         ▼                                        ▼
┌─────────────────┐                      ┌─────────────────┐
│  EventBus Dart  │◄────────────────────►│ EventBus Client │
└────────┬────────┘    2. Dispatch       └────────┬────────┘
         │             Event                      │
         │                                        │
         ▼                                        │
┌─────────────────┐                               │
│   Method/Event  │                               │
│    Channels     │                               │
└────────┬────────┘                               │
         │                                        │
         ▼                                        ▼
┌─────────────────┐                      ┌─────────────────┐
│  Native Event   │◄────────────────────►│  Event Handler  │
│     Handler     │  3. Process Event    │                 │
└─────────────────┘                      └─────────────────┘
```

## Event Bus Technical Implementation

The Event Bus implementation consists of several key components:

1. **Core EventBus Class**:
    - Singleton pattern for app-wide event management
    - Bidirectional communication via Flutter's MethodChannel and EventChannel
    - Support for encrypted and unencrypted data transmission

2. **Cross-Platform Integration**:
    - Native implementations for iOS (Swift) and Android (Kotlin)
    - Registration of platform-specific plugins and event handlers
    - Consistent event format across platforms

3. **Data Flow**:
    - Events are dispatched with a type and data payload
    - Optional encryption for sensitive data
    - JSON encoding/decoding for cross-platform compatibility

## Event Structure

Events follow a consistent structure across all platforms:

```
{
  "type": "event_identifier",
  "data": { 
    // JSON payload specific to the event
  }
}
```

## Security Layer

The Event Bus implements an optional encryption layer:

```
┌───────────────┐     ┌──────────────┐     ┌─────────────────┐
│ Original Data │────►│ Encryption   │────►│ Encrypted Data  │
│ (JSON)        │     │ (Optional)   │     │ (String)        │
└───────────────┘     └──────────────┘     └─────────────────┘
        ▲                                           │
        │                                           │
        │                                           ▼
┌───────────────┐     ┌──────────────┐     ┌─────────────────┐
│ Decoded Data  │◄────│ Decryption   │◄────│ Transport Layer │
│ (JSON)        │     │ (Optional)   │     │                 │
└───────────────┘     └──────────────┘     └─────────────────┘
```

## Platform-Specific Implementation

### iOS (Swift)
- Dedicated EventBusPlugin class for event management
- Integration with FlutterPluginRegistrar for method calls
- Support for native event emission and handling

### Android
- Native event bus implementation using MethodChannel
- Support for Java and Kotlin mini apps
- Conversion between platform-specific data types and JSON

## Mini App Integration Patterns

```
┌───────────────────────────────────────┐
│           MAIN APP                    │
│                                       │
│  ┌─────────────┐    ┌─────────────┐   │
│  │ EventBus    │◄──►│ Core API    │   │
│  └─────────────┘    └─────────────┘   │
└──────────┬────────────────────────────┘
           │
┌──────────▼────────────────────────────┐
│        MINI APP ADAPTERS              │
│ ┌─────────┐ ┌─────────┐ ┌─────────┐   │
│ │ Flutter │ │ WebView │ │ Native  │   │
│ │ Adapter │ │ Bridge  │ │ Adapter │   │
│ └─────────┘ └─────────┘ └─────────┘   │
└──────────┬────────────┬───────────────┘
           │            │
┌──────────▼──┐  ┌──────▼───────┐
│ Flutter     │  │ Web/Native   │
│ Mini App    │  │ Mini App     │
└─────────────┘  └──────────────┘
```

This architecture documentation provides more technical details on the implementation of the Event Bus communication system, which is the central component enabling the modular design of the Main App and Mini Apps ecosystem.
