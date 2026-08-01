import 'package:finanzas_app_mobile/data/services/authenticated_api_client.dart';

class DashboardService {
  static Future<Map<String, dynamic>> getDashboard(int userId) async {
    return AuthenticatedApiClient.postJson(
      'dashboard.php',
      body: {'user_id': userId.toString()},
    );
  }
}
