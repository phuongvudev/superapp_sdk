# Main App and Mini App Communication Guide

This document explains how the Flutter main app and mini apps communicate using an Event Bus pattern, allowing for decoupled, efficient message passing between components.

## Contents

- [Overview](#overview)
- [The Event Bus Architecture](#the-event-bus-architecture)
- [Implementation](#implementation)
   - [Core Event Bus](#core-event-bus)
   - [Flutter Main App Integration](#flutter-main-app-integration)
   - [Android Native Mini App Integration](#android-native-mini-app-integration)
   - [iOS Native Mini App Integration](#ios-native-mini-app-integration)
   - [Web Mini App Integration](#web-mini-app-integration)
   - [React Native Mini App Integration](#react-native-mini-app-integration)
- [Usage Examples](#usage-examples)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)

## Overview

The communication between the Flutter main app and various types of mini apps (Android native, iOS native, React Native, web) uses an Event Bus pattern that:

- Provides decoupled communication (publisher doesn't need to know subscribers)
- Supports multi-platform integration across all mini app types
- Enables type-safe event handling with optional encryption
- Allows both synchronous and asynchronous communication

## The Event Bus Architecture

```
┌─────────────────┐      ┌───────────────────┐      ┌─────────────────┐
│                 │      │                   │      │   Mini Apps:    │
│  Flutter Main   │◄────►│    Event Bus      │◄────►│ - Android       │
│      App        │      │                   │      │ - iOS           │
│                 │      │                   │      │ - React Native  │
└─────────────────┘      └───────────────────┘      │ - Web           │
      publishes                 routes               └─────────────────┘
      events                    events                 subscribes to
                                                       relevant events
```

The Event Bus serves as a central hub that:
1. Registers event types and handlers
2. Routes events to appropriate subscribers
3. Maintains isolation between components
4. Handles cross-platform translation of events
5. Provides optional encryption for sensitive data

## Implementation

### Core Event Bus

```dart
// From packages/core/lib/src/communication/event_bus.dart
class EventBus {
  final Map<String, List<Function(dynamic)>> _eventHandlers = {};
  final StreamController<Event> _eventStreamController = StreamController<Event>.broadcast();
  final MethodChannel _platformMethodChannel = const MethodChannel(MethodChannelConstants.methodChannelEventBus);
  final EventChannel _eventChannel = const EventChannel(MethodChannelConstants.eventChannelEventBus);

  MapEncryptor? encryptor;

  static final EventBus _instance = EventBus._internal();

  factory EventBus({MapEncryptor? encryptor, String? encryptionKey}) {
    if (encryptor != null || encryptionKey != null) {
      _instance._setEncryptor(encryptor, encryptionKey);
    }
    return _instance;
  }

  void dispatch(Event event) {
    _eventStreamController.sink.add(event);

    var data = event.data;
    if (encryptor != null) {
      data = encryptor!.encrypt(data);
    } else {
      data = jsonEncode(event.data);
    }

    _platformMethodChannel.invokeMethod('dispatch', {
      'type': event.type,
      'data': data,
    });
  }

  void on(String type, Function(dynamic) callback) {
    if (!_eventHandlers.containsKey(type)) {
      _eventHandlers[type] = [];
    }
    _eventHandlers[type]!.add(callback);

    eventStream.listen((event) {
      if (event.type == type) {
        for (final subscription in _eventHandlers[type]!) {
          subscription(event.data);
        }
      }
    });
  }
}
```

### Flutter Main App Integration

```dart
// In your Flutter main app
import 'package:core/core.dart';

class MainAppEventManager {
  final EventBus _eventBus = EventBus();

  void initialize() {
    // Subscribe to events from mini apps
    _eventBus.on('miniAppResult', (data) {
      handleMiniAppResult(data);
    });

    _eventBus.on('miniAppRequest', (data) {
      handleMiniAppRequest(data);
    });
  }

  void broadcastEvent(String eventName, Map<String, dynamic> data) {
    _eventBus.dispatch(Event(eventName, data));
  }

  void sendDataToMiniApp(String miniAppId, Map<String, dynamic> data) {
    _eventBus.dispatch(Event('mainAppData', {
      'targetMiniAppId': miniAppId,
      'data': data
    }));
  }

  void handleMiniAppResult(dynamic data) {
    // Process mini app results
    final miniAppId = data['miniAppId'];
    final result = data['result'];
    print('Received result from mini app $miniAppId: $result');
  }

  void handleMiniAppRequest(dynamic data) {
    // Handle various requests from mini apps
    final miniAppId = data['miniAppId'];
    final requestType = data['requestType'];
    final params = data['params'];
    
    switch (requestType) {
      case 'navigation':
        // Navigation handling
        break;
      case 'userData':
        // Send user data to mini app
        break;
      // Other request types
    }
  }
}
```

### Android Native Mini App Integration

Using the provided `EventBusPlugin.kt` for communication:

```kotlin
// In your Android native mini app
class MiniAppEventConnector(private val miniAppId: String) {
    private val eventListeners = mutableMapOf<String, MutableList<(Map<String, Any>) -> Unit>>()
    
    fun addEventListener(eventName: String, listener: (Map<String, Any>) -> Unit) {
        if (!eventListeners.containsKey(eventName)) {
            eventListeners[eventName] = mutableListOf()
        }
        eventListeners[eventName]?.add(listener)
    }
    
    fun publishEvent(eventName: String, data: Map<String, Any>) {
        val eventData = mapOf(
            "miniAppId" to miniAppId,
            "eventName" to eventName,
            "payload" to data
        )
        EventBusPlugin().sendEventToMainApp(eventName, eventData)
    }
    
    fun requestDataFromMainApp(requestType: String, params: Map<String, Any>): CompletableFuture<Map<String, Any>> {
        val future = CompletableFuture<Map<String, Any>>()
        val eventData = mapOf(
            "miniAppId" to miniAppId,
            "requestType" to requestType,
            "params" to params
        )
        
        // Implementation to handle response
        addEventListener("response_$requestType", { responseData ->
            if (responseData["requestId"] == requestType) {
                future.complete(responseData)
            }
        })
        
        EventBusPlugin().sendEventToMainApp("miniAppRequest", eventData)
        return future
    }
    
    // Called when event received from main app
    fun onEventReceived(eventName: String, data: Map<String, Any>) {
        eventListeners[eventName]?.forEach { listener ->
            listener(data)
        }
    }
}

// Usage example
val connector = MiniAppEventConnector("android_mini_app")
connector.addEventListener("themeChanged") { themeData ->
    // Update theme
    val isDarkMode = themeData["isDarkMode"] as Boolean
    updateAppTheme(isDarkMode)
}
```

### iOS Native Mini App Integration

Using the provided `EventBusPlugin.swift` for communication:

```swift
// In your iOS native mini app
class MiniAppEventConnector {
    private let miniAppId: String
    private var eventListeners: [String: [(payload: [String: Any]) -> Void]] = [:]
    
    init(miniAppId: String) {
        self.miniAppId = miniAppId
    }
    
    func addEventListener(eventName: String, listener: @escaping (_ payload: [String: Any]) -> Void) {
        if eventListeners[eventName] == nil {
            eventListeners[eventName] = []
        }
        eventListeners[eventName]?.append(listener)
    }
    
    func publishEvent(eventName: String, data: [String: Any]) {
        let eventData: [String: Any] = [
            "miniAppId": miniAppId,
            "eventName": eventName,
            "payload": data
        ]
        EventBusPlugin.shared.sendEventToMainApp(eventType: eventName, eventData: eventData)
    }
    
    func requestDataFromMainApp(requestType: String, params: [String: Any]) -> Promise<[String: Any]> {
        let promise = Promise<[String: Any]>()
        let eventData: [String: Any] = [
            "miniAppId": miniAppId,
            "requestType": requestType,
            "params": params
        ]
        
        // Implementation to handle response
        addEventListener("response_\(requestType)") { responseData in
            if let requestId = responseData["requestId"] as? String, requestId == requestType {
                promise.resolve(responseData)
            }
        }
        
        EventBusPlugin.shared.sendEventToMainApp(eventType: "miniAppRequest", eventData: eventData)
        return promise
    }
    
    // Called when event received from main app
    func onEventReceived(eventName: String, data: [String: Any]) {
        eventListeners[eventName]?.forEach { listener in
            listener(data)
        }
    }
}

// Usage example
let connector = MiniAppEventConnector(miniAppId: "ios_mini_app")
connector.addEventListener(eventName: "userLoggedIn") { userData in
    // Handle user login
    let username = userData["username"] as? String ?? ""
    updateUserInterface(for: username)
}
```

### Web Mini App Integration

```javascript
// In your web mini app
class EventBusConnector {
  constructor(miniAppId) {
    this.miniAppId = miniAppId;
    this.subscribers = {};
    this.initializeBridge();
  }

  initializeBridge() {
    // For Flutter WebView
    if (window.flutter_inappwebview) {
      window.flutter_inappwebview.callHandler('registerMiniApp', this.miniAppId);

      // Set up message handler
      window.receiveEventFromMainApp = (eventName, dataString) => {
        const data = JSON.parse(dataString);
        this.notifySubscribers(eventName, data);
      };
    }
  }

  subscribe(eventName, callback) {
    if (!this.subscribers[eventName]) {
      this.subscribers[eventName] = [];
    }
    this.subscribers[eventName].push(callback);
  }

  publishEvent(eventName, data) {
    // For Flutter WebView
    if (window.flutter_inappwebview) {
      window.flutter_inappwebview.callHandler(
        'publishEvent',
        this.miniAppId,
        eventName,
        JSON.stringify(data)
      );
    }
  }

  requestData(requestType, params) {
    return new Promise((resolve, reject) => {
      // For Flutter WebView
      if (window.flutter_inappwebview) {
        window.flutter_inappwebview.callHandler(
          'requestData',
          this.miniAppId,
          requestType,
          JSON.stringify(params)
        ).then(responseString => {
          resolve(JSON.parse(responseString));
        }).catch(error => {
          reject(error);
        });
      } else {
        reject(new Error("WebView bridge not available"));
      }
    });
  }
}

// Usage example
const eventBus = new EventBusConnector('web_mini_app');

// Subscribe to theme changes
eventBus.subscribe('themeChanged', (data) => {
  document.body.classList.toggle('dark-mode', data.isDarkMode);
  document.documentElement.style.setProperty('--primary-color', data.primaryColor);
});

// Send form data to main app
document.getElementById('submitForm').addEventListener('click', () => {
  const formData = {
    name: document.getElementById('nameInput').value,
    email: document.getElementById('emailInput').value
  };
  eventBus.publishEvent('formSubmitted', formData);
});
```

### React Native Mini App Integration

```javascript
// In your React Native mini app
import { NativeModules, NativeEventEmitter } from 'react-native';

const { EventBusModule } = NativeModules;
const eventEmitter = new NativeEventEmitter(EventBusModule);

class EventBusConnector {
  constructor(miniAppId) {
    this.miniAppId = miniAppId;
    this.subscriptions = [];
    
    // Register mini app with the event bus
    EventBusModule.registerMiniApp(miniAppId);
  }

  subscribe(eventName, callback) {
    const subscription = eventEmitter.addListener(eventName, (event) => {
      callback(event.data);
    });
    this.subscriptions.push(subscription);
    return subscription;
  }

  publishEvent(eventName, data) {
    EventBusModule.publishEvent(this.miniAppId, eventName, data);
  }

  requestData(requestType, params) {
    return EventBusModule.requestData(this.miniAppId, requestType, params);
  }

  unsubscribe(subscription) {
    subscription.remove();
    const index = this.subscriptions.indexOf(subscription);
    if (index > -1) {
      this.subscriptions.splice(index, 1);
    }
  }

  cleanup() {
    this.subscriptions.forEach(subscription => subscription.remove());
    this.subscriptions = [];
  }
}

// Usage example
import React, { useEffect, useState } from 'react';
import { View, Text, Button } from 'react-native';

function MiniAppComponent() {
  const [theme, setTheme] = useState({ isDarkMode: false, primaryColor: '#FFFFFF' });
  const [userProfile, setUserProfile] = useState(null);
  const eventBus = new EventBusConnector('react_native_mini_app');
  
  useEffect(() => {
    // Subscribe to theme changes
    const themeSubscription = eventBus.subscribe('themeChanged', (data) => {
      setTheme(data);
    });
    
    // Request user profile
    eventBus.requestData('userProfile', {})
      .then(profile => setUserProfile(profile))
      .catch(error => console.error(error));
    
    return () => {
      eventBus.cleanup();
    };
  }, []);
  
  return (
    <View style={{ backgroundColor: theme.primaryColor }}>
      <Text>React Native Mini App</Text>
      {userProfile && <Text>Hello, {userProfile.name}</Text>}
      <Button 
        title="Complete Task" 
        onPress={() => eventBus.publishEvent('taskCompleted', { status: 'success' })} 
      />
    </View>
  );
}
```

## Usage Examples

### Registering Mini Apps with Event Bus Support

```dart
// In Flutter main app using SKit
final sdk = SKit();

await sdk.initialize(
  config: {'apiKey': 'your_api_key'},
  optionalConfig: SDKOptionalConfig(
    encryptionKey: 'secure_encryption_key',
  ),
);

// Register a Flutter mini app
await sdk.miniApp.registerMiniApp(
  MiniAppManifest(
    appId: "flutter_mini_app",
    name: "Flutter Mini App",
    framework: FrameworkType.flutter,
    entryPath: "packages/flutter_mini_app/lib/main.dart",
    supportedEvents: ["themeChanged", "userLoggedIn", "networkStatusChanged"],
  )
);

// Register an Android native mini app
await sdk.miniApp.registerMiniApp(
  MiniAppManifest(
    appId: "android_mini_app",
    name: "Android Native Mini App",
    framework: FrameworkType.android,
    entryPath: "com.example.miniapp.MainActivity",
    supportedEvents: ["themeChanged", "locationUpdated"],
  )
);

// Register a web mini app
await sdk.miniApp.registerMiniApp(
  MiniAppManifest(
    appId: "web_mini_app",
    name: "Web Mini App",
    framework: FrameworkType.web,
    entryPath: "https://example.com/mini_apps/web_mini_app/",
    supportedEvents: ["themeChanged", "cartUpdated"],
  )
);
```

### Broadcasting Events from Flutter Main App to Mini Apps

```dart
// In Flutter main app
void updateAppTheme(bool isDarkMode) {
  // Update main app theme first
  ThemeProvider.of(context).setTheme(isDarkMode ? darkTheme : lightTheme);

  // Notify all mini apps about theme change
  sdk.eventBus.dispatch(Event('themeChanged', {
    'isDarkMode': isDarkMode,
    'primaryColor': isDarkMode ? "#121212" : "#FFFFFF",
    'accentColor': isDarkMode ? "#BB86FC" : "#6200EE"
  }));
}

// Send user-specific event to a single mini app
void refreshUserDataInMiniApp(String miniAppId) {
  final userData = userRepository.getCurrentUserData();

  sdk.eventBus.dispatch(Event('mainAppData', {
    'targetMiniAppId': miniAppId,
    'data': {
      'userData': userData.toMap()
    }
  }));
}
```

### Handling Events from Mini Apps in Flutter Main App

```dart
// In Flutter main app
void initializeMiniAppEventHandling() {
  // Handle payment completion from any mini app
  sdk.eventBus.on('paymentCompleted', (data) {
    final miniAppId = data['miniAppId'];
    final amount = data['amount'] as double;
    final transactionId = data['transactionId'] as String;
    
    // Process successful payment
    paymentService.confirmTransaction(transactionId);
    
    // Show success notification
    showNotification(
      title: 'Payment Successful',
      message: 'Your payment of \$${amount.toStringAsFixed(2)} was processed successfully.'
    );
  });

  // Handle user profile updates
  sdk.eventBus.on('profileUpdated', (data) {
    // Refresh user data in main app
    userRepository.refreshUserData();
    
    // Update UI components that display user info
    setState(() {
      userProfile = userRepository.getCurrentUserData();
    });
  });
}
```

## Best Practices

1. **Event Naming**
   - Use consistent naming conventions (e.g., past-tense for completed actions: `profileUpdated`)
   - Namespace events to avoid conflicts (e.g., `user:loggedIn`, `theme:changed`)
   - Document all supported events for each mini app

2. **Security**
   - Use encryption for sensitive data via the built-in encryption support
   - Validate event sources and implement permission checks
   - Don't send sensitive information like authentication tokens through events

3. **Data Structure**
   - Keep event payloads small and focused
   - Use standard data types that serialize well across platforms
   - Validate data on both sending and receiving sides

4. **Error Handling**
   - Implement timeouts for requests
   - Add proper error handling for all event subscriptions
   - Provide fallback behavior when communication fails

5. **Performance**
   - Unsubscribe from events when no longer needed
   - Be cautious with high-frequency events
   - Consider batching multiple high-frequency updates

## Troubleshooting

### Common Issues

1. **Events not being received**
   - Check that the mini app is properly registered with supported events
   - Verify the event name matches exactly (case-sensitive)
   - Ensure the event bus is properly initialized in both main app and mini app

2. **Data serialization problems**
   - Use only simple data types (strings, numbers, booleans, maps, lists)
   - Avoid circular references in objects
   - Check for null values that might be causing issues

3. **Encryption issues**
   - Verify that encryption keys match on both sides
   - Ensure the correct encryption/decryption methods are being used

4. **Web view communication failures**
   - Verify JavaScript bridge is properly initialized
   - Check for console errors in web inspector
   - Ensure the web content is loaded completely before communication

5. **Cross-platform compatibility**
   - Test events across all supported mini app types
   - Use consistent data structures across platforms
   - Handle platform-specific edge cases

### Debugging Tips

- Enable verbose logging for the event bus in development builds
- Implement a visual event monitor for development environments
- Create test events to verify communication flows

---

This documentation provides a foundation for implementing a robust communication system between your Flutter main app and various types of mini apps using the Event Bus pattern.

## References
- [Flutter Event Bus Documentation](https://pub.dev/packages/event_bus)
- [Flutter Method Channels](https://flutter.dev/docs/development/platform-integration/platform-channels)
- [Flutter WebView Documentation](https://pub.dev/packages/webview_flutter)
- [React Native EventEmitter](https://reactnative.dev/docs/native-modules-ios#eventemitter)
- [Android EventBus](https://github.com/greenrobot/EventBus)