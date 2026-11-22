import 'package:equatable/equatable.dart';

class PdvEntity extends Equatable {
  final String  id;
  final String  codigo;
  final String  nombre;
  final String  direccion;
  final String  ciudad;
  final String? zona;
  final String? responsable;
  final String? telefono;
  final double  latitud;
  final double  longitud;
  final int     geofenceMetros;
  final bool    activo;

  const PdvEntity({
    required this.id,
    required this.codigo,
    required this.nombre,
    required this.direccion,
    required this.ciudad,
    this.zona,
    this.responsable,
    this.telefono,
    required this.latitud,
    required this.longitud,
    required this.geofenceMetros,
    required this.activo,
  });

  @override
  List<Object?> get props => [id];
}
