import 'package:app/core/config/app_manager.dart';
import 'package:app/constants/event_bus.dart';
import 'package:injectable/injectable.dart';
import 'package:skit_sdk/kit.dart';

@lazySingleton
class AppEventBusHandler with LoggerMixin {
  final AppManager _appManager;

  /// Get access to the event bus
  EventBus get _eventBus => _appManager.superAppKit.eventBus;

  AppEventBusHandler(this._appManager);

  @postConstruct
  void initialize() {
    // Subscribe to events from mini apps
    _eventBus.on(EventNameConstants.miniAppResult, (data) {
      handleMiniAppResult(data);
    });

    _eventBus.on(EventNameConstants.miniAppRequest, (data) {
      handleMiniAppRequest(data);
    });

    // Listen for mini app lifecycle events
    _eventBus.on(EventNameConstants.miniAppLaunched, (data) {
      logger.info('Mini app launched: ${data['appId']}');
    });

    _eventBus.on(EventNameConstants.miniAppClosed, (data) {
      logger.info('Mini app closed: ${data['appId']}');
    });

    logger.info('AppEventBusHandler initialized');
  }

  void broadcastEvent(String eventName, Map<String, dynamic> data) {
    logger.debug('Broadcasting event: $eventName');
    _eventBus.dispatch(Event(eventName, data));
  }

  void sendDataToMiniApp(String miniAppId, Map<String, dynamic> data) {
    logger.debug('Sending data to mini app: $miniAppId');
    _eventBus.dispatch(
      Event(EventNameConstants.mainAppData, {
        'targetMiniAppId': miniAppId,
        'data': data,
      }),
    );
  }

  void handleMiniAppResult(dynamic data) {
    try {
      // Process mini app results
      final miniAppId = data['miniAppId'];
      final result = data['result'];
      logger.info('Received result from mini app $miniAppId: $result');

      // Additional processing logic can be added here
    } catch (e, stackTrace) {
      logger.error('Error handling mini app result', e, stackTrace);
    }
  }

  void handleMiniAppRequest(dynamic data) {
    try {
      // Handle various requests from mini apps
      final miniAppId = data['miniAppId'];
      final requestType = data['requestType'];
      final params = data['params'];

      logger.debug('Handling request from mini app $miniAppId: $requestType');

      switch (requestType) {
        case EventNameConstants.requestNavigation:
          // Navigation handling
          break;
        case EventNameConstants.requestUserData:
          // Send user data to mini app
          _eventBus.dispatch(
            Event(EventNameConstants.getResponseEvent(requestType), {
              'miniAppId': miniAppId,
              'data': getUserData(),
            }),
          );
          break;
        // Other request types
        default:
          logger.warning('Unknown request type from mini app: $requestType');
      }
    } catch (e, stackTrace) {
      logger.error('Error handling mini app request', e, stackTrace);
    }
  }

  Map<String, dynamic> getUserData() {
    // Implementation for getting user data
    return {
      'userId': 'user_123',
      'name': 'Test User',
      'email': 'test@example.com',
    };
  }

  void notifyAppLifecycleChange(String state) {
    broadcastEvent(EventNameConstants.appStateChanged, {'state': state});
  }

  void notifyAppForegrounded() {
    broadcastEvent(EventNameConstants.appForegrounded, {});
  }

  void notifyAppBackgrounded() {
    broadcastEvent(EventNameConstants.appBackgrounded, {});
  }
}
