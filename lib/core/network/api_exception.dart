enum ApiErrorType { connection, timeout, http, invalidResponse, configuration }

class ApiException implements Exception {
  const ApiException({
    required this.type,
    required this.message,
    this.statusCode,
  });

  final ApiErrorType type;
  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

String apiErrorMessage(Object error, {required String fallback}) {
  return error is ApiException ? error.message : fallback;
}
