import 'package:finanzas_app_mobile/core/network/http_client.dart';

class ExpenseService {
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

    return ApiClient.postJson('expenses.php', body: body);
  }

  static Future<Map<String, dynamic>> createExpense({
    required int userId,
    required int incomeId,
    required String amount,
    required String note,
    required String expenseDate,
    required String reflectionType,
  }) async {
    return ApiClient.postJson(
      'create_expense.php',
      body: {
        'user_id': userId.toString(),
        'income_id': incomeId.toString(),
        'amount': amount,
        'note': note,
        'expense_date': expenseDate,
        'reflection_type': reflectionType,
      },
    );
  }

  static Future<Map<String, dynamic>> updateExpense({
    required int id,
    required String amount,
    required String note,
    required String expenseDate,
    required String reflectionType,
  }) async {
    return ApiClient.postJson(
      'update_expense.php',
      body: {
        'id': id.toString(),
        'amount': amount,
        'note': note,
        'expense_date': expenseDate,
        'reflection_type': reflectionType,
      },
    );
  }

  static Future<Map<String, dynamic>> deleteExpense({
    required int id,
    required int userId,
  }) async {
    return ApiClient.postJson(
      'delete_expense.php',
      body: {'id': id.toString(), 'user_id': userId.toString()},
    );
  }
}
