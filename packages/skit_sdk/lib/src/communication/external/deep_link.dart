import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:skit_sdk/src/kit/kit.dart';
import 'package:skit_sdk/src/logger/logger.dart';
import 'package:skit_sdk/src/models/mini_app_manifest.dart';
import 'package:skit_sdk/src/utils/url_pattern_matcher.dart';

part 'deep_link_handler.dart';

typedef OnFallbackDeepLink = void Function(Uri uri);

typedef MiniAppMatcher = MiniAppManifest? Function(Uri uri);

typedef OnMiniAppLink = void Function(MiniAppManifest appManifest);

typedef OnDeepLinkError = void Function(Object error);

typedef OnDeepLinkTrack = void Function(Uri uri);

class DeepLink with LoggerMixin {
  final OnFallbackDeepLink? onFallbackDeepLink;
  final MiniAppMatcher? miniAppMatcher;
  final OnMiniAppLink? onMiniAppLink;
  final OnDeepLinkError? onDeepLinkError;
  final OnDeepLinkTrack? onDeepLinkTrack;

  StreamSubscription? _deepLinkSubscription;
  final _appLinks = AppLinks();

  DeepLink({
    required this.miniAppMatcher,
    required this.onMiniAppLink,
    this.onFallbackDeepLink,
    this.onDeepLinkError,
    this.onDeepLinkTrack,
  }) {
    _initializeDeepLinkHandling();
  }

  void _initializeDeepLinkHandling() async {
    // Attach a listener to the URI stream for incoming deep links
    _deepLinkSubscription = _appLinks.uriLinkStream.listen(
      _handleIncomingDeepLink,
      onError: (err) {
        // Handle any errors from the stream.
        logger.error("Error handling deep link stream: $err", err);
        onDeepLinkError?.call(err);
      },
    );

    // Check if the app was launched from a deep link.
    try {
      final initialUri = await _appLinks.getInitialLink();
      _handleIncomingDeepLink(initialUri);
    } catch (err) {
      // Handle exception when getting the initial URI.
      logger.error("Error getting initial URI: $err", err);
    }
  }

  void _handleIncomingDeepLink(Uri? uri) {
    if (uri == null) {
      return;
    }
    logger.info("Received deep link: $uri");
    onDeepLinkTrack?.call(uri);

    var miniAppManifest = miniAppMatcher?.call(uri);

    if (miniAppManifest != null) {
      final deepLinkParameters = _extractDeepLinkParameters(uri);
      miniAppManifest = miniAppManifest.copyWith(params: deepLinkParameters);
      onMiniAppLink?.call(miniAppManifest);
    } else {
      logger.info("No matching mini app found for deep link: $uri");
      onFallbackDeepLink?.call(uri);
    }
  }

  Map<String, dynamic> _extractDeepLinkParameters(Uri uri) {
    final parameters = <String, dynamic>{};
    uri.queryParameters.forEach((key, value) {
      parameters[key] = value;
    });
    return parameters;
  }

  void dispose() {
    _deepLinkSubscription?.cancel();
  }
}
