import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import '../../core/error/failures.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/user_model.dart';

@lazySingleton
class AuthRemoteDataSource {
  final ApiClient _client;
  final DeviceInfoPlugin _deviceInfo;

  AuthRemoteDataSource(this._client, this._deviceInfo);

  // ─── Login ─────────────────────────────────────────────────────────────
  Future<(UserModel?, Failure?)> login(
      String usernameOrEmail, String password) async {
    try {
      final deviceData = await _getDeviceInfo();
      final res = await _client.dio.post(
        ApiConstants.login,
        data: {
          'usernameOrEmail': usernameOrEmail,
          'password': password,
          ...deviceData,
        },
      );
      final model = UserModel.fromLoginJson(
          res.data['data'] as Map<String, dynamic>);
      return (model, null);
    } on DioException catch (e) {
      return (null, _handleDioError(e));
    } catch (_) {
      return (null, const UnexpectedFailure());
    }
  }

  // ─── Refresh ────────────────────────────────────────────────────────────
  Future<(UserModel?, Failure?)> refreshToken(
      String accessToken, String refreshToken) async {
    try {
      final res = await _client.dio.post(
        ApiConstants.refresh,
        data: {
          'accessToken': accessToken,
          'refreshToken': refreshToken,
        },
      );
      final model = UserModel.fromLoginJson(
          res.data['data'] as Map<String, dynamic>);
      return (model, null);
    } on DioException catch (e) {
      return (null, _handleDioError(e));
    } catch (_) {
      return (null, const UnexpectedFailure());
    }
  }

  // ─── Logout ─────────────────────────────────────────────────────────────
  Future<Failure?> logout(String refreshToken) async {
    try {
      await _client.dio.post(
        ApiConstants.logout,
        data: {'refreshToken': refreshToken},
      );
      return null;
    } on DioException catch (e) {
      // El logout siempre limpia localmente aunque falle en server
      if (e.response?.statusCode == 401) return null;
      return _handleDioError(e);
    } catch (_) {
      return null;
    }
  }

  // ─── Me ─────────────────────────────────────────────────────────────────
  Future<(Map<String, dynamic>?, Failure?)> getMe() async {
    try {
      final res = await _client.dio.get(ApiConstants.me);
      return (res.data['data'] as Map<String, dynamic>, null);
    } on DioException catch (e) {
      return (null, _handleDioError(e));
    } catch (_) {
      return (null, const UnexpectedFailure());
    }
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────
  Future<Map<String, String?>> _getDeviceInfo() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final info = await _deviceInfo.androidInfo;
        return {
          'deviceId': info.id,
          'deviceName': '${info.brand} ${info.model}',
          'plataforma': 'Android',
        };
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final info = await _deviceInfo.iosInfo;
        return {
          'deviceId': info.identifierForVendor,
          'deviceName': info.model,
          'plataforma': 'iOS',
        };
      }
    } catch (_) {}
    return {'deviceId': null, 'deviceName': 'Desconocido', 'plataforma': 'Desconocido'};
  }

  Failure _handleDioError(DioException e) {
    final serverMessage = e.response?.data?['message'] as String?;

    switch (e.response?.statusCode) {
      case 400:
        return ServerFailure(serverMessage ?? 'Solicitud inválida.');
      case 401:
        return AuthFailure(serverMessage ?? 'Credenciales incorrectas o sesión expirada.');
      case 403:
        return AuthFailure(serverMessage ?? 'Acceso denegado.');
      case 422:
        return AuthFailure(serverMessage ?? 'Credenciales o datos incorrectos.');
      default:
        return ServerFailure(serverMessage ?? e.message ?? 'Error de servidor.');
    }
  }
}
