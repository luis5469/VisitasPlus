// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:device_info_plus/device_info_plus.dart' as _i833;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:visitapdv_app/core/network/api_client.dart' as _i500;
import 'package:visitapdv_app/core/network/interceptors/auth_interceptor.dart'
    as _i147;
import 'package:visitapdv_app/core/services/biometric_service.dart' as _i562;
import 'package:visitapdv_app/core/services/camera_service.dart' as _i146;
import 'package:visitapdv_app/core/services/connectivity_service.dart' as _i72;
import 'package:visitapdv_app/core/services/gps_service.dart' as _i1062;
import 'package:visitapdv_app/core/services/imagen_offline_queue.dart' as _i273;
import 'package:visitapdv_app/core/services/session_service.dart' as _i253;
import 'package:visitapdv_app/core/services/sync_service.dart' as _i422;
import 'package:visitapdv_app/core/services/token_service.dart' as _i933;
import 'package:visitapdv_app/data/datasources/auth_remote_datasource.dart'
    as _i26;
import 'package:visitapdv_app/data/datasources/novedad_local_datasource.dart'
    as _i116;
import 'package:visitapdv_app/data/datasources/novedad_remote_datasource.dart'
    as _i859;
import 'package:visitapdv_app/data/datasources/visita_local_datasource.dart'
    as _i780;
import 'package:visitapdv_app/data/datasources/visita_remote_datasource.dart'
    as _i53;
import 'package:visitapdv_app/data/repositories/auth_repository_impl.dart'
    as _i311;
import 'package:visitapdv_app/data/repositories/novedad_repository_impl.dart'
    as _i817;
import 'package:visitapdv_app/data/repositories/visita_repository_impl.dart'
    as _i655;
import 'package:visitapdv_app/domain/repositories/auth_repository.dart'
    as _i677;
import 'package:visitapdv_app/domain/repositories/novedad_repository.dart'
    as _i891;
import 'package:visitapdv_app/domain/repositories/visita_repository.dart'
    as _i851;
import 'package:visitapdv_app/domain/usecases/check_session_usecase.dart'
    as _i568;
import 'package:visitapdv_app/domain/usecases/login_usecase.dart' as _i839;
import 'package:visitapdv_app/domain/usecases/logout_usecase.dart' as _i482;
import 'package:visitapdv_app/domain/usecases/refresh_token_usecase.dart'
    as _i339;
import 'package:visitapdv_app/presentation/auth/bloc/auth_bloc.dart' as _i702;
import 'package:visitapdv_app/presentation/novedades/bloc/novedad_bloc.dart'
    as _i26;
import 'package:visitapdv_app/presentation/visitas/bloc/connectivity_cubit.dart'
    as _i202;
