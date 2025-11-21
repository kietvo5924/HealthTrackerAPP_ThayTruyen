import 'package:dio/dio.dart';
import 'package:health_tracker_app/data/models/notification_settings_request_model.dart';
import 'package:health_tracker_app/data/models/user_goals_request_model.dart';
import 'package:health_tracker_app/data/models/user_profile_model.dart';

abstract class UserRemoteDataSource {
  Future<UserProfileModel> getUserProfile();
  Future<UserProfileModel> updateUserProfile(UserProfileModel profile);
  Future<UserProfileModel> updateNotificationSettings(
    NotificationSettingsRequestModel settings,
  );
  Future<UserProfileModel> updateUserGoals(UserGoalsRequestModel goals);
  Future<List<UserProfileModel>> searchUsers(String query);
  Future<void> followUser(int userId);
  Future<void> unfollowUser(int userId);
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

  @override
  Future<UserProfileModel> updateUserGoals(UserGoalsRequestModel goals) async {
    try {
      final response = await dio.put(
        '/users/me/goals', // API endpoint mới
        data: goals.toJson(),
      );
      if (response.statusCode == 200) {
        return UserProfileModel.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          message: 'Cập nhật mục tiêu thất bại',
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

  // --- SOCIAL IMPLEMENTATION ---

  @override
  Future<List<UserProfileModel>> searchUsers(String query) async {
    try {
      // API tìm kiếm user: GET /api/users/search?query=abc
      final response = await dio.get(
        '/users/search',
        queryParameters: {'query': query},
      );
      if (response.statusCode == 200) {
        return (response.data as List)
            .map((json) => UserProfileModel.fromJson(json))
            .toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          message: 'Tìm kiếm user thất bại',
        );
      }
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<void> followUser(int userId) async {
    try {
      // API follow: POST /api/v1/social/follow/{id}
      await dio.post('/v1/social/follow/$userId');
    } on DioException catch (e) {
      final errorMessage = e.response?.data ?? 'Lỗi follow';
      throw DioException(
        requestOptions: e.requestOptions,
        message: errorMessage.toString(),
      );
    }
  }

  @override
  Future<void> unfollowUser(int userId) async {
    try {
      await dio.post('/v1/social/unfollow/$userId');
    } on DioException catch (e) {
      throw DioException(
        requestOptions: e.requestOptions,
        message: e.message ?? 'Lỗi unfollow',
      );
    }
  }
}
