import 'package:skit_sdk/src/logger/logger.dart';

class TestConfiguration {
  final String environment;
  final LogLevel logLevel;
  final bool mockServices;

  const TestConfiguration({
    required this.environment,
    required this.logLevel,
    this.mockServices = false,
  });
}
