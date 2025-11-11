import 'package:dio/dio.dart';

abstract class NotificationRemoteDataSource {
  Future<void> saveFcmToken(String token);
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final Dio dio;

  NotificationRemoteDataSourceImpl(this.dio);

  @override
  Future<void> saveFcmToken(String token) async {
    try {
      final response = await dio.post(
        '/users/me/fcm-token',
        data: {'token': token},
      );
      if (response.statusCode != 200) {
        throw DioException(
          requestOptions: response.requestOptions,
          message: 'Lưu token thất bại',
        );
      }
    } on DioException {
      rethrow;
    }
  }
}
