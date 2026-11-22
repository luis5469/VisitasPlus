import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class LoadDashboard extends DashboardEvent {
  final DateTime? desde;
  final DateTime? hasta;

  const LoadDashboard({this.desde, this.hasta});

  @override
  List<Object?> get props => [desde, hasta];
}

class RefreshDashboard extends DashboardEvent {
  const RefreshDashboard();
}

class ExportDashboard extends DashboardEvent {
  final String formato; // 'pdf' | 'excel'
  final DateTime? desde;
  final DateTime? hasta;

  const ExportDashboard({required this.formato, this.desde, this.hasta});

  @override
  List<Object?> get props => [formato, desde, hasta];
}
