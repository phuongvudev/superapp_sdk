
import 'package:flutter/material.dart';
import 'package:skit_sdk/src/app_shell/super_mini_app_container.dart';
import 'package:skit_sdk/src/models/mini_app_manifest.dart';

/// Main shell for the Super App that provides structure and navigation
class SuperAppShell extends StatefulWidget {
  /// AppBar to display at the top of the shell
  final PreferredSizeWidget? appBar;

  /// Function to build the navigation component
  final Widget Function(BuildContext context)? navigationBuilder;

  /// Container for displaying mini apps
  final SuperMiniAppContainer? miniAppContainer;

  /// Callback when a mini app is successfully loaded
  final Function(MiniAppManifest miniApp)? onMiniAppLoaded;

  /// Callback when there's an error loading a mini app
  final Function(MiniAppManifest miniApp, dynamic error)? onMiniAppError;

  /// Child widget to display in the shell
  final Widget? child;

  const SuperAppShell({
    super.key,
    this.appBar,
    this.navigationBuilder,
    this.miniAppContainer,
    this.onMiniAppLoaded,
    this.onMiniAppError,
    this.child,
  });

  @override
  State<SuperAppShell> createState() => _SuperAppShellState();
}

class _SuperAppShellState extends State<SuperAppShell> {
  MiniAppManifest? _currentMiniApp;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.appBar,
      body: Column(
        children: [
          Expanded(
            child: widget.miniAppContainer ??
                SuperMiniAppContainer(
                  isLoading: _isLoading,
                  child: widget.child ?? const Center(
                    child: Text('Welcome to your Super App'),
                  ),
                ),
          ),
        ],
      ),
      bottomNavigationBar: widget.navigationBuilder != null
          ? widget.navigationBuilder!(context)
          : null,
    );
  }

  void _loadMiniApp(MiniAppManifest miniApp) {
    setState(() {
      _isLoading = true;
      _currentMiniApp = miniApp;
    });

    // Simulate loading of mini app
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        widget.onMiniAppLoaded?.call(miniApp);
      }
    });
  }

  void _handleMiniAppError(MiniAppManifest miniApp, dynamic error) {
    setState(() {
      _isLoading = false;
    });
    widget.onMiniAppError?.call(miniApp, error);
  }
}