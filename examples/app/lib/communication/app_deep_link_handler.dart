import 'package:injectable/injectable.dart';
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
    } catch (e, stackTrace) {
      logger.error(
        'Failed to launch mini app from deep link: ${appManifest.appId}',
        e,
        stackTrace,
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

      return matchingManifest;
    } catch (e) {
      logger.error("Error matching mini app for deep link: $e", e);
      return null;
    }
  }

  @override
  void onDeepLinkTrack(Uri uri) {
    // TODO: implement trackDeepLink
  }

}
