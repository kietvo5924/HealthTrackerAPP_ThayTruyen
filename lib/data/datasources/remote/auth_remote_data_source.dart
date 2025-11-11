import 'package:dio/dio.dart';
import 'package:health_tracker_app/data/models/jwt_auth_response_model.dart';

abstract class AuthRemoteDataSource {
  Future<JwtAuthResponseModel> login(String email, String password);

  Future<String> signup({
    required String fullName,
    required String phoneNumber,
    required String email,
    required String password,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl(this.dio);

  @override
  Future<JwtAuthResponseModel> login(String email, String password) async {
    try {
      final response = await dio.post(
        '/auth/signin',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        return JwtAuthResponseModel.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Đăng nhập thất bại',
        );
      }
    } on DioException catch (e) {
      // Xử lý lỗi từ Dio (ví dụ: 400, 403, 500)
      final errorMessage = e.response?.data?['message'] ?? 'Lỗi không xác định';
      throw DioException(
        requestOptions: e.requestOptions,
        message: errorMessage,
      );
    }
  }

  @override
  Future<String> signup({
    required String fullName,
    required String phoneNumber,
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        '/auth/signup', // API endpoint từ Spring Boot
        data: {
          'fullName': fullName,
          'phoneNumber': phoneNumber,
          'email': email,
          'password': password,
        },
      );

      // API /signup trả về 200 OK với body là một String message
      if (response.statusCode == 200) {
        return response.data as String;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Đăng ký thất bại',
        );
      }
    } on DioException catch (e) {
      final errorMessage = e.response?.data?.toString() ?? 'Lỗi không xác định';
      throw DioException(
        requestOptions: e.requestOptions,
        message: errorMessage,
      );
    }
  }
}
