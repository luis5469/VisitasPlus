import 'package:dio/dio.dart';
import '../../core/error/failures.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_datasource.dart';
import '../models/dashboard_model.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource _remote;

  DashboardRepositoryImpl(this._remote);

  @override
  Future<(DashboardResumenModel?, Failure?)> getResumen({
    DateTime? desde,
    DateTime? hasta,
  }) async {
    try {
      final model = await _remote.getResumen(desde: desde, hasta: hasta);
      return (model, null);
    } on DioException catch (e) {
      return (null, ServerFailure(e.message ?? 'Error al cargar dashboard'));
    } catch (e) {
      return (null, ServerFailure(e.toString()));
    }
  }

  @override
  Future<(List<int>?, Failure?)> exportar(
    String formato, {
    DateTime? desde,
    DateTime? hasta,
  }) async {
    try {
      final bytes = await _remote.exportar(formato, desde: desde, hasta: hasta);
      return (bytes, null);
    } on DioException catch (e) {
      return (null, ServerFailure(e.message ?? 'Error al exportar'));
    } catch (e) {
      return (null, ServerFailure(e.toString()));
    }
  }
}
