class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://visitas.digitalexpressplus.com/api'; // Producción VPS (HTTPS)
  static const bool isTestingMode = true; // Define si el entorno es pruebas o producción
  static const Duration connectTimeout = Duration(seconds: 8);
  static const Duration receiveTimeout = Duration(seconds: 8);

  // Auth endpoints
  static const String login   = '/auth/login';
  static const String logout  = '/auth/logout';
  static const String refresh = '/auth/refresh';
  static const String me      = '/auth/me';

  // Business endpoints
  static const String visitas        = '/visitas';
  static const String iniciarVisita  = '/visitas/iniciar';
  static const String finalizarVisita = '/visitas/finalizar';
  static const String pdv            = '/pdv';
  static const String novedades      = '/novedades';

  // Headers
  static const String headerAuthorization = 'Authorization';
  static const String headerBearer = 'Bearer';
}

