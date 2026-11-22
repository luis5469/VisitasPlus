part of 'visita_bloc.dart';

abstract class VisitaEvent extends Equatable {
  const VisitaEvent();
  @override
  List<Object?> get props => [];
}

class VisitaLoadRequested extends VisitaEvent {
  const VisitaLoadRequested();
}

class VisitaIniciarRequested extends VisitaEvent {
  final String pdvId;
  final double latitud;
  final double longitud;

  const VisitaIniciarRequested({
    required this.pdvId,
    required this.latitud,
    required this.longitud,
  });

  @override
  List<Object?> get props => [pdvId, latitud, longitud];
}

class VisitaFinalizarRequested extends VisitaEvent {
  final String visitaId;
  final double latitud;
  final double longitud;

  const VisitaFinalizarRequested({
    required this.visitaId,
    required this.latitud,
    required this.longitud,
  });

  @override
  List<Object?> get props => [visitaId, latitud, longitud];
}
