import 'dart:convert';
import 'package:http/http.dart' as http;

class ExpenseService {
  static const String baseUrl = 'http://192.168.20.29/finanzas_app/api';

  static Future<Map<String, dynamic>> getExpenses(
    int userId, {
    String? startDate,
    String? endDate,
  }) async {
    final body = <String, String>{'user_id': userId.toString()};
    if (startDate != null && endDate != null) {
      body['start_date'] = startDate;
      body['end_date'] = endDate;
    }

    final response = await http.post(
      Uri.parse('$baseUrl/expenses.php'),
      body: body,
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> createExpense({
    required int userId,
    required int incomeId,
    required String amount,
    required String note,
    required String expenseDate,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/create_expense.php'),
      body: {
        'user_id': userId.toString(),
        'income_id': incomeId.toString(),
        'amount': amount,
        'note': note,
        'expense_date': expenseDate,
      },
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> updateExpense({
    required int id,
    required String amount,
    required String note,
    required String expenseDate,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/update_expense.php'),
      body: {
        'id': id.toString(),
        'amount': amount,
        'note': note,
        'expense_date': expenseDate,
      },
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> deleteExpense({
    required int id,
    required int userId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/delete_expense.php'),
      body: {
        'id': id.toString(),
        'user_id': userId.toString(),
      },
    );

    return jsonDecode(response.body);
  }
}
