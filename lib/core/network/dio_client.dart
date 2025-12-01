import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DioClient {
  final Dio dio;
  final SharedPreferences sharedPreferences;

  // Base URL của API Spring Boot của bạn
  static const String _baseUrl = "http://192.168.1.4:8080/api";

  DioClient(this.dio, this.sharedPreferences) {
    dio
      ..options.baseUrl = _baseUrl
      ..options.connectTimeout = const Duration(milliseconds: 15000)
      ..options.receiveTimeout = const Duration(milliseconds: 15000)
      ..options.responseType = ResponseType.json
      ..interceptors.add(LogInterceptor(requestBody: true, responseBody: true))
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            // Tự động thêm token vào header nếu đã đăng nhập
            final token = sharedPreferences.getString('auth_token');
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
            return handler.next(options);
          },
          onError: (DioException e, handler) async {
            // (Nâng cao) Xử lý refresh token nếu có 401
            return handler.next(e);
          },
        ),
      );
  }
}
