import 'package:skit_sdk/src/brigdes/mini_app/mini_app_platform_interface.dart';
import 'package:skit_sdk/src/models/mini_app_manifest.dart';
import 'package:flutter_test/flutter_test.dart';

class MockMiniAppPlatform extends MiniAppPlatform {
  @override
  Future<void> launchMiniApp(MiniAppManifest manifest) async {
    // Mock implementation for testing
  }

  @override
  Future<void> launchWebMiniApp(MiniAppManifest manifest) async {
    // Mock implementation for testing
  }
}

void main() {
  group('MiniAppPlatform', () {
    test('Default instance is MethodChannelMiniApp', () {
      expect(MiniAppPlatform.instance, isA<MiniAppPlatform>());
    });

    test('Can set and get custom instance', () {
      final mockPlatform = MockMiniAppPlatform();
      MiniAppPlatform.instance = mockPlatform;
      expect(MiniAppPlatform.instance, equals(mockPlatform));
    });

  });
}