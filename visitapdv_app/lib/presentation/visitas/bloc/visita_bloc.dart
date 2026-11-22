import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/entities/visita_entity.dart';
import '../../../domain/repositories/visita_repository.dart';

part 'visita_event.dart';
part 'visita_state.dart';

@injectable
class VisitaBloc extends Bloc<VisitaEvent, VisitaState> {
  final VisitaRepository _repo;

  VisitaBloc(this._repo) : super(const VisitaInitial()) {
    on<VisitaLoadRequested>(_onLoad);
    on<VisitaIniciarRequested>(_onIniciar);
    on<VisitaFinalizarRequested>(_onFinalizar);
  }

  Future<void> _onLoad(VisitaLoadRequested event, Emitter<VisitaState> emit) async {
    emit(const VisitaLoading());
    final (visitas, err) = await _repo.getVisitas();
    final activa         = await _repo.getVisitaActiva();
    if (err != null && visitas.isEmpty) {
      emit(VisitaError(err.message));
    } else {
      emit(VisitaLoaded(visitas: visitas, visitaActiva: activa));
    }
  }

  Future<void> _onIniciar(VisitaIniciarRequested event, Emitter<VisitaState> emit) async {
    emit(const VisitaLoading());
    final (visita, err) = await _repo.iniciarVisita(
      pdvId:    event.pdvId,
      latitud:  event.latitud,
      longitud: event.longitud,
    );
    if (err != null) {
      emit(VisitaError(err.message));
    } else {
      emit(VisitaActionSuccess(message: 'Visita iniciada correctamente', visita: visita));
      add(const VisitaLoadRequested());
    }
  }

  Future<void> _onFinalizar(VisitaFinalizarRequested event, Emitter<VisitaState> emit) async {
    emit(const VisitaLoading());
    final (visita, err) = await _repo.finalizarVisita(
      visitaId: event.visitaId,
      latitud:  event.latitud,
      longitud: event.longitud,
    );
    if (err != null) {
      emit(VisitaError(err.message));
    } else {
      emit(VisitaActionSuccess(message: 'Visita finalizada correctamente', visita: visita));
      add(const VisitaLoadRequested());
    }
  }
}
