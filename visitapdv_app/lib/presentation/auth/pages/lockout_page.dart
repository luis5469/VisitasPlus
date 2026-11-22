import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LockoutPage extends StatefulWidget {
  const LockoutPage({super.key});

  @override
  State<LockoutPage> createState() => _LockoutPageState();
}

class _LockoutPageState extends State<LockoutPage> {
  Timer? _timer;
  Duration _remaining = Duration.zero;
  DateTime? _lockoutUntil;

  @override
  void initState() {
    super.initState();
    final state = context.read<AuthBloc>().state;
    if (state is AuthLockedOut) {
      _lockoutUntil = state.lockoutUntil;
      _updateRemaining();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        _updateRemaining();
      });
    }
  }

  void _updateRemaining() {
    if (_lockoutUntil == null) return;
    final now = DateTime.now();
    if (now.isAfter(_lockoutUntil!)) {
      _timer?.cancel();
      setState(() => _remaining = Duration.zero);
      // Sesión desbloqueada → ir a login
      if (mounted) context.go('/login');
    } else {
      setState(() => _remaining = _lockoutUntil!.difference(now));
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isUnlocked = _remaining == Duration.zero;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.go('/login');
        }
      },
      child: Scaffold(
        backgroundColor: colorScheme.errorContainer,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_clock_rounded,
                  size: 80,
                  color: colorScheme.onErrorContainer,
                ),
                const SizedBox(height: 24),
                Text(
                  'Cuenta bloqueada',
                  style: textTheme.headlineMedium?.copyWith(
                    color: colorScheme.onErrorContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Has superado el número máximo de intentos fallidos.',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onErrorContainer.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 40),

                // Countdown
                if (!isUnlocked && _lockoutUntil != null) ...[
                  Text(
                    'Podrás intentarlo de nuevo en:',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onErrorContainer.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.error,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _formatDuration(_remaining),
                      style: textTheme.displaySmall?.copyWith(
                        color: colorScheme.onError,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ] else ...[
                  FilledButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(
                            const AuthCheckSessionRequested(),
                          );
                      context.go('/login');
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: colorScheme.onErrorContainer,
                      foregroundColor: colorScheme.errorContainer,
                      minimumSize: const Size.fromHeight(52),
                    ),
                    child: const Text('Ir al inicio de sesión'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
