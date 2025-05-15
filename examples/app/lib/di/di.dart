import 'package:app/communication/app_event_bus_handler.dart';
import 'package:app/core/config/app_manager.dart';
import 'package:app/di/di.config.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> setupDependencyInjection() async {
  await getIt.init();
}

AppManager get appManager => getIt<AppManager>();

AppEventBusManager get appEventBus =>
    getIt<AppEventBusManager>();
