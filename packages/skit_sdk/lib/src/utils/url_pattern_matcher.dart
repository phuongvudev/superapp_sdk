import 'package:skit_sdk/src/logger/logger.dart';

/// A utility class for matching URIs or strings against URL patterns.
class UrlPatternMatcher {
  /// Checks if a given string/URI matches a pattern.
  ///
  /// [pattern] - The pattern to match against. It can include
  /// wildcards (*) to represent variable parts of the pattern.
  /// [value] - The string or URI to be checked against the pattern.
  /// [enableLogging] - Optional flag to enable/disable logging.
  ///
  /// Returns `true` if the value matches the pattern, otherwise `false`.
  static bool matches(
    String pattern,
    dynamic value, {
    bool enableLogging = false,
  }) {
    final String valueStr = value.toString();

    if (enableLogging) {
      final Logger logger = LogManager().getLogger("UrlPatternMatcher");
      logger.debug("Matching pattern: $pattern, value: $valueStr");
    }

    if (pattern.contains("*")) {
      // Replace wildcard (*) with a regex pattern (.*) to match variable parts.
      final regexPattern = pattern.replaceAll("*", ".*");
      final regex = RegExp("^$regexPattern\$");

      // Check if the value matches the regex pattern.
      return regex.hasMatch(valueStr);
    } else {
      // Perform an exact match if no wildcard is present.
      return pattern == valueStr;
    }
  }

  /// Alias for backward compatibility with DeepLinkMatcher
  static bool isDeepLinkMatching(String deepLinkPattern, Uri uri) {
    return matches(deepLinkPattern, uri);
  }
}
