import 'package:flutter/material.dart';

final class AppNavigation {
  static final AppNavigation _instance = AppNavigation._internal();

  factory AppNavigation() => _instance;

  AppNavigation._internal();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();


}
