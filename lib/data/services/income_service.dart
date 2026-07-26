import 'package:finanzas_app_mobile/core/network/http_client.dart';

class IncomeService {
  static String _normalizeDate(String date) {
    final value = date.trim();
    if (value.isNotEmpty) return value;

    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  static Future<Map<String, dynamic>> getIncomes(
    int userId, {
    String? startDate,
    String? endDate,
  }) async {
    final body = <String, String>{'user_id': userId.toString()};
    if (startDate != null && endDate != null) {
      body['start_date'] = startDate;
      body['end_date'] = endDate;
    }

    return ApiClient.postJson('incomes.php', body: body);
  }

  static Future<Map<String, dynamic>> createIncome({
    required int userId,
    required String amount,
    required String type,
    required String note,
    required String date,
  }) async {
    final safeDate = _normalizeDate(date);

    return ApiClient.postJson(
      'create_income.php',
      body: {
        'user_id': userId.toString(),
        'amount': amount,
        'type': type,
        'note': note,
        'date': safeDate,
        'income_date': safeDate,
      },
    );
  }

  static Future<Map<String, dynamic>> updateIncome({
    required int id,
    required int userId,
    required String amount,
    required String type,
    required String note,
    required String date,
  }) async {
    final safeDate = _normalizeDate(date);

    return ApiClient.postJson(
      'update_income.php',
      body: {
        'id': id.toString(),
        'user_id': userId.toString(),
        'amount': amount,
        'type': type,
        'note': note,
        'date': safeDate,
        'income_date': safeDate,
      },
    );
  }

  static Future<Map<String, dynamic>> deleteIncome({
    required int id,
    required int userId,
  }) async {
    return ApiClient.postJson(
      'delete_income.php',
      body: {'id': id.toString(), 'user_id': userId.toString()},
    );
  }
}
