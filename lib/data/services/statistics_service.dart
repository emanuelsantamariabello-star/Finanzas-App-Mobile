import 'package:finanzas_app_mobile/core/network/http_client.dart';

class StatisticsService {
  static Future<Map<String, dynamic>> getMonthlyStats(int userId) async {
    return ApiClient.postJson(
      'statistics_monthly.php',
      body: {'user_id': userId.toString()},
    );
  }
}
