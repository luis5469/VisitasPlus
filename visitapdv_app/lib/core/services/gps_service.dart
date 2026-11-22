import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class GpsService {
  /// Solicita permisos y devuelve la posición actual.
  Future<Position?> getCurrentPosition() async {
    try {
      return await _getRawPosition().timeout(const Duration(seconds: 5));
    } catch (_) {
      try {
        return await Geolocator.getLastKnownPosition().timeout(const Duration(seconds: 2));
      } catch (_) {
        return null;
      }
    }
  }

  Future<Position?> _getRawPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return await Geolocator.getLastKnownPosition();
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return await Geolocator.getLastKnownPosition();
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return await Geolocator.getLastKnownPosition();
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// Calcula distancia en metros entre dos puntos.
  double distanciaMetros(
    double lat1, double lng1,
    double lat2, double lng2,
  ) =>
      Geolocator.distanceBetween(lat1, lng1, lat2, lng2);

  /// Verifica si está dentro del radio de geofence.
  bool estaDentroDeGeofence(
    double latUsuario, double lngUsuario,
    double latPdv,     double lngPdv,
    int    radioMetros,
  ) {
    final dist = distanciaMetros(latUsuario, lngUsuario, latPdv, lngPdv);
    return dist <= radioMetros;
  }
}
