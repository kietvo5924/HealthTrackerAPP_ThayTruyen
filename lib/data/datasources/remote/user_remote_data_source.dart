import 'package:dio/dio.dart';
import 'package:health_tracker_app/data/models/notification_settings_request_model.dart';
import 'package:health_tracker_app/data/models/user_profile_model.dart';

abstract class UserRemoteDataSource {
  Future<UserProfileModel> getUserProfile();
  Future<UserProfileModel> updateUserProfile(UserProfileModel profile);
  Future<UserProfileModel> updateNotificationSettings(
    NotificationSettingsRequestModel settings,
  );
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final Dio dio;

  UserRemoteDataSourceImpl(this.dio);

  @override
  Future<UserProfileModel> getUserProfile() async {
    try {
      final response = await dio.get('/users/me'); // GET /api/users/me
      if (response.statusCode == 200) {
        return UserProfileModel.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          message: 'Lấy hồ sơ thất bại',
        );
      }
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ?? 'Lỗi không xác định';
      throw DioException(
        requestOptions: e.requestOptions,
        message: errorMessage,
      );
    }
  }

  @override
  Future<UserProfileModel> updateUserProfile(UserProfileModel profile) async {
    try {
      final response = await dio.put(
        '/users/me', // PUT /api/users/me
        data: profile.toJson(), // Gửi đi nội dung đã cập nhật
      );
      if (response.statusCode == 200) {
        // Trả về data mới nhất
        return UserProfileModel.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          message: 'Cập nhật hồ sơ thất bại',
        );
      }
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ?? 'Lỗi không xác định';
      throw DioException(
        requestOptions: e.requestOptions,
        message: errorMessage,
      );
    }
  }

  @override
  Future<UserProfileModel> updateNotificationSettings(
    NotificationSettingsRequestModel settings,
  ) async {
    try {
      final response = await dio.put(
        '/users/me/notification-settings', // API endpoint mới
        data: settings.toJson(), // Gửi DTO
      );
      if (response.statusCode == 200) {
        // Trả về data mới nhất
        return UserProfileModel.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          message: 'Cập nhật cài đặt thất bại',
        );
      }
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ?? 'Lỗi không xác định';
      throw DioException(
        requestOptions: e.requestOptions,
        message: errorMessage,
      );
    }
  }
}
