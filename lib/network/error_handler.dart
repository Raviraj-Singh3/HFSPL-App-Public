import 'package:dio/dio.dart';

String getErrorMessage(Object error) {
  if (error is DioException) {
    if (error.type == DioExceptionType.connectionError) {
      return error.error.toString(); // From the interceptor
    }

    if (error.response?.data is Map && error.response?.data["ResponseMessage"] != null) {
      return error.response?.data["ResponseMessage"];
    }

    return 'Something went wrong. Please try again.';
  }

  return 'Unexpected error occurred. Please try again.';
}
