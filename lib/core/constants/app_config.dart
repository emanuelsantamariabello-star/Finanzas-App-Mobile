import 'package:finanzas_app_mobile/core/constants/api_constants.dart';

class AppConfig {
  static const String env = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'dev',
  );

  static const String _apiBaseUrlOverride = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static String get apiBaseUrl {
    if (_apiBaseUrlOverride.isNotEmpty) {
      return _apiBaseUrlOverride;
    }

    switch (env) {
      case 'beta':
        return ApiConstants.baseUrlBeta;
      case 'production':
        throw StateError(
          'API_BASE_URL es obligatorio para el entorno de producción',
        );
      case 'development':
      case 'dev':
      default:
        return ApiConstants.baseUrlDevelopment;
    }
  }
}
