import 'package:dio/dio.dart';

class BaseService {
  String handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout || 
        e.type == DioExceptionType.receiveTimeout) {
      return 'Connection timeout. Please check your internet connection.';
    } else if (e.type == DioExceptionType.connectionError) {
      return 'No internet connection. Please check your network.';
    } else if (e.response != null) {
      switch (e.response?.statusCode) {
        case 400:
          return 'Bad request: ${e.response?.data['message'] ?? 'Invalid data'}';
        case 401:
          return 'Unauthorized. Please log in again.';
        case 403:
          return 'You do not have permission to access this resource.';
        case 404:
          return 'The requested resource was not found.';
        case 413:
          return 'File too large. Please use a smaller file.';
        case 415:
          return 'Unsupported media type.';
        case 500:
          return 'Server error. Please try again later.';
        default:
          return 'Server error: ${e.response?.statusCode}';
      }
    }
    return 'Network error occurred';
  }
}