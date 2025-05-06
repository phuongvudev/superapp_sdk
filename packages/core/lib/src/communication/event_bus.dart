import 'dart:async';
import 'dart:convert';
import 'package:core/src/constants/method_channel.dart';
import 'package:core/src/encrypt/encryptor.dart';
import 'package:core/src/models/event.dart';
import 'package:flutter/services.dart';

/// EventBus class for managing communication between different parts of the app.
///
/// This class supports dispatching events, listening to events, and handling
/// communication with native platforms. It also supports optional encryption
/// for secure data transmission.
class EventBus {
  /// Map to store event handlers for specific event types.
  final Map<String, List<Function(dynamic)>> _eventHandlers = {};

  /// StreamController for broadcasting events to listeners.
  final StreamController<Event> _eventStreamController =
      StreamController<Event>.broadcast();

  /// MethodChannel for communicating with native platforms.
  final MethodChannel _platformMethodChannel =
      const MethodChannel(MethodChannelConstants.methodChannelEventBus);

  /// EventChannel for receiving events from native platforms.
  final EventChannel _eventChannel =
      const EventChannel(MethodChannelConstants.eventChannelEventBus);

  /// Optional encryptor for encrypting and decrypting event data.
  MapEncryptor? encryptor;

  /// Singleton instance of EventBus.
  static final EventBus _instance = EventBus._internal();

  /// Factory constructor to return the singleton instance.
  factory EventBus({MapEncryptor? encryptor, String? encryptionKey}){
    // If an instance already exists, return it.
    if (encryptor == null && encryptionKey == null) {
      _instance._setEncryptor(encryptor, encryptionKey);
    }
    return _instance;
  }

  /// Private constructor for singleton pattern.
  EventBus._internal() {
    // Set up a handler for method calls from the native platform.
    _platformMethodChannel.setMethodCallHandler(_onNativeMethodCall);

    _eventChannel.receiveBroadcastStream().listen((event) {
      // Handle events received from the native platform.
      final type = event['type'] as String;
      var data = event['data'] as String;

      // Decrypt data if an encryptor is set.
      if (encryptor != null) {
        data = encryptor!.decrypt(data).toString();
      }

      // Decode the JSON data and dispatch the event.
      final mapData = jsonDecode(data);
      dispatch(Event(type, mapData));
    });
  }

  /// Sets the encryptor for the EventBus.
  ///
  /// [encryptor] - The encryptor instance to use for encryption and decryption.
  /// [encryptionKey] - The encryption key to use with the encryptor.
  void _setEncryptor(MapEncryptor? encryptor, String? encryptionKey) {
    this.encryptor = encryptor;
    _platformMethodChannel
        .invokeMethod("setEncryptionKey", {"key": encryptionKey});
  }

  /// Handles method calls from the native platform.
  ///
  /// [call] - The method call from the native platform.
  Future<void> _onNativeMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'dispatch':
        final type = call.arguments['type'] as String;
        var data = call.arguments['data'] as String;

        // Decrypt data if an encryptor is set.
        if (encryptor != null) {
          data = encryptor!.decrypt(data).toString();
        }

        // Decode the JSON data and dispatch the event.
        final mapData = jsonDecode(data);
        dispatch(Event(type, mapData));
        break;
    }
  }



  /// Dispatches an event to all listeners and sends it to native platforms.
  ///
  /// [event] - The event to dispatch.
  void dispatch(Event event) {
    // Add the event to the stream for listeners.
    _eventStreamController.sink.add(event);

    // Prepare data for native platforms.
    var data = event.data;
    if (encryptor != null) {
      data = encryptor!.encrypt(data);
    } else {
      data = jsonEncode(event.data);
    }

    // Send the event to the native platform.
    _platformMethodChannel.invokeMethod('dispatch', {
      'type': event.type,
      'data': data,
    });

    // Send the event to React Native specifically.
    _platformMethodChannel.invokeMethod('dispatchReactNative', {
      'type': event.type,
      'data': data,
    });
  }

  /// Returns a stream of events for listening.
  Stream<Event> get eventStream => _eventStreamController.stream;

  /// Registers a callback for a specific event type.
  ///
  /// [type] - The event type to listen for.
  /// [callback] - The function to call when the event is dispatched.
  void on(String type, Function(dynamic) callback) {
    if (!_eventHandlers.containsKey(type)) {
      _eventHandlers[type] = [];
    }
    _eventHandlers[type]!.add(callback);

    // Listen to the event stream and invoke the callback for matching events.
    eventStream.listen((event) {
      if (event.type == type) {
        for (final subscription in _eventHandlers[type]!) {
          subscription(event.data);
        }
      }
    });
  }

  /// Unregisters a callback for a specific event type.
  ///
  /// [type] - The event type to stop listening for.
  /// [callback] - The function to remove from the event handlers.
  void off(String type, Function(dynamic) callback) {
    if (_eventHandlers.containsKey(type)) {
      _eventHandlers[type]!.remove(callback);
      if (_eventHandlers[type]!.isEmpty) {
        _eventHandlers.remove(type);
      }
    }
  }

  /// Closes the EventBus and releases resources.
  Future<void> close() async {
    await _eventStreamController.close();
  }
}
