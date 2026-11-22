import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/dashboard_repository.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepository _repo;

  DateTime? _desde;
  DateTime? _hasta;

  DashboardBloc(this._repo) : super(const DashboardInitial()) {
    on<LoadDashboard>(_onLoad);
    on<RefreshDashboard>(_onRefresh);
    on<ExportDashboard>(_onExport);
  }

  Future<void> _onLoad(LoadDashboard event, Emitter<DashboardState> emit) async {
    emit(const DashboardLoading());
    _desde = event.desde;
    _hasta = event.hasta;
    await _fetch(emit);
  }

  Future<void> _onRefresh(RefreshDashboard event, Emitter<DashboardState> emit) async {
    // Mantenemos la pantalla con los datos actuales mientras recargamos
    if (state is DashboardLoaded) {
      // silently refresh without showing full loader
    } else {
      emit(const DashboardLoading());
    }
    await _fetch(emit);
  }

  Future<void> _onExport(ExportDashboard event, Emitter<DashboardState> emit) async {
    emit(const DashboardExporting());
    final (bytes, failure) = await _repo.exportar(
      event.formato,
      desde: event.desde ?? _desde,
      hasta: event.hasta ?? _hasta,
    );
    if (failure != null) {
      emit(DashboardError(failure.message));
    } else {
      emit(DashboardExportSuccess(bytes: bytes!, formato: event.formato));
    }
  }

  Future<void> _fetch(Emitter<DashboardState> emit) async {
    final (data, failure) = await _repo.getResumen(desde: _desde, hasta: _hasta);
    if (failure != null) {
      emit(DashboardError(failure.message));
    } else {
      emit(DashboardLoaded(data: data!, lastUpdated: DateTime.now()));
    }
  }
}
