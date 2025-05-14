import 'dart:async';

import 'package:app/core/errors/global_error_handler.dart';
import 'package:app/core/exception/global_exception_handler.dart';
import 'package:app/core/loggers/logger.dart';
import 'package:app/navigation/app_navigation.dart';
import 'package:app/presentation/app.dart';
import 'package:flutter/material.dart';

import 'di/di.dart';

void main() {
  // Initialize the logger
  AppLogger().initLogger();
  // Initialize the global error handler
  GlobalErrorHandler().initialize();
  // Initialize the global exception handler
  GlobalExceptionHandler().initialize(
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
  GlobalErrorHandler().handleError(error, stackTrace, 'ZoneError');
}
