import 'package:dio/dio.dart';
import 'package:health_tracker_app/data/models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<void> saveFcmToken(String token);
  Future<List<NotificationModel>> getNotifications(int page, int size);
  Future<void> markAsRead(int id);
  Future<void> markAllAsRead();
  Future<int> getUnreadCount();
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

  @override
  Future<List<NotificationModel>> getNotifications(int page, int size) async {
    try {
      // Gọi API: GET /api/v1/notifications?page=0&size=20
      final response = await dio.get(
        '/v1/notifications',
        queryParameters: {'page': page, 'size': size},
      );

      if (response.statusCode == 200) {
        return (response.data as List)
            .map((e) => NotificationModel.fromJson(e))
            .toList();
      }
      return [];
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<void> markAsRead(int id) async {
    await dio.put('/v1/notifications/$id/read');
  }

  @override
  Future<void> markAllAsRead() async {
    await dio.put('/v1/notifications/read-all');
  }

  @override
  Future<int> getUnreadCount() async {
    try {
      final response = await dio.get('/v1/notifications/unread-count');
      return response.data as int;
    } catch (e) {
      return 0;
    }
  }
}
