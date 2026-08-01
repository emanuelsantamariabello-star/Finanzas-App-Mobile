import 'package:finanzas_app_mobile/data/services/authenticated_api_client.dart';

class StatisticsService {
  static Future<Map<String, dynamic>> getMonthlyStats(int userId) async {
    return AuthenticatedApiClient.postJson(
      'statistics_monthly.php',
      body: {'user_id': userId.toString()},
    );
  }
}
