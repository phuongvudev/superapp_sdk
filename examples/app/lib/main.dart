import 'dart:async';

import 'package:app/core/loggers/logger.dart';
import 'package:app/presentation/app.dart';
import 'package:flutter/material.dart';

import 'di/di.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    // Initialize dependency injection

    await setupDependencyInjection();
    // Initialize the logger
    initLogger();
    runApp(const MyApp());
  }, onError);
}

void onError(Object? error, StackTrace stackTrace) {
  globalLogger.error('Error in main: $error', error, stackTrace);
}
