# Main App and Mini App Communication Guide

This document explains how the main app and mini apps communicate using an Event Bus pattern, allowing for decoupled, efficient message passing between components.

## Contents

- [Overview](#overview)
- [The Event Bus Architecture](#the-event-bus-architecture)
- [Implementation](#implementation)
    - [Core Event Bus](#core-event-bus)
    - [Main App Integration](#main-app-integration)
    - [Flutter Mini App Integration](#flutter-mini-app-integration)
    - [Web Mini App Integration](#web-mini-app-integration)
- [Usage Examples](#usage-examples)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)

## Overview

The communication between the main app and mini apps uses an Event Bus pattern that:

- Provides decoupled communication (publisher doesn't need to know subscribers)
- Supports multi-platform integration (native Android, Flutter, web)
- Enables type-safe event handling
- Allows both synchronous and asynchronous communication

## The Event Bus Architecture

```
┌─────────────────┐      ┌───────────────────┐      ┌─────────────────┐
│                 │      │                   │      │                 │
│    Main App     │◄────►│    Event Bus      │◄────►│   Mini Apps     │
│                 │      │                   │      │                 │
└─────────────────┘      └───────────────────┘      └─────────────────┘
      publishes                 routes                 subscribes to
      events                    events                 relevant events
```

The Event Bus serves as a central hub that:
1. Registers event types and handlers
2. Routes events to appropriate subscribers
3. Maintains isolation between components
4. Handles cross-platform translation of events

## Implementation

### Core Event Bus

```kotlin
// In core module
class EventBus {
    private val subscribers = mutableMapOf<Class<*>, MutableList<(Any) -> Unit>>()
    
    fun <T : Any> subscribe(eventClass: Class<T>, subscriber: (T) -> Unit) {
        val typedSubscriber: (Any) -> Unit = { event -> subscriber(event as T) }
        subscribers.getOrPut(eventClass) { mutableListOf() }.add(typedSubscriber)
    }
    
    inline fun <reified T : Any> subscribe(noinline subscriber: (T) -> Unit) {
        subscribe(T::class.java, subscriber)
    }
    
    fun <T : Any> publish(event: T) {
        val eventClass = event.javaClass
        subscribers[eventClass]?.forEach { subscriber ->
            subscriber(event)
        }
    }
    
    fun <T : Any> unsubscribe(eventClass: Class<T>, subscriber: (T) -> Unit) {
        // Implementation for unsubscribing
    }
}

// Create a singleton instance
object EventBusManager {
    val eventBus = EventBus()
}
```

### Main App Integration

```kotlin
// In your main app
class MainAppCommunicationManager(private val eventBus: EventBus = EventBusManager.eventBus) {
    
    fun initialize() {
        // Subscribe to events from mini apps
        eventBus.subscribe<MiniAppDataEvent> { event ->
            handleMiniAppData(event)
        }
        
        eventBus.subscribe<MiniAppRequestEvent> { event ->
            handleMiniAppRequest(event)
        }
    }
    
    fun sendDataToMiniApp(miniAppId: String, data: Map<String, Any>) {
        eventBus.publish(MainAppDataEvent(miniAppId, data))
    }
    
    fun notifyMiniAppEvent(eventName: String, data: Map<String, Any>? = null) {
        eventBus.publish(MainAppNotificationEvent(eventName, data))
    }
    
    private fun handleMiniAppData(event: MiniAppDataEvent) {
        // Process data received from mini app
        val miniAppId = event.miniAppId
        val data = event.data
        
        // Your handling logic here
    }
    
    private fun handleMiniAppRequest(event: MiniAppRequestEvent) {
        // Handle requests from mini apps
        when (event.requestType) {
            "navigation" -> handleNavigationRequest(event.params)
            "permission" -> handlePermissionRequest(event.params)
            // Other request types
        }
    }
}

// Event classes
data class MainAppDataEvent(val miniAppId: String, val data: Map<String, Any>)
data class MainAppNotificationEvent(val eventName: String, val data: Map<String, Any>?)
data class MiniAppDataEvent(val miniAppId: String, val data: Map<String, Any>)
data class MiniAppRequestEvent(
    val miniAppId: String,
    val requestType: String,
    val params: Map<String, Any>
)
```

### Flutter Mini App Integration

```dart
// In your Flutter mini app
class EventBusConnector {
  final String miniAppId;
  
  // Channel for native communication
  static const _channel = MethodChannel('com.example.mini_app/event_bus');
  
  // Local event bus for Flutter-side communication
  static final _localEventBus = StreamController<dynamic>.broadcast();
  
  EventBusConnector(this.miniAppId) {
    _initializeChannel();
  }
  
  void _initializeChannel() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onEventReceived') {
        final eventName = call.arguments['eventName'];
        final eventData = call.arguments['data'];
        
        // Pass to local event bus
        _localEventBus.add({
          'eventName': eventName,
          'data': eventData,
        });
      }
      return null;
    });
  }
  
  Future<void> publishEvent(String eventName, Map<String, dynamic> data) async {
    await _channel.invokeMethod('publishEvent', {
      'miniAppId': miniAppId,
      'eventName': eventName,
      'data': data,
    });
  }
  
  Stream<dynamic> subscribe(String eventName) {
    return _localEventBus.stream.where((event) => 
        event is Map && event['eventName'] == eventName);
  }
  
  Future<Map<String, dynamic>?> requestData(String requestType, Map<String, dynamic> params) async {
    final result = await _channel.invokeMethod('requestData', {
      'miniAppId': miniAppId,
      'requestType': requestType,
      'params': params,
    });
    
    if (result != null) {
      return Map<String, dynamic>.from(result);
    }
    return null;
  }
  
  void dispose() {
    // Clean up resources
  }
}

// Example usage in Flutter mini app
class MiniAppBridge {
  late EventBusConnector _connector;
  
  void initialize(String miniAppId) {
    _connector = EventBusConnector(miniAppId);
    
    // Subscribe to events from main app
    _connector.subscribe('themeChanged').listen((event) {
      final data = event['data'];
      // Update theme
    });
  }
  
  Future<void> sendResult(Map<String, dynamic> result) async {
    await _connector.publishEvent('result', result);
  }
  
  Future<Map<String, dynamic>?> getUserProfile() async {
    return await _connector.requestData('userProfile', {});
  }
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
      window.receiveEventFromMainApp = (eventName, data) => {
        this.notifySubscribers(eventName, data);
      };
    } 
    // For native WebView
    else if (window.MiniAppBridge) {
      window.MiniAppBridge.registerMiniApp(this.miniAppId);
      
      window.MiniAppBridge.setEventListener((eventName, dataString) => {
        const data = JSON.parse(dataString);
        this.notifySubscribers(eventName, data);
      });
    }
  }
  
  subscribe(eventName, callback) {
    if (!this.subscribers[eventName]) {
      this.subscribers[eventName] = [];
    }
    this.subscribers[eventName].push(callback);
  }
  
  unsubscribe(eventName, callback) {
    if (this.subscribers[eventName]) {
      this.subscribers[eventName] = this.subscribers[eventName]
        .filter(cb => cb !== callback);
    }
  }
  
  notifySubscribers(eventName, data) {
    if (this.subscribers[eventName]) {
      this.subscribers[eventName].forEach(callback => {
        callback(data);
      });
    }
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
    // For native WebView
    else if (window.MiniAppBridge) {
      window.MiniAppBridge.publishEvent(
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
      } 
      // For native WebView
      else if (window.MiniAppBridge) {
        try {
          const responseString = window.MiniAppBridge.requestData(
            this.miniAppId,
            requestType,
            JSON.stringify(params)
          );
          resolve(JSON.parse(responseString));
        } catch (error) {
          reject(error);
        }
      } else {
        reject(new Error("Bridge not available"));
      }
    });
  }
}

// Example usage
const eventBus = new EventBusConnector('web_mini_app_id');

// Subscribe to events
eventBus.subscribe('themeChanged', (data) => {
  console.log('Theme changed:', data);
  // Update UI with new theme
});

// Publish events
document.getElementById('submitButton').addEventListener('click', () => {
  eventBus.publishEvent('formSubmitted', {
    formData: {
      name: document.getElementById('nameInput').value,
      email: document.getElementById('emailInput').value
    }
  });
});

// Request data
async function loadUserProfile() {
  try {
    const userProfile = await eventBus.requestData('userProfile', {});
    document.getElementById('userInfo').textContent = `Welcome, ${userProfile.name}!`;
  } catch (error) {
    console.error('Failed to load user profile:', error);
  }
}
```

## Usage Examples

### Registering Mini Apps with Event Bus Support

```kotlin
// In main app
val miniAppManager = MiniAppManager()

// Register a Flutter mini app with event bus support
miniAppManager.registerMiniApp(
  MiniAppManifest(
    appId = "flutter_mini_app",
    name = "Flutter Mini App",
    framework = FrameworkType.FLUTTER,
    entryPath = "packages/flutter_mini_app/lib/main.dart",
    supportedEvents = listOf("themeChanged", "userLoggedIn", "networkStatusChanged")
  )
)

// Register a Web mini app with event bus support
miniAppManager.registerMiniApp(
  MiniAppManifest(
    appId = "web_mini_app",
    name = "Web Mini App",
    framework = FrameworkType.WEB,
    entryPath = "https://example.com/mini_apps/web_mini_app/",
    supportedEvents = listOf("themeChanged", "cartUpdated")
  )
)
```

### Listening for Mini App Events in Main App

```kotlin
// In main app
val communicationManager = MainAppCommunicationManager()

// Initialize event bus subscribers
communicationManager.initialize()

// Handle specific mini app events
eventBus.subscribe<MiniAppDataEvent> { event ->
  when (event.miniAppId) {
    "payment_mini_app" -> {
      if (event.data.containsKey("paymentComplete")) {
        val amount = event.data["amount"] as Double
        val transactionId = event.data["transactionId"] as String
        
        // Process successful payment
        mainAppViewModel.processPayment(amount, transactionId)
      }
    }
    
    "profile_mini_app" -> {
      if (event.data.containsKey("profileUpdated")) {
        // Refresh user data after profile update
        mainAppViewModel.refreshUserData()
      }
    }
  }
}
```

### Broadcasting Events from Main App to Mini Apps

```kotlin
// Send theme change event to all mini apps
fun updateAppTheme(isDarkMode: Boolean) {
  // Update main app theme
  applyTheme(isDarkMode)
  
  // Notify mini apps about theme change
  communicationManager.notifyMiniAppEvent("themeChanged", mapOf(
    "isDarkMode" to isDarkMode,
    "primaryColor" to if (isDarkMode) "#121212" else "#FFFFFF",
    "accentColor" to if (isDarkMode) "#BB86FC" else "#6200EE"
  ))
}

// Send user-specific event to a single mini app
fun refreshUserDataInMiniApp(miniAppId: String) {
  val userData = userRepository.getCurrentUserData()
  
  communicationManager.sendDataToMiniApp(miniAppId, mapOf(
    "userData" to userData.toMap()
  ))
}
```

## Best Practices

1. **Event Naming**
    - Use consistent naming conventions (e.g., past-tense for completed actions: `profileUpdated`)
    - Namespace events to avoid conflicts (e.g., `user:loggedIn`, `theme:changed`)

2. **Data Structure**
    - Keep event payloads small and focused
    - Use standard data types that serialize well across platforms
    - Validate data on both sending and receiving sides

3. **Error Handling**
    - Implement timeouts for requests
    - Provide proper error responses
    - Add error handling for all event subscriptions

4. **Performance**
    - Unsubscribe from events when no longer needed
    - Be cautious with high-frequency events
    - Consider batching multiple high-frequency updates

5. **Security**
    - Validate event sources
    - Sanitize data received from mini apps
    - Implement permission checks for sensitive operations

6. **Testing**
    - Write unit tests for event handlers
    - Create mock event publishers for testing
    - Test edge cases like disconnects and reconnects

## Troubleshooting

### Common Issues

1. **Events not being received**
    - Check that the subscriber is registered correctly
    - Verify the event name matches exactly (case-sensitive)
    - Ensure the mini app is properly registered with the event bus

2. **Data serialization problems**
    - Use only simple data types (strings, numbers, booleans, maps, lists)
    - Avoid circular references
    - Check for null values that might be causing issues

3. **Memory leaks**
    - Ensure all event subscriptions are properly cleaned up
    - Unsubscribe from events when components are destroyed
    - Watch for strong references in event handlers

4. **Web view communication failures**
    - Verify JavaScript bridge is properly initialized
    - Check for console errors in web inspector
    - Ensure the web content is loaded completely before communication

5. **Performance issues**
    - Reduce event payload sizes
    - Limit high-frequency events
    - Consider debouncing rapidly firing events

### Debugging Tips

- Enable verbose logging for the event bus in development builds
- Add timestamps to events for timing analysis
- Implement a visual event monitor for development environments

---

This documentation provides a foundation for implementing a robust communication system between your main app and mini apps using the Event Bus pattern. Adapt the implementation details to your specific project requirements.