import 'dart:convert';
import 'package:finanzas_app_mobile/core/network/http_client.dart';

class DashboardService {
  static Future<Map<String, dynamic>> getDashboard(int userId) async {
    final response = await ApiClient.post(
      'dashboard.php',
      body: {'user_id': userId.toString()},
    );

    return jsonDecode(response.body);
  }
}
