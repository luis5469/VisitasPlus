import 'package:geolocator/geolocator.dart';

class GpsHelper {
  GpsHelper._();

  static Future<Position> obtenerPosicion() async {
    bool servicio = await Geolocator.isLocationServiceEnabled();
    if (!servicio) throw Exception('GPS desactivado');

    LocationPermission permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
    }
    if (permiso == LocationPermission.deniedForever) {
      throw Exception('Permiso GPS denegado permanentemente');
    }

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}
