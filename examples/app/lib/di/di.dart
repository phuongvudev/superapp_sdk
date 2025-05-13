import 'package:app/app/app_manager.dart';
import 'package:app/di/di.config.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:skit_sdk/kit.dart';

import 'di.config.dart';


final getIt = GetIt.instance;

@InjectableInit(
)
Future<void> setupDependencyInjection() async {
  await getIt.init();
}

void initLogger() {
  // Initialize the logger here if needed
  LogManager().addLogSinks([ConsoleLogSink(LogManager.defaultLoggerName)]);

}

AppManager get appManager => getIt<AppManager>();

Logger get globalLogger => LogManager().getLogger('GlobalLogger');
