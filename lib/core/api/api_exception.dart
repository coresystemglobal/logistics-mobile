class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class UnauthorizedException extends ApiException {
  UnauthorizedException([String message = 'Unauthorized'])
      : super(message, statusCode: 401);
}

class NotFoundException extends ApiException {
  NotFoundException([String message = 'Not found'])
      : super(message, statusCode: 404);
}

class ServerException extends ApiException {
  ServerException([String message = 'Server error'])
      : super(message, statusCode: 500);
}

class NetworkException extends ApiException {
  NetworkException([String message = 'Network error'])
      : super(message);
}

class ValidationException extends ApiException {
  final Map<String, dynamic>? errors;

  ValidationException(String message, {this.errors})
      : super(message, statusCode: 422);
}

class ForbiddenException extends ApiException {
  ForbiddenException([String message = 'Access denied'])
      : super(message, statusCode: 403);
}
