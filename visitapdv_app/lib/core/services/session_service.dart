import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'token_service.dart';

/// Claves usadas en FlutterSecureStorage.
abstract class StorageKeys {
  static const accessToken  = 'access_token';
  static const refreshToken = 'refresh_token';
  static const userId       = 'user_id';
  static const username     = 'username';
  static const nombreCompleto = 'nombre_completo';
  static const rol          = 'rol';
  static const expiresAt    = 'expires_at';
  static const biometriaEnabled = 'biometria_enabled';
  static const failedAttempts   = 'failed_attempts';
  static const lockoutUntil     = 'lockout_until';
}

/// Gestiona el ciclo de vida completo de la sesión.
@lazySingleton
class SessionService {
  final FlutterSecureStorage _storage;
  final TokenService _tokenService;

  static const int _maxFailedAttempts = 5;
  static const Duration _lockoutDuration = Duration(minutes: 30);

  SessionService(this._storage, this._tokenService);

  // ─── Guardar sesión ────────────────────────────────────────────────────
  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required String userId,
    required String username,
    required String nombreCompleto,
    required String rol,
    required DateTime expiresAt,
  }) async {
    await Future.wait([
      _storage.write(key: StorageKeys.accessToken,    value: accessToken),
      _storage.write(key: StorageKeys.refreshToken,   value: refreshToken),
      _storage.write(key: StorageKeys.userId,         value: userId),
      _storage.write(key: StorageKeys.username,       value: username),
      _storage.write(key: StorageKeys.nombreCompleto, value: nombreCompleto),
      _storage.write(key: StorageKeys.rol,            value: rol),
      _storage.write(key: StorageKeys.expiresAt,      value: expiresAt.toIso8601String()),
      _storage.delete(key: StorageKeys.failedAttempts),
      _storage.delete(key: StorageKeys.lockoutUntil),
    ]);
  }

  // ─── Leer sesión ───────────────────────────────────────────────────────
  Future<String?> getAccessToken()  => _storage.read(key: StorageKeys.accessToken);
  Future<String?> getRefreshToken() => _storage.read(key: StorageKeys.refreshToken);
  Future<String?> getUserId()       => _storage.read(key: StorageKeys.userId);
  Future<String?> getUsername()     => _storage.read(key: StorageKeys.username);
  Future<String?> getNombreCompleto() => _storage.read(key: StorageKeys.nombreCompleto);
  Future<String?> getRol()          => _storage.read(key: StorageKeys.rol);

  Future<bool> get isBiometriaEnabled async {
    final v = await _storage.read(key: StorageKeys.biometriaEnabled);
    return v == 'true';
  }

  Future<void> setBiometriaEnabled(bool enabled) =>
      _storage.write(key: StorageKeys.biometriaEnabled, value: enabled.toString());

  // ─── Estado de sesión ──────────────────────────────────────────────────
  Future<bool> hasValidSession() async {
    final token = await getAccessToken();
    if (token == null) return false;
    return !_tokenService.isExpired(token);
  }

  Future<bool> hasRefreshToken() async {
    final rt = await getRefreshToken();
    return rt != null && rt.isNotEmpty;
  }

  /// Determina si se puede recuperar la sesión con biometría.
  Future<bool> canRecoverSession() async {
    final rt = await getRefreshToken();
    if (rt == null || rt.isEmpty) return false;
    if (await isLockedOut) return false;
    return await isBiometriaEnabled;
  }

  // ─── Cerrar sesión ─────────────────────────────────────────────────────
  Future<void> clearSession() async {
    await Future.wait([
      _storage.delete(key: StorageKeys.accessToken),
      _storage.delete(key: StorageKeys.refreshToken),
      _storage.delete(key: StorageKeys.userId),
      _storage.delete(key: StorageKeys.username),
      _storage.delete(key: StorageKeys.nombreCompleto),
      _storage.delete(key: StorageKeys.rol),
      _storage.delete(key: StorageKeys.expiresAt),
    ]);
  }

  // ─── Control de intentos fallidos ─────────────────────────────────────
  Future<int> getFailedAttempts() async {
    final v = await _storage.read(key: StorageKeys.failedAttempts);
    return int.tryParse(v ?? '0') ?? 0;
  }

  Future<void> registerFailedAttempt() async {
    final current = await getFailedAttempts();
    final next = current + 1;
    await _storage.write(key: StorageKeys.failedAttempts, value: next.toString());

    if (next >= _maxFailedAttempts) {
      final lockUntil = DateTime.now().add(_lockoutDuration);
      await _storage.write(
        key: StorageKeys.lockoutUntil,
        value: lockUntil.toIso8601String(),
      );
    }
  }

  Future<void> resetFailedAttempts() async {
    await _storage.delete(key: StorageKeys.failedAttempts);
    await _storage.delete(key: StorageKeys.lockoutUntil);
  }

  Future<bool> get isLockedOut async {
    final v = await _storage.read(key: StorageKeys.lockoutUntil);
    if (v == null) return false;
    final until = DateTime.tryParse(v);
    if (until == null) return false;
    if (DateTime.now().isAfter(until)) {
      await resetFailedAttempts();
      return false;
    }
    return true;
  }

  Future<DateTime?> get lockoutUntil async {
    final v = await _storage.read(key: StorageKeys.lockoutUntil);
    return v != null ? DateTime.tryParse(v) : null;
  }
}
