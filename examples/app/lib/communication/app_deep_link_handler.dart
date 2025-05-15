import 'package:app/core/error_handling/app_error.dart';
import 'package:skit_sdk/kit.dart';

final class AppDeepLinkHandler with LoggerMixin implements DeepLinkHandler {
  final MiniAppKit miniApp;

  AppDeepLinkHandler({required this.miniApp});

  @override
  void onFallbackDeepLink(Uri uri) {
    // Handle fallback deep link navigation
    logger.info('Fallback deep link received: $uri');
  }

  @override
  void onMiniAppLink(MiniAppManifest appManifest) {
    logger.info('Mini app deep link received: ${appManifest.appId}');
    try {
      miniApp.launch(appManifest.appId, params: appManifest.params);
      logger.info('Launching mini app from deep link: ${appManifest.appId}');
    } catch (e, stackTrace) {
      throw AppError(
        message:
            'Failed to launch mini app ${appManifest.appId} from deep link',
        error: e,
        source: source,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  MiniAppManifest? miniAppMatcher(Uri uri) {
    try {
      // Find the mini app manifest that matches the deep link
      final matchingManifest = miniApp.registeredMiniApps.firstWhere(
        (manifest) =>
            manifest.deepLinks?.any(
              (deepLinkPattern) =>
                  UrlPatternMatcher.isDeepLinkMatching(deepLinkPattern, uri),
            ) ??
            false,
      );
      logger.info('Matching mini app found: ${matchingManifest.appId}');
      // If a matching manifest is found, return it
      return matchingManifest;
    } catch (e, stackTrace) {
      throw AppError(
        message: 'Failed to match mini app for deep link: $uri',
        source: source,
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  void onDeepLinkTrack(Uri uri) {
    logger.info('Deep link track received: $uri');
  }
}
