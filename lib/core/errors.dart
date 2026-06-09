sealed class AiServiceError implements Exception {
  final String message;
  const AiServiceError(this.message);

  @override
  String toString() => 'AiServiceError: $message';
}

final class NetworkError extends AiServiceError {
  const NetworkError(super.message);
}

final class ApiError extends AiServiceError {
  final int statusCode;
  final String body;

  const ApiError({required this.statusCode, required this.body})
      : super('API error $statusCode');
}

final class ParseError extends AiServiceError {
  final String detail;

  const ParseError(this.detail) : super('Parse error: $detail');
}
