import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../models/dashboard_model.dart';

abstract class DashboardRemoteDataSource {
  Future<DashboardResumenModel> getResumen({DateTime? desde, DateTime? hasta});
  Future<List<int>> exportar(String formato, {DateTime? desde, DateTime? hasta});
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final DioClient _client;

  DashboardRemoteDataSourceImpl(this._client);

  @override
  Future<DashboardResumenModel> getResumen({
    DateTime? desde,
    DateTime? hasta,
  }) async {
    final params = <String, dynamic>{};
    if (desde != null) params['desde'] = desde.toIso8601String();
    if (hasta != null) params['hasta'] = hasta.toIso8601String();

    final resp = await _client.dio.get(
      '/api/dashboard',
      queryParameters: params,
    );
    return DashboardResumenModel.fromJson(
        resp.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<List<int>> exportar(
    String formato, {
    DateTime? desde,
    DateTime? hasta,
  }) async {
    final params = <String, dynamic>{'formato': formato};
    if (desde != null) params['desde'] = desde.toIso8601String();
    if (hasta != null) params['hasta'] = hasta.toIso8601String();

    final resp = await _client.dio.get(
      '/api/dashboard/exportar',
      queryParameters: params,
      options: Options(responseType: ResponseType.bytes),
    );
    return resp.data as List<int>;
  }
}
