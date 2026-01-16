import 'package:dio/dio.dart';

Future<T> safeApiCall<T>(Future<T> Function() call) async {
  try {
    return await call();
  } on DioException catch (e) {
    // Handle internet issues
    if (e.type == DioExceptionType.connectionError) {
      throw 'No internet connection. Please check your connection.';
    }

    // Handle HTTP response status codes
    final statusCode = e.response?.statusCode ?? 0;

    switch (statusCode) {
      case 400:
      final data = e.response?.data;
      if (data is Map<String, dynamic> && data.containsKey("ResponseMessage")) {
        throw data["ResponseMessage"];
      }
      else if (data is String) {
        if (data.contains("<!DOCTYPE html>")){
          throw "Server error. Please try again later.";
        }
        throw data;
      }
      else if (data is Map<String, dynamic> && data.containsKey("Message")) {
        throw data["Message"];
      }
      else if (data is Map) {
        throw data["message"] ?? "Invalid request. Please check your input.";
      }
       else {
        throw "Invalid request/Server error. Please check and try again.";
      }
      case 401:
        throw "Session expired. Please login again.";
      case 403:
        throw "You do not have permission to perform this action.";
      case 404:
        throw "Requested resource not found.";
      case 500:
        final data = e.response?.data;
        if (data is Map<String, dynamic> && data.containsKey("error")) {
          throw data["error"];
        } else if (data is String) {
          throw data;
        }
        throw "Server error. Please try again later.";
      case 502:
        throw "Bad gateway. Please try again later.";
      case 503:
        throw "Server error. Please try again later.";
      default:
        throw "Unexpected error occurred. Please try again.";
    }
  } catch (e) {
        // print("Unhandled error: ${e}");
    throw "Unexpected error occurred. Please try again.";
  }
}
