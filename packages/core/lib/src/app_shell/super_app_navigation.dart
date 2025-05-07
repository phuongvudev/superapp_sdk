import 'package:flutter/material.dart';
import '../models/mini_app_manifest.dart';

/// Navigation component for the Super App
class SuperAppNavigation extends StatelessWidget {
  final List<MiniAppManifest>? miniApps;
  final Function(String appId)? onMiniAppSelected;
  final int currentIndex;

  const SuperAppNavigation({
    super.key,
    this.miniApps,
    this.onMiniAppSelected,
    this.currentIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    // Default implementation as a bottom navigation bar
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        if (miniApps != null && miniApps!.isNotEmpty && index < miniApps!.length) {
          onMiniAppSelected?.call(miniApps![index].appId);
        }
      },
      items: miniApps?.map((app) => BottomNavigationBarItem(
        icon: Icon(Icons.apps),
        label: app.name,
      )).toList() ?? [const BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'Home',
      )],
    );
  }
}