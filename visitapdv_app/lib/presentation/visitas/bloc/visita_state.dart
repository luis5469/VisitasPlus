part of 'visita_bloc.dart';

abstract class VisitaState extends Equatable {
  const VisitaState();
  @override
  List<Object?> get props => [];
}

class VisitaInitial extends VisitaState {
  const VisitaInitial();
}

class VisitaLoading extends VisitaState {
  const VisitaLoading();
}

class VisitaLoaded extends VisitaState {
  final List<VisitaEntity> visitas;
  final VisitaEntity?      visitaActiva;

  const VisitaLoaded({required this.visitas, this.visitaActiva});

  @override
  List<Object?> get props => [visitas, visitaActiva];
}

class VisitaError extends VisitaState {
  final String message;
  const VisitaError(this.message);
  @override
  List<Object?> get props => [message];
}

class VisitaActionSuccess extends VisitaState {
  final VisitaEntity? visita;
  final String        message;
  const VisitaActionSuccess({required this.message, this.visita});
  @override
  List<Object?> get props => [visita, message];
}
