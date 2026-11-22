import 'package:equatable/equatable.dart';
import '../../data/models/dashboard_model.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

class DashboardLoaded extends DashboardState {
  final DashboardResumenModel data;
  final DateTime lastUpdated;

  const DashboardLoaded({required this.data, required this.lastUpdated});

  @override
  List<Object?> get props => [data, lastUpdated];
}

class DashboardError extends DashboardState {
  final String mensaje;

  const DashboardError(this.mensaje);

  @override
  List<Object?> get props => [mensaje];
}

class DashboardExporting extends DashboardState {
  const DashboardExporting();
}

class DashboardExportSuccess extends DashboardState {
  final List<int> bytes;
  final String formato;

  const DashboardExportSuccess({required this.bytes, required this.formato});

  @override
  List<Object?> get props => [bytes, formato];
}
