import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/auth/bloc/auth_bloc.dart';
import '../../presentation/auth/bloc/auth_state.dart';
import '../../presentation/auth/pages/login_page.dart';
import '../../presentation/auth/pages/splash_page.dart';
import '../../presentation/auth/pages/session_recovery_page.dart';
import '../../presentation/auth/pages/lockout_page.dart';
import '../../presentation/home/pages/home_page.dart';
import '../../presentation/home/pages/main_navigation_page.dart';
import '../../presentation/visitas/pages/pdv_list_page.dart';
import '../../presentation/visitas/pages/pdv_detail_page.dart';
import '../../presentation/visitas/pages/iniciar_visita_page.dart';
import '../../presentation/visitas/pages/finalizar_visita_page.dart';
import '../../presentation/visitas/pages/historial_page.dart';
import '../../presentation/novedades/pages/novedades_list_page.dart';
import '../../presentation/novedades/pages/crear_novedad_page.dart';
import '../../presentation/novedades/pages/novedad_detalle_page.dart';
import '../../presentation/novedades/pages/novedad_timeline_page.dart';
import '../../presentation/novedades/pages/adjuntar_fotos_page.dart';
import '../../presentation/novedades/bloc/novedad_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/di/injection.dart';

/// Rutas públicas: no redirigen aunque el usuario no esté autenticado.
const _publicRoutes = ['/splash', '/login', '/session-recovery', '/lockout'];

class AppRouter {
  AppRouter._();

  static GoRouter createRouter(AuthBloc authBloc) {
    return GoRouter(
      initialLocation: '/splash',
      refreshListenable: _AuthStateNotifier(authBloc),
      redirect: (context, routerState) {
        final state = authBloc.state;
        final location = routerState.matchedLocation;
        final isPublic = _publicRoutes.contains(location);

        if (state is AuthAuthenticated && isPublic) {
          return '/home';
        }
        if (state is AuthLockedOut && location != '/lockout') {
          return '/lockout';
        }
        if ((state is AuthUnauthenticated ||
                state is AuthSessionExpiredState) &&
            !isPublic) {
          return '/login';
        }
        return null; // sin redirección
      },
      routes: [
        GoRoute(
          path: '/splash',
          name: 'splash',
          builder: (context, state) => const SplashPage(),
        ),
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/session-recovery',
          name: 'session-recovery',
          builder: (context, state) => const SessionRecoveryPage(),
        ),
        GoRoute(
          path: '/lockout',
          name: 'lockout',
          builder: (context, state) => const LockoutPage(),
        ),
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) => BlocProvider(
            create: (_) => getIt<NovedadBloc>(),
            child: const MainNavigationPage(),
          ),
        ),
        GoRoute(
          path: '/pdv',
          name: 'pdv-list',
          builder: (context, state) => const PdvListPage(),
        ),
        GoRoute(
          path: '/pdv/:id',
          name: 'pdv-detail',
          builder: (context, state) =>
              PdvDetailPage(pdvId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/visitas/iniciar/:pdvId',
          name: 'iniciar-visita',
          builder: (context, state) =>
              IniciarVisitaPage(pdvId: state.pathParameters['pdvId']!),
        ),
        GoRoute(
          path: '/visitas/finalizar/:visitaId',
          name: 'finalizar-visita',
          builder: (context, state) =>
              FinalizarVisitaPage(visitaId: state.pathParameters['visitaId']!),
        ),
        GoRoute(
          path: '/historial',
          name: 'historial',
          builder: (context, state) => const HistorialPage(),
        ),
        // ── Novedades ──────────────────────────────────────────────────────
        GoRoute(
          path: '/novedades',
          name: 'novedades-list',
          builder: (context, state) => BlocProvider(
            create: (_) => getIt<NovedadBloc>(),
            child: NovedadesListPage(
              visitaId: state.uri.queryParameters['visitaId'],
            ),
          ),
        ),
        GoRoute(
          path: '/novedades/crear',
          name: 'crear-novedad',
          builder: (context, state) => BlocProvider(
            create: (_) => getIt<NovedadBloc>(),
            child: CrearNovedadPage(
              visitaId:
                  state.uri.queryParameters['visitaId'] ?? '',
              pdvId: state.uri.queryParameters['pdvId'] ?? '',
            ),
          ),
        ),
        GoRoute(
          path: '/novedades/:id',
          name: 'novedad-detalle',
          builder: (context, state) => BlocProvider(
            create: (_) => getIt<NovedadBloc>(),
            child: NovedadDetallePage(
                novedadId: state.pathParameters['id']!),
          ),
        ),
        GoRoute(
          path: '/novedades/:id/timeline',
          name: 'novedad-timeline',
          builder: (context, state) => BlocProvider(
            create: (_) => getIt<NovedadBloc>(),
            child: NovedadTimelinePage(
                novedadId: state.pathParameters['id']!),
          ),
        ),
        GoRoute(
          path: '/novedades/:id/fotos',
          name: 'novedad-fotos',
          builder: (context, state) => BlocProvider(
            create: (_) => getIt<NovedadBloc>(),
            child: AdjuntarFotosPage(
              novedadId: state.pathParameters['id']!,
              usuarioNombre:
                  state.uri.queryParameters['usuario'] ?? 'Usuario',
            ),
          ),
        ),
      ],
    );
  }
}

/// Notifica a GoRouter cuando cambia el AuthBloc.
class _AuthStateNotifier extends ChangeNotifier {
  final AuthBloc _bloc;
  late final _subscription;

  _AuthStateNotifier(this._bloc) {
    _subscription = _bloc.stream.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
