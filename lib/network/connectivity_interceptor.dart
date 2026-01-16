import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'dart:io';

class ConnectivityInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    var connectivity = await Connectivity().checkConnectivity();

    if (connectivity == ConnectivityResult.none) {
      return handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
          error: 'No Internet Connection. Please try again.',
        ),
      );
    }

    try {
      final result = await InternetAddress.lookup('www.google.com');
      if (result.isEmpty || result[0].rawAddress.isEmpty) {
        return handler.reject(
          DioException(
            requestOptions: options,
            type: DioExceptionType.connectionError,
            error: 'Internet not reachable. Please check your connection.',
          ),
        );
      }
    } on SocketException {
      return handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
          error: 'Internet not reachable. Please check your connection.',
        ),
      );
    }

    handler.next(options); // Proceed if all good
  }
}