import 'package:visitapdv_app/presentation/visitas/bloc/pdv_bloc.dart' as _i582;
import 'package:visitapdv_app/presentation/visitas/bloc/visita_bloc.dart'
    as _i1004;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.lazySingleton<_i562.BiometricService>(() => _i562.BiometricService());
    gh.lazySingleton<_i146.CameraService>(() => _i146.CameraService());
    await gh.lazySingletonAsync<_i72.ConnectivityService>(
      () {
        final i = _i72.ConnectivityService();
        return i.init().then((_) => i);
      },
      preResolve: true,
    );
    gh.lazySingleton<_i1062.GpsService>(() => _i1062.GpsService());
    gh.lazySingleton<_i933.TokenService>(() => _i933.TokenService());
    await gh.lazySingletonAsync<_i116.NovedadLocalDataSource>(
      () {
        final i = _i116.NovedadLocalDataSource();
        return i.init().then((_) => i);
      },
      preResolve: true,
    );
    gh.lazySingleton<_i780.VisitaLocalDataSource>(
        () => _i780.VisitaLocalDataSource());
    gh.factory<_i202.ConnectivityCubit>(
        () => _i202.ConnectivityCubit(gh<_i72.ConnectivityService>()));
    gh.lazySingleton<_i253.SessionService>(() => _i253.SessionService(
          gh<_i558.FlutterSecureStorage>(),
          gh<_i933.TokenService>(),
        ));
    gh.lazySingleton<_i147.AuthInterceptor>(() => _i147.AuthInterceptor(
          gh<_i558.FlutterSecureStorage>(),
          gh<_i933.TokenService>(),
          gh<_i253.SessionService>(),
        ));
    gh.lazySingleton<_i500.ApiClient>(
        () => _i500.ApiClient(gh<_i147.AuthInterceptor>()));
    gh.lazySingleton<_i26.AuthRemoteDataSource>(() => _i26.AuthRemoteDataSource(
          gh<_i500.ApiClient>(),
          gh<_i833.DeviceInfoPlugin>(),
        ));
    gh.lazySingleton<_i859.NovedadRemoteDataSource>(
        () => _i859.NovedadRemoteDataSource(gh<_i500.ApiClient>()));
    gh.lazySingleton<_i53.VisitaRemoteDataSource>(
        () => _i53.VisitaRemoteDataSource(gh<_i500.ApiClient>()));
    await gh.lazySingletonAsync<_i422.SyncService>(
      () {
        final i = _i422.SyncService(
          gh<_i500.ApiClient>(),
          gh<_i72.ConnectivityService>(),
        );
        return i.init().then((_) => i);
      },
      preResolve: true,
    );
    await gh.lazySingletonAsync<_i273.ImagenOfflineQueue>(
      () {
        final i = _i273.ImagenOfflineQueue(gh<_i859.NovedadRemoteDataSource>());
        return i.init().then((_) => i);
      },
      preResolve: true,
    );
    gh.lazySingleton<_i851.VisitaRepository>(() => _i655.VisitaRepositoryImpl(
          gh<_i53.VisitaRemoteDataSource>(),
          gh<_i780.VisitaLocalDataSource>(),
          gh<_i72.ConnectivityService>(),
          gh<_i422.SyncService>(),
        ));
    gh.lazySingleton<_i677.AuthRepository>(() => _i311.AuthRepositoryImpl(
          gh<_i26.AuthRemoteDataSource>(),
          gh<_i253.SessionService>(),
        ));
    gh.lazySingleton<_i568.CheckSessionUseCase>(
        () => _i568.CheckSessionUseCase(gh<_i677.AuthRepository>()));
    gh.lazySingleton<_i839.LoginUseCase>(
        () => _i839.LoginUseCase(gh<_i677.AuthRepository>()));
    gh.lazySingleton<_i482.LogoutUseCase>(
        () => _i482.LogoutUseCase(gh<_i677.AuthRepository>()));
    gh.lazySingleton<_i339.RefreshTokenUseCase>(
        () => _i339.RefreshTokenUseCase(gh<_i677.AuthRepository>()));
    gh.lazySingleton<_i891.NovedadRepository>(() => _i817.NovedadRepositoryImpl(
          gh<_i859.NovedadRemoteDataSource>(),
          gh<_i116.NovedadLocalDataSource>(),
          gh<_i72.ConnectivityService>(),
          gh<_i422.SyncService>(),
          gh<_i273.ImagenOfflineQueue>(),
        ));
    gh.factory<_i582.PdvBloc>(
        () => _i582.PdvBloc(gh<_i851.VisitaRepository>()));
    gh.factory<_i1004.VisitaBloc>(
        () => _i1004.VisitaBloc(gh<_i851.VisitaRepository>()));
    gh.factory<_i702.AuthBloc>(() => _i702.AuthBloc(
          gh<_i839.LoginUseCase>(),
          gh<_i482.LogoutUseCase>(),
          gh<_i339.RefreshTokenUseCase>(),
          gh<_i568.CheckSessionUseCase>(),
          gh<_i253.SessionService>(),
          gh<_i562.BiometricService>(),
          gh<_i933.TokenService>(),
        ));
    gh.factory<_i26.NovedadBloc>(() => _i26.NovedadBloc(
          gh<_i891.NovedadRepository>(),
          gh<_i146.CameraService>(),
          gh<_i273.ImagenOfflineQueue>(),
        ));
    return this;
  }
}
