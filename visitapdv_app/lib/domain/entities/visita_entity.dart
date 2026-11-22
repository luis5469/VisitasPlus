import 'package:equatable/equatable.dart';

class VisitaEntity extends Equatable {
  final String   id;
  final String   pdvId;
  final String   pdvNombre;
  final String   pdvCodigo;
  final String   visitadorId;
  final String   estado;
  final double?  latitudInicio;
  final double?  longitudInicio;
  final double?  latitudFin;
  final double?  longitudFin;
  final DateTime timestampInicio;
  final DateTime? timestampFin;
  final String?  actaPdfUrl;
  final bool     sincronizado;

  const VisitaEntity({
    required this.id,
    required this.pdvId,
    required this.pdvNombre,
    required this.pdvCodigo,
    required this.visitadorId,
    required this.estado,
    this.latitudInicio,
    this.longitudInicio,
    this.latitudFin,
    this.longitudFin,
    required this.timestampInicio,
    this.timestampFin,
    this.actaPdfUrl,
    required this.sincronizado,
  });

  bool get estaEnCurso => estado == 'EnCurso';
  bool get estaCompletada => estado == 'Completada';

  @override
  List<Object?> get props => [id];
}
