import '../../core/error/failures.dart';
import '../../data/models/dashboard_model.dart';

abstract class DashboardRepository {
  Future<(DashboardResumenModel?, Failure?)> getResumen({
    DateTime? desde,
    DateTime? hasta,
  });

  Future<(List<int>?, Failure?)> exportar(
    String formato, {
    DateTime? desde,
    DateTime? hasta,
  });
}
