import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

/// Verificar sesión existente al arrancar la app (splash).
class AuthCheckSessionRequested extends AuthEvent {
  const AuthCheckSessionRequested();
}

/// Login con usuario + contraseña.
class AuthLoginRequested extends AuthEvent {
  final String usernameOrEmail;
  final String password;
  const AuthLoginRequested({
    required this.usernameOrEmail,
    required this.password,
  });
  @override
  List<Object?> get props => [usernameOrEmail, password];
}

/// Login con biometría (recuperación de sesión).
class AuthBiometricLoginRequested extends AuthEvent {
  const AuthBiometricLoginRequested();
}

/// Renovar access token con refresh token.
class AuthRefreshRequested extends AuthEvent {
  const AuthRefreshRequested();
}

/// Cerrar sesión.
class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

/// Sesión expiró (disparado por interceptor).
class AuthSessionExpired extends AuthEvent {
  const AuthSessionExpired();
}

/// Activar/desactivar biometría.
class AuthBiometricToggleRequested extends AuthEvent {
  final bool enable;
  const AuthBiometricToggleRequested(this.enable);
  @override
  List<Object?> get props => [enable];
}
