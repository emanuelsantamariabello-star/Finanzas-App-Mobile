import 'package:flutter/material.dart';
import 'package:finanzas_app_mobile/data/services/dashboard_service.dart';

class DashboardProvider extends ChangeNotifier {
  Map<String, dynamic> data = {};
  bool isLoading = false;
  String? error;

  Future<void> refreshDashboard(int userId) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await DashboardService.getDashboard(userId);

      if (response['success'] == true) {
        data = (response['data'] as Map?)?.cast<String, dynamic>() ?? {};
        error = null;
      } else {
        error = response['message']?.toString() ?? 'Error al cargar dashboard';
      }
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
