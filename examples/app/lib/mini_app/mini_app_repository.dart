import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:skit_sdk/kit.dart';

@injectable
final class MiniAppRepository extends MiniAppManifestRepository {
  @override
  Future<Map<String, MiniAppManifest>> loadRegistry() {
    return Future.value({
      'com.superapp_sdk.flutter': MiniAppManifest(
        appId: 'com.superapp_sdk.flutter',
        name: 'Example Flutter App',
        description: 'This is an example mini app built with Flutter.',
        appIcon:
            'https://storage.googleapis.com/cms-storage-bucket/a9d6ce81aee44ae017ee.png',
        version: '1.0.0',
        framework: FrameworkType.flutter,
        params: {'key': 'value'},
        entryPath: 'lib/main.dart',
        appBuilder: (params) {
          return const Center(child: Text("Hello from Flutter Mini App"));
        },
      ),
      'com.superapp_sdk.flutter_web': MiniAppManifest(
        appId: 'com.superapp_sdk.flutter_web',
        name: 'Example Flutter Web App',
        description: 'This is an example mini app built with Flutter Web.',
        appIcon:
            'https://storage.googleapis.com/cms-storage-bucket/a9d6ce81aee44ae017ee.png',
        version: '1.0.0',
        framework: FrameworkType.flutterWeb,
        params: {'key': 'value'},
        entryPath: 'index.html',
      ),
      'com.superapp_sdk.web': MiniAppManifest(
        appId: 'com.superapp_sdk.web',
        name: 'Example Web App',
        description: 'This is an example mini app built with Web.',
        appIcon:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/2/26/Logo_Sitio_Web.png/330px-Logo_Sitio_Web.png',
        version: '1.0.0',
        framework: FrameworkType.web,
        params: {'key': 'value'},
        entryPath: 'index.html',
      ),
      'com.superapp_sdk.react_native': MiniAppManifest(
        appId: 'com.superapp_sdk.react_native',
        name: 'Example React Native App',
        description: 'This is an example mini app built with React Native.',
        appIcon:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a7/React-icon.svg/330px-React-icon.svg.png',
        version: '1.0.0',
        framework: FrameworkType.reactNative,
        params: {'key': 'value'},
        entryPath: 'index.html',
      ),
      'com.superapp_sdk.android_native': MiniAppManifest(
        appId: 'com.superapp_sdk.android_native',
        name: 'Example Android Native App',
        description: 'This is an example mini app built with Android Native.',
        appIcon:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/6/64/Android_logo_2019_%28stacked%29.svg/330px-Android_logo_2019_%28stacked%29.svg.png',
        version: '1.0.0',
        framework: FrameworkType.native,
        params: {'key': 'value'},
        entryPath: 'index.html',
      ),
      'com.superapp_sdk.ios_native': MiniAppManifest(
        appId: 'com.superapp_sdk.ios_native',
        name: 'Example iOS Native App',
        description: 'This is an example mini app built with iOS Native.',
        appIcon:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/Apple_logo_black.svg/250px-Apple_logo_black.svg.png',
        version: '1.0.0',
        framework: FrameworkType.native,
        params: {'key': 'value'},
        entryPath: 'index.html',
      ),
    });
  }

  @override
  void saveRegistry(Map<String, MiniAppManifest> registry) {
    // TODO: implement saveRegistry
  }
}
