// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:app/communication/app_event_bus_handler.dart' as _i638;
import 'package:app/core/config/app_manager.dart' as _i677;
import 'package:app/mini_app/mini_app_repository.dart' as _i65;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.factory<_i65.MiniAppRepository>(() => _i65.MiniAppRepository());
    await gh.singletonAsync<_i677.AppManager>(() {
      final i = _i677.AppManager();
      return i.initialize().then((_) => i);
    }, preResolve: true);
    gh.lazySingleton<_i638.AppEventBusManager>(
      () => _i638.AppEventBusManager(gh<_i677.AppManager>())..initialize(),
    );
    return this;
  }
}
