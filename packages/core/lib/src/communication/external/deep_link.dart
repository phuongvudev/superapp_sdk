import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:core/src/communication/external/deep_link_matcher.dart';
import 'package:core/src/logger/logger_mixin.dart';
import 'package:core/src/models/mini_app_manifest.dart';
import 'package:core/src/services/mini_app/mini_app_launcher.dart';
import 'package:core/src/constants/framework_type.dart';

class DeepLinkDispatcher with LoggerMixin {
  final MiniAppLauncher miniAppLauncher;

  StreamSubscription? _deepLinkSubscription;
  final _appLinks = AppLinks();

  DeepLinkDispatcher({
    required this.miniAppLauncher,
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

    // Find the mini app manifest that matches the deep link.
    final matchingManifest = miniAppLauncher.registeredMiniApps.firstWhere(
      (manifest) =>
          manifest.deepLinks?.any(
            (deepLinkPattern) =>
                DeepLinkMatcher.isDeepLinkMatching(deepLinkPattern, uri),
          ) ??
          false,
      orElse: () => MiniAppManifest(
        appId: '',
        name: '',
        framework: FrameworkType.unknown,
        entryPath: '',
      ), // Return a default manifest if no match is found.
    );

    if (matchingManifest.appId.isEmpty) {
      logger.info("No matching mini app found for deep link: $uri");
      return;
    }

    // Extract parameters from the deep link.
    final deepLinkParameters = _extractDeepLinkParameters(uri);

    // Launch the mini app associated with the deep link.
    miniAppLauncher.launch(
      matchingManifest.appId,
      params: deepLinkParameters,
    );
  }

  Map<String, dynamic> _extractDeepLinkParameters(Uri uri) {
    final parameters = <String, dynamic>{};
    // Extract query parameters.
    uri.queryParameters.forEach((key, value) {
      parameters[key] = value;
    });
    // You can add logic here to extract parameters from path segments if needed.
    return parameters;
  }

  void dispose() {
    _deepLinkSubscription?.cancel();
  }
}
