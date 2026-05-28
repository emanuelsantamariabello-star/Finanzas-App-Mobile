import 'dart:convert';
import 'package:finanzas_app_mobile/core/network/http_client.dart';

class StatisticsService {
  static Future<Map<String, dynamic>> getMonthlyStats(int userId) async {
    final response = await ApiClient.post(
      'statistics_monthly.php',
      body: {'user_id': userId.toString()},
    );

    return jsonDecode(response.body);
  }
}
