/// Constants for all event bus event names used throughout the application`
final class EventNameConstants {
  // App lifecycle events
  static const String appLaunched = 'app_launched';
  static const String appClosed = 'app_closed';
  static const String appUpdated = 'app_updated';
  static const String appError = 'app_error';
  static const String appStateChanged = 'app_state_changed';
  static const String appForegrounded = 'app_foregrounded';
  static const String appBackgrounded = 'app_backgrounded';

  // Mini app lifecycle events
  static const String miniAppLaunched = 'mini_app_launched';
  static const String miniAppClosed = 'mini_app_closed';
  static const String miniAppUpdated = 'mini_app_updated';

  // Communication events
  static const String miniAppResult = 'miniAppResult';
  static const String miniAppRequest = 'miniAppRequest';
  static const String mainAppData = 'mainAppData';

  // Request types
  static const String requestNavigation = 'navigation';
  static const String requestUserData = 'userData';

  // Response prefix
  static const String responsePrefix = 'response_';

  /// Helper method to create a response event name for a given request type
  static String getResponseEvent(String requestType) => '$responsePrefix$requestType';
}