import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.userId,
    required super.username,
    required super.nombreCompleto,
    required super.rol,
    required super.accessToken,
    required super.refreshToken,
    required super.expiresAt,
    super.biometriaHabilitada = false,
  });

  factory UserModel.fromLoginJson(Map<String, dynamic> json) => UserModel(
        userId: json['userId'] as String? ?? '',
        username: json['username'] as String,
        nombreCompleto: json['nombreCompleto'] as String,
        rol: json['rol'] as String,
        accessToken: json['accessToken'] as String,
        refreshToken: json['refreshToken'] as String,
        expiresAt: DateTime.parse(json['expiresAt'] as String),
      );

  /// Construye desde la respuesta de /auth/me + tokens existentes.
  factory UserModel.fromMeJson(
    Map<String, dynamic> json, {
    required String accessToken,
    required String refreshToken,
    required DateTime expiresAt,
  }) =>
      UserModel(
        userId: (json['id'] as String?) ?? '',
        username: json['username'] as String,
        nombreCompleto: json['nombreCompleto'] as String,
        rol: json['rol'] as String,
        accessToken: accessToken,
        refreshToken: refreshToken,
        expiresAt: expiresAt,
        biometriaHabilitada: json['biometriaHabilitada'] as bool? ?? false,
      );

  UserModel copyWith({
    String? accessToken,
    String? refreshToken,
    DateTime? expiresAt,
  }) =>
      UserModel(
        userId: userId,
        username: username,
        nombreCompleto: nombreCompleto,
        rol: rol,
        accessToken: accessToken ?? this.accessToken,
        refreshToken: refreshToken ?? this.refreshToken,
        expiresAt: expiresAt ?? this.expiresAt,
        biometriaHabilitada: biometriaHabilitada,
      );

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'username': username,
        'nombreCompleto': nombreCompleto,
        'rol': rol,
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'expiresAt': expiresAt.toIso8601String(),
        'biometriaHabilitada': biometriaHabilitada,
      };
}

