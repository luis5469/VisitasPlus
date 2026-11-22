import 'package:hive/hive.dart';

part 'visita_hive_model.g.dart';

@HiveType(typeId: 11)
class VisitaHiveModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String pdvId;

  @HiveField(2)
  late String pdvNombre;

  @HiveField(3)
  late String pdvCodigo;

  @HiveField(4)
  late String visitadorId;

  @HiveField(5)
  late String estado; // EnCurso | Completada | Cancelada

  @HiveField(6)
  double? latitudInicio;

  @HiveField(7)
  double? longitudInicio;

  @HiveField(8)
  double? latitudFin;

  @HiveField(9)
  double? longitudFin;

  @HiveField(10)
  late DateTime timestampInicio;

  @HiveField(11)
  DateTime? timestampFin;

  @HiveField(12)
  String? actaPdfUrl;

  @HiveField(13)
  late bool sincronizado;

  @HiveField(14)
  late DateTime updatedAt;
}
