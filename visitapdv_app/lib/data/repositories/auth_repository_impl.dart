import 'package:injectable/injectable.dart';
import '../../core/error/failures.dart';
import '../../core/services/session_service.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final SessionService _session;

  AuthRepositoryImpl(this._remote, this._session);

  @override
  Future<(UserEntity?, Failure?)> login(
      String usernameOrEmail, String password) async {
    final (model, failure) = await _remote.login(usernameOrEmail, password);
    if (failure != null) return (null, failure);

    await _session.saveSession(
      accessToken:    model!.accessToken,
      refreshToken:   model.refreshToken,
      userId:         model.userId,
      username:       model.username,
      nombreCompleto: model.nombreCompleto,
      rol:            model.rol,
      expiresAt:      model.expiresAt,
    );
    return (model, null);
  }

  @override
  Future<(UserEntity?, Failure?)> refreshToken() async {
    final at = await _session.getAccessToken();
    final rt = await _session.getRefreshToken();
    if (at == null || rt == null) {
      return (null, const AuthFailure('Sin sesión activa.'));
    }

    final (model, failure) = await _remote.refreshToken(at, rt);
    if (failure != null) {
      await _session.clearSession();
      return (null, failure);
    }

    await _session.saveSession(
      accessToken:    model!.accessToken,
      refreshToken:   model.refreshToken,
      userId:         model.userId,
      username:       model.username,
      nombreCompleto: model.nombreCompleto,
      rol:            model.rol,
      expiresAt:      model.expiresAt,
    );
    return (model, null);
  }

  @override
  Future<(UserEntity?, Failure?)> getCurrentUser() async {
    final at = await _session.getAccessToken();
    if (at == null) return (null, null);

    final (meData, failure) = await _remote.getMe();
    if (failure != null) return (null, failure);

    final rt = await _session.getRefreshToken() ?? '';
    final expiresStr = await _session.getAccessToken();
    final model = UserModel.fromMeJson(
      meData!,
      accessToken:  at,
      refreshToken: rt,
      expiresAt:    DateTime.now().add(const Duration(hours: 8)),
    );
    return (model, null);
  }

  @override
  Future<void> logout() async {
    final rt = await _session.getRefreshToken();
    if (rt != null) await _remote.logout(rt);
    await _session.clearSession();
  }
}

