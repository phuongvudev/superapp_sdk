import 'package:flutter/material.dart';

/// Container for displaying mini apps
class SuperMiniAppContainer extends StatelessWidget {
  final Widget? child;
  final bool isLoading;

  const SuperMiniAppContainer({
    super.key,
    this.child,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: Colors.white,
      ),
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : child ?? const Center(child: Text('No mini app loaded')),
    );
  }
}