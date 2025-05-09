import 'package:flutter/material.dart';
import 'package:skit_sdk/src/models/mini_app_manifest.dart';

typedef MiniAppSplashScreenBuilder = Widget Function(BuildContext context);

/// Container for displaying mini apps
class SuperMiniAppContainer extends StatelessWidget {
  final MiniAppSplashScreenBuilder splashScreenBuilder;
  final MiniAppManifest? miniApp;

  const SuperMiniAppContainer({
    super.key,
    required this.splashScreenBuilder,
    this.miniApp,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: splashScreenBuilder(context)),
    );
  }
}
