class AppException implements Exception {
  final String message;
  final int? statusCode;

  AppException({required this.message, this.statusCode});

  @override
  String toString() => message;
}

class ServerException extends AppException {
  ServerException({required super.message, super.statusCode});
}

class NetworkException extends AppException {
  NetworkException({super.message = 'No internet connection'});
}

class UnauthorizedException extends AppException {
  UnauthorizedException({
    super.message = 'Session expired. Please login again.',
    super.statusCode = 401,
  });
}

class NotFoundException extends AppException {
  NotFoundException({
    super.message = 'Resource not found.',
    super.statusCode = 404,
  });
}

class ValidationException extends AppException {
  ValidationException({required super.message, super.statusCode = 400});
}
