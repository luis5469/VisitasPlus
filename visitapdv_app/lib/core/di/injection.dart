import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import '../../core/services/camera_service.dart';
import '../../core/services/imagen_offline_queue.dart';
import '../../data/datasources/novedad_local_datasource.dart';
import '../../data/datasources/novedad_remote_datasource.dart';
import '../../data/repositories/novedad_repository_impl.dart';
import '../../domain/repositories/novedad_repository.dart';
import '../../presentation/novedades/bloc/novedad_bloc.dart';
import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async {
  // Registros manuales de dependencias externas (sin @injectable)
  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    ),
  );
  getIt.registerLazySingleton<DeviceInfoPlugin>(() => DeviceInfoPlugin());

  await getIt.init();

  // Registros manuales temporales para novedades mientras injection.config.dart
  // no refleje las clases agregadas recientemente.
  if (!getIt.isRegistered<NovedadLocalDataSource>()) {
    getIt.registerLazySingleton<NovedadLocalDataSource>(
      () => NovedadLocalDataSource(),
    );
  }

  if (!getIt.isRegistered<NovedadRemoteDataSource>()) {
    getIt.registerLazySingleton<NovedadRemoteDataSource>(
      () => NovedadRemoteDataSource(getIt()),
    );
  }

  if (!getIt.isRegistered<CameraService>()) {
    getIt.registerLazySingleton<CameraService>(() => CameraService());
  }

  if (!getIt.isRegistered<ImagenOfflineQueue>()) {
    getIt.registerLazySingleton<ImagenOfflineQueue>(
      () => ImagenOfflineQueue(getIt()),
    );
  }

  if (!getIt.isRegistered<NovedadRepository>()) {
    getIt.registerLazySingleton<NovedadRepository>(
      () => NovedadRepositoryImpl(
        getIt(),
        getIt(),
        getIt(),
        getIt(),
        getIt(),
      ),
    );
  }

  if (!getIt.isRegistered<NovedadBloc>()) {
    getIt.registerFactory<NovedadBloc>(
      () => NovedadBloc(getIt(), getIt(), getIt()),
    );
  }
}
