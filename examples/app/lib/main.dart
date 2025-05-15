import 'dart:async';

import 'package:app/core/error_handling/app_error_manager.dart';

import 'package:app/core/loggers/logger.dart';
import 'package:app/navigation/app_navigation.dart';
import 'package:app/presentation/app.dart';
import 'package:flutter/material.dart';

import 'di/di.dart';

void main() {
  // Initialize the logger
  AppLogger().initLogger();

  // Initialize the global app error manager
  AppErrorManager().initialize(
    navigatorKey: AppNavigation.navigatorKey,
    scaffoldMessengerKey: AppNavigation.scaffoldMessengerKey,
  );

  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    // Initialize dependency injection
    await setupDependencyInjection();

    runApp(
      MyApp(
        navigatorKey: AppNavigation.navigatorKey,
        scaffoldMessengerKey: AppNavigation.scaffoldMessengerKey,
      ),
    );
  }, onError);
}

void onError(Object? error, StackTrace stackTrace) {
  // Handle other types of errors
  AppErrorManager().handleError(error, stackTrace, 'ZoneError');
}
