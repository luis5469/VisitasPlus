import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String userId;
  final String username;
  final String nombreCompleto;
  final String rol;
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;
  final bool biometriaHabilitada;

  const UserEntity({
    required this.userId,
    required this.username,
    required this.nombreCompleto,
    required this.rol,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    this.biometriaHabilitada = false,
  });

  bool get isAdmin => rol == 'Administrador';
  bool get isSupervisor => rol == 'Supervisor';

  @override
  List<Object?> get props => [userId, username, rol, accessToken];
}

