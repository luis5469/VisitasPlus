import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../core/services/biometric_service.dart';
import '../../../core/services/session_service.dart';
import '../../../core/services/token_service.dart';
import '../../../domain/usecases/check_session_usecase.dart';
import '../../../domain/usecases/login_usecase.dart';
import '../../../domain/usecases/logout_usecase.dart';
import '../../../domain/usecases/refresh_token_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  final RefreshTokenUseCase _refreshTokenUseCase;
  final CheckSessionUseCase _checkSessionUseCase;
  final SessionService _sessionService;
  final BiometricService _biometricService;
  final TokenService _tokenService;

  // Timer para auto-refresh antes de expirar
  Timer? _refreshTimer;

  AuthBloc(
    this._loginUseCase,
    this._logoutUseCase,
    this._refreshTokenUseCase,
    this._checkSessionUseCase,
    this._sessionService,
    this._biometricService,
    this._tokenService,
  ) : super(const AuthInitial()) {
    on<AuthCheckSessionRequested>(_onCheckSession);
    on<AuthLoginRequested>(_onLogin);
    on<AuthBiometricLoginRequested>(_onBiometricLogin);
    on<AuthRefreshRequested>(_onRefresh);
    on<AuthLogoutRequested>(_onLogout);
    on<AuthSessionExpired>(_onSessionExpired);
    on<AuthBiometricToggleRequested>(_onBiometricToggle);
  }

  // ─── Check Session (Splash) ────────────────────────────────────────────
  Future<void> _onCheckSession(
    AuthCheckSessionRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    // 1. ¿Está bloqueada la cuenta?
    if (await _sessionService.isLockedOut) {
      final until = await _sessionService.lockoutUntil;
      emit(AuthLockedOut(lockoutUntil: until));
      return;
    }

    // 2. ¿Token activo válido?
    final at = await _sessionService.getAccessToken();
    if (at != null && !_tokenService.isExpired(at)) {
      final (user, _) = await _checkSessionUseCase();
      if (user != null) {
        _scheduleTokenRefresh(at);
        emit(AuthAuthenticated(user));
        return;
      }
    }

    // 3. ¿Puede renovar con refresh token?
    if (await _sessionService.hasRefreshToken()) {
      if (await _sessionService.isBiometriaEnabled) {
        emit(const AuthSessionExpiredState(canRecoverWithBiometric: true));
      } else {
        // Intenta refresh silencioso
        final (user, failure) = await _refreshTokenUseCase();
        if (user != null) {
          _scheduleTokenRefresh(user.accessToken);
          emit(AuthAuthenticated(user));
          return;
        }
        emit(const AuthUnauthenticated());
      }
      return;
    }

    emit(const AuthUnauthenticated());
  }

  // ─── Login con credenciales ────────────────────────────────────────────
  Future<void> _onLogin(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    // Verificar bloqueo
    if (await _sessionService.isLockedOut) {
      final until = await _sessionService.lockoutUntil;
      emit(AuthLockedOut(lockoutUntil: until));
      return;
    }

    emit(const AuthLoading());
    final (user, failure) = await _loginUseCase(
      usernameOrEmail: event.usernameOrEmail,
      password: event.password,
    );

    if (failure != null) {
      await _sessionService.registerFailedAttempt();
      final locked = await _sessionService.isLockedOut;
      if (locked) {
        final until = await _sessionService.lockoutUntil;
        emit(AuthLockedOut(lockoutUntil: until));
      } else {
        emit(AuthError(failure.message));
      }
      return;
    }

    await _sessionService.resetFailedAttempts();
    _scheduleTokenRefresh(user!.accessToken);
    emit(AuthAuthenticated(user));
  }

  // ─── Login con biometría ───────────────────────────────────────────────
  Future<void> _onBiometricLogin(
    AuthBiometricLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    final authenticated = await _biometricService.authenticate();
    if (!authenticated) {
      emit(const AuthBiometricUnavailable());
      return;
    }

    emit(const AuthLoading());
    final (user, failure) = await _refreshTokenUseCase();
    if (failure != null) {
      await _sessionService.clearSession();
      emit(const AuthUnauthenticated());
      return;
    }
    _scheduleTokenRefresh(user!.accessToken);
    emit(AuthAuthenticated(user));
  }

  // ─── Refresh Token ─────────────────────────────────────────────────────
  Future<void> _onRefresh(
    AuthRefreshRequested event,
    Emitter<AuthState> emit,
  ) async {
    final (user, failure) = await _refreshTokenUseCase();
    if (failure != null) {
      emit(const AuthSessionExpiredState());
      return;
    }
    _scheduleTokenRefresh(user!.accessToken);
    emit(AuthAuthenticated(user));
  }

  // ─── Logout ────────────────────────────────────────────────────────────
  Future<void> _onLogout(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    _refreshTimer?.cancel();
    await _logoutUseCase();
    emit(const AuthUnauthenticated());
  }

  // ─── Sesión expirada (desde interceptor) ──────────────────────────────
  Future<void> _onSessionExpired(
    AuthSessionExpired event,
    Emitter<AuthState> emit,
  ) async {
    _refreshTimer?.cancel();
    final canRecover = await _sessionService.canRecoverSession();
    emit(AuthSessionExpiredState(canRecoverWithBiometric: canRecover));
  }

  // ─── Toggle biometría ──────────────────────────────────────────────────
  Future<void> _onBiometricToggle(
    AuthBiometricToggleRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (event.enable) {
      final avail = await _biometricService.checkAvailability();
      if (avail != BiometricAvailability.available) {
        emit(const AuthBiometricUnavailable());
        return;
      }
      final ok = await _biometricService.authenticate(
        localizedReason: 'Confirma tu huella para activar el acceso biométrico',
      );
      if (!ok) return;
    }
    await _sessionService.setBiometriaEnabled(event.enable);
  }

  // ─── Auto-refresh ──────────────────────────────────────────────────────
  void _scheduleTokenRefresh(String accessToken) {
    _refreshTimer?.cancel();
    final ttl = _tokenService.timeToExpiry(accessToken);
    // Refrescar 5 minutos antes de que expire
    final delay = ttl - const Duration(minutes: 5);
    if (delay.isNegative) {
      add(const AuthRefreshRequested());
      return;
    }
    _refreshTimer = Timer(delay, () => add(const AuthRefreshRequested()));
  }

  @override
  Future<void> close() {
    _refreshTimer?.cancel();
    return super.close();
  }
}
