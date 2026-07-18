import 'dart:convert';
import 'package:finanzas_app_mobile/core/network/http_client.dart';

class IncomeService {
  static String _normalizeDate(String date) {
    final value = date.trim();
    if (value.isNotEmpty) return value;

    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  static Map<String, dynamic> _decodeJson(String rawBody) {
    final body = rawBody.trim();
    try {
      return jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {
      final snippet = body.length > 200 ? body.substring(0, 200) : body;
      throw FormatException('Respuesta no JSON del servidor: $snippet');
    }
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

    final response = await ApiClient.post('incomes.php', body: body);

    return _decodeJson(response.body);
  }

  static Future<Map<String, dynamic>> createIncome({
    required int userId,
    required String amount,
    required String type,
    required String note,
    required String date,
  }) async {
    final safeDate = _normalizeDate(date);

    final response = await ApiClient.post(
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

    return _decodeJson(response.body);
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

    final response = await ApiClient.post(
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

    return _decodeJson(response.body);
  }

  static Future<Map<String, dynamic>> deleteIncome({
    required int id,
    required int userId,
  }) async {
    final response = await ApiClient.post(
      'delete_income.php',
      body: {'id': id.toString(), 'user_id': userId.toString()},
    );

    return jsonDecode(response.body);
  }
}
