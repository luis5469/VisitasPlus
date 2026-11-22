import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../constants/api_constants.dart';
import 'interceptors/auth_interceptor.dart';

@lazySingleton
class ApiClient {
  late final Dio _dio;

  ApiClient(AuthInterceptor authInterceptor) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {'Content-Type': 'application/json'},
      ),
    );
    _dio.interceptors.add(authInterceptor);
  }

  Dio get dio => _dio;
}
