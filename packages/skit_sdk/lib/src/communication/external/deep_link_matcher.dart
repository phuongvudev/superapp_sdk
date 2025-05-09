import 'package:skit_sdk/src/logger/logger.dart';

class DeepLinkMatcher {
  /// Checks if a given URI matches a deep link pattern.
  ///
  /// [deepLinkPattern] - The deep link pattern to match against. It can include
  /// wildcards (*) to represent variable parts of the pattern.
  /// [uri] - The URI to be checked against the pattern.
  ///
  /// Returns `true` if the URI matches the pattern, otherwise `false`.
  static bool isDeepLinkMatching(String deepLinkPattern, Uri uri) {
    final Logger logger = LogManager().getLogger("DeepLinkMatcher");
    logger.debug(
        "isDeepLinkMatching deepLinkPattern: $deepLinkPattern, uri: $uri");

    if (deepLinkPattern.contains("*")) {
      // Replace wildcard (*) with a regex pattern (.*) to match variable parts.
      final regexPattern = deepLinkPattern.replaceAll("*", ".*");
      final regex = RegExp("^$regexPattern\$");

      // Check if the URI matches the regex pattern.
      return regex.hasMatch(uri.toString());
    } else {
      // Perform an exact match if no wildcard is present.
      return deepLinkPattern == uri.toString();
    }
  }
}
