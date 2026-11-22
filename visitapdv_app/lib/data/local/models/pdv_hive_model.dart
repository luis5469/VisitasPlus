import 'package:hive/hive.dart';

part 'pdv_hive_model.g.dart';

@HiveType(typeId: 10)
class PdvHiveModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String codigo;

  @HiveField(2)
  late String nombre;

  @HiveField(3)
  late String direccion;

  @HiveField(4)
  late String ciudad;

  @HiveField(5)
  String? zona;

  @HiveField(6)
  String? responsable;

  @HiveField(7)
  String? telefono;

  @HiveField(8)
  late double latitud;

  @HiveField(9)
  late double longitud;

  @HiveField(10)
  late int geofenceMetros;

  @HiveField(11)
  late bool activo;

  @HiveField(12)
  late DateTime updatedAt;
}
