import 'package:hive/hive.dart';

part 'novedad_hive_model.g.dart';

@HiveType(typeId: 13)
class NovedadHiveModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String visitaId;

  @HiveField(2)
  late String pdvId;

  @HiveField(3)
  late String titulo;

  @HiveField(4)
  late String descripcion;

  @HiveField(5)
  late String categoria;

  @HiveField(6)
  late String prioridad;

  @HiveField(7)
  late String estado; // Abierta|EnProgreso|Resuelta|Cerrada|Reabierta|Vencida

  @HiveField(8)
  late String responsableSolucionId;

  @HiveField(9)
  late String responsableSeguimientoId;

  @HiveField(10)
  late DateTime fechaSeguimiento;

  @HiveField(11)
  late bool sincronizado;

  @HiveField(12)
  late DateTime creadoEn;

  @HiveField(13)
  List<Map<dynamic, dynamic>> imagenes = [];

  @HiveField(14)
  bool pendienteSincronizacion = false;
}

@HiveType(typeId: 14)
class NovedadImagenHiveModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String novedadId;

  @HiveField(2)
  late String rutaLocal; // path local antes de subir

  @HiveField(3)
  String? urlRemota; // URL Azure tras sincronizar

  @HiveField(4)
  late String nombreArchivo;

  @HiveField(5)
  late int tamanoBytes;

  @HiveField(6)
  double? latitud;

  @HiveField(7)
  double? longitud;

  @HiveField(8)
  late DateTime timestampCaptura;

  @HiveField(9)
  late bool marcaAguaAplicada;

  @HiveField(10)
  bool subida = false; // false = pendiente en offline queue
}
