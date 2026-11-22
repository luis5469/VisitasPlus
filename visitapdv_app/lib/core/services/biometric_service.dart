import 'package:injectable/injectable.dart';
import 'package:local_auth/local_auth.dart';

enum BiometricAvailability { available, notAvailable, notEnrolled }

@lazySingleton
class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  /// Verifica si el dispositivo tiene biometría configurada.
  Future<BiometricAvailability> checkAvailability() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isDeviceSupported = await _auth.isDeviceSupported();
      if (!isDeviceSupported) return BiometricAvailability.notAvailable;
      if (!canCheck) return BiometricAvailability.notEnrolled;
      return BiometricAvailability.available;
    } catch (_) {
      return BiometricAvailability.notAvailable;
    }
  }

  /// Obtiene tipos de biometría disponibles (facial, huella, etc.)
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (_) {
      return [];
    }
  }

  /// Autentica con biometría. Retorna true si el usuario se autenticó.
  Future<bool> authenticate({
    String localizedReason = 'Confirma tu identidad para ingresar a VisitaPDV',
  }) async {
    try {
      return await _auth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          biometricOnly: false,  // permite PIN como fallback
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }

  Future<void> stopAuthentication() async {
    await _auth.stopAuthentication();
  }
}
