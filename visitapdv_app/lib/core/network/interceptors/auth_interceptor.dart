import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import '../../constants/api_constants.dart';
import '../../services/session_service.dart';
import '../../services/token_service.dart';

/// Interceptor que:
/// 1. Adjunta el Bearer token en cada request.
/// 2. Reintenta con refresh token si recibe 401.
/// 3. Limpia sesión si el refresh también falla.
@lazySingleton
class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;
  final TokenService _tokenService;
  final SessionService _sessionService;

  bool _isRefreshing = false;
  final List<Completer<String>> _refreshQueue = [];

  AuthInterceptor(this._storage, this._tokenService, this._sessionService);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final path = options.path;
    // No adjuntar token en endpoints públicos
    if (path == ApiConstants.login || path == ApiConstants.refresh) {
      return handler.next(options);
    }

    var token = await _storage.read(key: StorageKeys.accessToken);

    // Refresh proactivo si el token está por expirar
    if (token != null && _tokenService.isAboutToExpire(token)) {
      token = await _refreshAndNotify();
    }

    if (token != null) {
      options.headers[ApiConstants.headerAuthorization] =
          '${ApiConstants.headerBearer} $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // Si ya refrescando, esperar en la cola
    if (_isRefreshing) {
      final completer = Completer<String>();
      _refreshQueue.add(completer);
      try {
        final newToken = await completer.future;
        final response = await _retry(err.requestOptions, newToken);
        return handler.resolve(response);
      } catch (_) {
        return handler.reject(err);
      }
    }

    final newToken = await _refreshAndNotify();
    if (newToken == null) {
      await _sessionService.clearSession();
      return handler.reject(err);
    }

    try {
      final response = await _retry(err.requestOptions, newToken);
      handler.resolve(response);
    } catch (_) {
      handler.reject(err);
    }
  }

  // ─── Refresh y notificación a la cola ───────────────────────────────────
  Future<String?> _refreshAndNotify() async {
    _isRefreshing = true;
    try {
      final newToken = await _doRefresh();
      if (newToken != null) {
        for (final c in _refreshQueue) {
          c.complete(newToken);
        }
      } else {
        for (final c in _refreshQueue) {
          c.completeError(Exception('refresh_failed'));
        }
      }
      _refreshQueue.clear();
      return newToken;
    } finally {
      _isRefreshing = false;
    }
  }

  Future<String?> _doRefresh() async {
    try {
      final at = await _storage.read(key: StorageKeys.accessToken);
      final rt = await _storage.read(key: StorageKeys.refreshToken);
      if (at == null || rt == null) return null;

      // Llamada directa sin pasar por interceptores (evita bucle)
      final dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
      final res = await dio.post(
        ApiConstants.refresh,
        data: {'accessToken': at, 'refreshToken': rt},
      );

      final data = res.data['data'] as Map<String, dynamic>;
      final newAt = data['accessToken'] as String;
      final newRt = data['refreshToken'] as String;

      await _storage.write(key: StorageKeys.accessToken, value: newAt);
      await _storage.write(key: StorageKeys.refreshToken, value: newRt);
      return newAt;
    } catch (_) {
      return null;
    }
  }

  Future<Response> _retry(RequestOptions options, String token) {
    final dio = Dio(BaseOptions(baseUrl: options.baseUrl));
    options.headers[ApiConstants.headerAuthorization] =
        '${ApiConstants.headerBearer} $token';
    return dio.fetch(options);
  }
}
