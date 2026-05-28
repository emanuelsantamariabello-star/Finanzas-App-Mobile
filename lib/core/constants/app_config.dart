import 'package:finanzas_app_mobile/core/constants/api_constants.dart';

class AppConfig {
  static const String env = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'dev',
  );

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: ApiConstants.baseUrlEmulator,
  );
}
