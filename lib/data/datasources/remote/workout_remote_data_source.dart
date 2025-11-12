import 'package:dio/dio.dart';
import 'package:health_tracker_app/data/models/log_workout_request_model.dart';
import 'package:health_tracker_app/data/models/workout_model.dart';

abstract class WorkoutRemoteDataSource {
  Future<List<WorkoutModel>> getMyWorkouts();
  Future<WorkoutModel> logWorkout(LogWorkoutRequestModel request);
  Future<List<WorkoutModel>> getCommunityFeed();
  Future<WorkoutModel> toggleWorkoutLike(int workoutId);
}

class WorkoutRemoteDataSourceImpl implements WorkoutRemoteDataSource {
  final Dio dio;

  WorkoutRemoteDataSourceImpl(this.dio);

  @override
  Future<List<WorkoutModel>> getMyWorkouts() async {
    try {
      // 1. Gọi API GET /api/workouts
      final response = await dio.get('/workouts/me');

      if (response.statusCode == 200) {
        // 2. Chuyển đổi List<dynamic> (JSON) thành List<WorkoutModel>
        return (response.data as List)
            .map((json) => WorkoutModel.fromJson(json))
            .toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          message: 'Lấy lịch sử bài tập thất bại',
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
  Future<WorkoutModel> logWorkout(LogWorkoutRequestModel request) async {
    try {
      // 1. Gọi API POST /api/workouts
      final response = await dio.post('/workouts', data: request.toJson());

      if (response.statusCode == 200) {
        // 2. Trả về bài tập vừa được tạo
        return WorkoutModel.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          message: 'Ghi bài tập thất bại',
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
  Future<List<WorkoutModel>> getCommunityFeed() async {
    try {
      // 1. Gọi API GET /api/workouts/feed
      final response = await dio.get('/workouts/feed');

      if (response.statusCode == 200) {
        // 2. Chuyển đổi List<dynamic> (JSON) thành List<WorkoutModel>
        return (response.data as List)
            .map((json) => WorkoutModel.fromJson(json))
            .toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          message: 'Lấy Bảng tin thất bại',
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
  Future<WorkoutModel> toggleWorkoutLike(int workoutId) async {
    try {
      // Gọi API POST /api/workouts/{id}/like
      final response = await dio.post('/workouts/$workoutId/like');

      if (response.statusCode == 200) {
        // Trả về bài tập đã được cập nhật (với likeCount mới)
        return WorkoutModel.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          message: 'Like/Unlike thất bại',
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
