import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:visitapdv_app/core/di/injection.dart';
import 'package:visitapdv_app/core/router/app_router.dart';
import 'package:visitapdv_app/core/bloc/app_bloc_observer.dart';
import 'package:visitapdv_app/core/theme/app_theme.dart';
import 'package:visitapdv_app/core/services/connectivity_service.dart';
import 'package:visitapdv_app/core/services/sync_service.dart';
import 'package:visitapdv_app/data/local/models/pdv_hive_model.dart';
import 'package:visitapdv_app/data/local/models/visita_hive_model.dart';
import 'package:visitapdv_app/data/local/models/sync_queue_item.dart';
import 'package:visitapdv_app/data/local/models/novedad_hive_model.dart';
import 'package:visitapdv_app/data/datasources/novedad_local_datasource.dart';
import 'package:visitapdv_app/core/services/imagen_offline_queue.dart';
import 'package:visitapdv_app/presentation/auth/bloc/auth_bloc.dart';
import 'package:visitapdv_app/presentation/visitas/bloc/visita_bloc.dart';
import 'package:visitapdv_app/presentation/visitas/bloc/pdv_bloc.dart';
import 'package:visitapdv_app/presentation/visitas/bloc/connectivity_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Hive
  await Hive.initFlutter();
  Hive
    ..registerAdapter(PdvHiveModelAdapter())
    ..registerAdapter(VisitaHiveModelAdapter())
    ..registerAdapter(SyncQueueItemAdapter())
    ..registerAdapter(NovedadHiveModelAdapter())
    ..registerAdapter(NovedadImagenHiveModelAdapter());
  await Future.wait([
    Hive.openBox<PdvHiveModel>('pdvs'),
    Hive.openBox<VisitaHiveModel>('visitas'),
  ]);

  await configureDependencies();

  // Inicializar servicios con estado (ya pre-resueltos de forma síncrona)
  getIt<ConnectivityService>();
  getIt<SyncService>();

  Bloc.observer = AppBlocObserver();
  runApp(const VisitaPDVApp());
}

class VisitaPDVApp extends StatefulWidget {
  const VisitaPDVApp({super.key});

  @override
  State<VisitaPDVApp> createState() => _VisitaPDVAppState();
}

class _VisitaPDVAppState extends State<VisitaPDVApp> {
  late final AuthBloc _authBloc;
  late final _router;

  @override
  void initState() {
    super.initState();
    _authBloc = getIt<AuthBloc>();
    _router = AppRouter.createRouter(_authBloc);
  }

  @override
  void dispose() {
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authBloc),
        BlocProvider(create: (_) => getIt<ConnectivityCubit>()),
        BlocProvider(create: (_) => getIt<PdvBloc>()),
        BlocProvider(create: (_) => getIt<VisitaBloc>()),
      ],
      child: MaterialApp.router(
        title: 'VisitaPDV',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        routerConfig: _router,
      ),
    );
  }
}
