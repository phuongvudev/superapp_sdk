import 'package:flutter/material.dart';

typedef OnAppStarted = void Function();
typedef OnAppForegrounded = void Function();
typedef OnAppBackgrounded = void Function();
typedef OnAppClosed = void Function();
typedef OnAppLifecycleStateChanged = void Function(AppLifecycleState state);

/// Main shell for the Super App that provides structure and navigation
class SuperAppShell extends StatefulWidget {
  /// Child widget to display in the shell
  final Widget child;

  /// Callback for when the app is started
  /// This is called when the app is launched
  final OnAppStarted? onAppStarted;

  /// Callback for when the app is foregrounded
  /// This is called when the app comes to the foreground
  final OnAppForegrounded? onAppForegrounded;

  /// Callback for when the app is backgrounded
  /// This is called when the app goes to the background
  final OnAppBackgrounded? onAppBackgrounded;

  /// Callback for when the app is closed
  /// This is called when the app is closed
  final OnAppClosed? onAppClosed;

  /// Callback for when the app lifecycle state changes
  /// This is called when the app lifecycle state changes
  final OnAppLifecycleStateChanged? onChangeAppLifecycleState;

  const SuperAppShell({
    super.key,
    required this.child,
    this.onChangeAppLifecycleState,
    this.onAppStarted,
    this.onAppForegrounded,
    this.onAppBackgrounded,
    this.onAppClosed,
  });

  @override
  State<SuperAppShell> createState() => _SuperAppShellState();

  static SuperAppShell of(BuildContext context) {
    final superAppShell =
        context.findAncestorWidgetOfExactType<SuperAppShell>();
    assert(superAppShell != null, 'No SuperAppShell found in context');
    return superAppShell!;
  }
}

class _SuperAppShellState extends State<SuperAppShell>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Notify app launched
    widget.onAppStarted?.call();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Notify app closed
    widget.onAppClosed?.call();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Notify about lifecycle changes
    widget.onChangeAppLifecycleState?.call(state);
    // Handle specific states
    if (state == AppLifecycleState.resumed) {
      widget.onAppForegrounded?.call();
    } else if (state == AppLifecycleState.paused) {
      widget.onAppBackgrounded?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
