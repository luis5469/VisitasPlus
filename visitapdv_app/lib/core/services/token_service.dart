import 'dart:convert';
import 'package:injectable/injectable.dart';

/// Decodifica tokens JWT sin validar firma (validación en backend).
@lazySingleton
class TokenService {
  /// Retorna el payload del JWT o null si no es decodificable.
  Map<String, dynamic>? decodePayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final normalized = base64.normalize(parts[1]);
      final decoded = utf8.decode(base64Url.decode(normalized));
      return json.decode(decoded) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// True si el token ha expirado (compara claim "exp" vs ahora).
  bool isExpired(String token) {
    final payload = decodePayload(token);
    if (payload == null) return true;
    final exp = payload['exp'];
    if (exp == null) return true;
    final expiry = DateTime.fromMillisecondsSinceEpoch((exp as int) * 1000);
    return DateTime.now().isAfter(expiry);
  }

  /// Cuánto tiempo falta para expirar. Negativo = ya expiró.
  Duration timeToExpiry(String token) {
    final payload = decodePayload(token);
    if (payload == null) return Duration.zero;
    final exp = payload['exp'];
    if (exp == null) return Duration.zero;
    final expiry = DateTime.fromMillisecondsSinceEpoch((exp as int) * 1000);
    return expiry.difference(DateTime.now());
  }

  /// Extrae el subject (userId) del JWT.
  String? getSubject(String token) => decodePayload(token)?['sub'] as String?;

  /// Retorna true si faltan menos de [threshold] para que expire.
  bool isAboutToExpire(String token, {Duration threshold = const Duration(minutes: 10)}) {
    return timeToExpiry(token) < threshold;
  }
}
