import 'package:equatable/equatable.dart';
import '../../../domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

/// Estado inicial antes del splash check.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Cargando (login, refresh, splash check).
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Usuario autenticado y sesión activa.
class AuthAuthenticated extends AuthState {
  final UserEntity user;
  const AuthAuthenticated(this.user);
  @override
  List<Object?> get props => [user];
}

/// No autenticado — debe ir a login.
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Sesión expirada — puede recuperar con biometría.
class AuthSessionExpiredState extends AuthState {
  final bool canRecoverWithBiometric;
  const AuthSessionExpiredState({this.canRecoverWithBiometric = false});
  @override
  List<Object?> get props => [canRecoverWithBiometric];
}

/// Cuenta bloqueada por intentos fallidos.
class AuthLockedOut extends AuthState {
  final DateTime? lockoutUntil;
  const AuthLockedOut({this.lockoutUntil});
  @override
  List<Object?> get props => [lockoutUntil];
}

/// Error genérico (mensaje a mostrar en UI).
class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object?> get props => [message];
}

/// Biometría no disponible o cancelada.
class AuthBiometricUnavailable extends AuthState {
  const AuthBiometricUnavailable();
}
