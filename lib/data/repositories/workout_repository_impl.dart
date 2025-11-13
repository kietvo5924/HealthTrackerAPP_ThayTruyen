import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:health_tracker_app/core/error/failures.dart';
import 'package:health_tracker_app/data/datasources/remote/workout_remote_data_source.dart';
import 'package:health_tracker_app/data/models/log_workout_request_model.dart';
import 'package:health_tracker_app/domain/entities/workout.dart';
import 'package:health_tracker_app/domain/entities/workout_comment.dart';
import 'package:health_tracker_app/domain/entities/workout_summary.dart';
import 'package:health_tracker_app/domain/repositories/workout_repository.dart';
import 'package:intl/intl.dart';

class WorkoutRepositoryImpl implements WorkoutRepository {
  final WorkoutRemoteDataSource remoteDataSource;

  WorkoutRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Workout>>> getMyWorkouts() async {
    try {
      final workoutList = await remoteDataSource.getMyWorkouts();
      return Right(workoutList);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Lỗi server'));
    } catch (e) {
      return Left(GenericFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Workout>> logWorkout({
    required WorkoutType workoutType,
    required int durationInMinutes,
    required DateTime startedAt,
    double? caloriesBurned,
    double? distanceInKm, // Đã thêm
    String? routePolyline, // Đã thêm
  }) async {
    try {
      // 1. Chuyển đổi dữ liệu sang Request DTO
      final requestModel = LogWorkoutRequestModel(
        // Chuyển Enum thành String (ví dụ: "RUNNING")
        workoutType: workoutType.toString().split('.').last,
        durationInMinutes: durationInMinutes,
        startedAt: startedAt.toIso8601String(), // Chuyển DateTime thành String
        caloriesBurned: caloriesBurned,
        distanceInKm: distanceInKm, // Đã thêm
        routePolyline: routePolyline, // Đã thêm
      );

      // 2. Gọi API
      final newWorkout = await remoteDataSource.logWorkout(requestModel);
      return Right(newWorkout);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Lỗi server'));
    } catch (e) {
      return Left(GenericFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Workout>>> getCommunityFeed() async {
    try {
      final workoutList = await remoteDataSource.getCommunityFeed();
      return Right(workoutList);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Lỗi server'));
    } catch (e) {
      return Left(GenericFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Workout>> toggleWorkoutLike(int workoutId) async {
    try {
      // Model là kiểu trả về của remoteDataSource
      final workoutModel = await remoteDataSource.toggleWorkoutLike(workoutId);
      // Trả về Entity (lớp cha)
      return Right(workoutModel);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Lỗi server'));
    } catch (e) {
      return Left(GenericFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<WorkoutComment>>> getComments(
    int workoutId,
  ) async {
    try {
      final commentModels = await remoteDataSource.getComments(workoutId);
      return Right(commentModels); // Models là con của Entities
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Lỗi server'));
    } catch (e) {
      return Left(GenericFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, WorkoutComment>> addComment({
    required int workoutId,
    required String text,
  }) async {
    try {
      final newComment = await remoteDataSource.addComment(
        workoutId: workoutId,
        text: text,
      );
      return Right(newComment);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Lỗi server'));
    } catch (e) {
      return Left(GenericFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<WorkoutSummary>>> getWorkoutSummary({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final start = DateFormat('yyyy-MM-dd').format(startDate);
      final end = DateFormat('yyyy-MM-dd').format(endDate);
      final summaryList = await remoteDataSource.getWorkoutSummary(start, end);
      return Right(summaryList);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Lỗi server'));
    } catch (e) {
      return Left(GenericFailure(e.toString()));
    }
  }
}
