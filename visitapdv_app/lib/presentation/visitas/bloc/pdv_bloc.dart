import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/entities/pdv_entity.dart';
import '../../../domain/repositories/visita_repository.dart';

part 'pdv_event.dart';
part 'pdv_state.dart';

@injectable
class PdvBloc extends Bloc<PdvEvent, PdvState> {
  final VisitaRepository _repo;

  PdvBloc(this._repo) : super(const PdvInitial()) {
    on<PdvLoadRequested>(_onLoad);
    on<PdvSearchChanged>(_onSearch);
  }

  Future<void> _onLoad(PdvLoadRequested event, Emitter<PdvState> emit) async {
    emit(const PdvLoading());
    final (pdvs, err) = await _repo.getPdvs();
    if (err != null && pdvs.isEmpty) {
      emit(PdvError(err.message));
    } else {
      emit(PdvLoaded(all: pdvs, filtered: pdvs));
    }
  }

  void _onSearch(PdvSearchChanged event, Emitter<PdvState> emit) {
    final current = state;
    if (current is! PdvLoaded) return;
    final q = event.query.toLowerCase();
    final filtered = q.isEmpty
        ? current.all
        : current.all.where((p) =>
            p.nombre.toLowerCase().contains(q) ||
            p.codigo.toLowerCase().contains(q) ||
            p.ciudad.toLowerCase().contains(q)).toList();
    emit(PdvLoaded(all: current.all, filtered: filtered));
  }
}
