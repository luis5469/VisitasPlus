import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../../core/services/session_service.dart';
import '../../../core/di/injection.dart';

class SessionRecoveryPage extends StatefulWidget {
  const SessionRecoveryPage({super.key});

  @override
  State<SessionRecoveryPage> createState() => _SessionRecoveryPageState();
}

class _SessionRecoveryPageState extends State<SessionRecoveryPage> {
  String? _username;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final sessionService = getIt<SessionService>();
    final name = await sessionService.getUsername();
    if (mounted) setState(() => _username = name);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        setState(() => _isLoading = state is AuthLoading);
        if (state is AuthAuthenticated) {
          context.go('/home');
        } else if (state is AuthUnauthenticated || state is AuthBiometricUnavailable) {
          context.go('/login');
        } else if (state is AuthLockedOut) {
          context.go('/lockout');
        }
      },
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Ícono de candado / biometría
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.fingerprint_rounded,
                    size: 48,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'Bienvenido de nuevo',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (_username != null)
                  Text(
                    _username!,
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                const SizedBox(height: 12),
                Text(
                  'Tu sesión ha expirado. Usa tu huella digital para continuar.',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 48),

                // Botón biometría
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  FilledButton.icon(
                    onPressed: () => context
                        .read<AuthBloc>()
                        .add(const AuthBiometricLoginRequested()),
                    icon: const Icon(Icons.fingerprint_rounded, size: 22),
                    label: const Text('Acceder con huella digital'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      textStyle: textTheme.titleMedium,
                    ),
                  ),
                const SizedBox(height: 16),

                // Acceder con contraseña
                OutlinedButton(
                  onPressed: () => context.go('/login'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                  child: const Text('Iniciar sesión con contraseña'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
