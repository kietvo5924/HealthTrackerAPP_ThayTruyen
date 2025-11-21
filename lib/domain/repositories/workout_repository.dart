import 'package:fpdart/fpdart.dart';
import 'package:health_tracker_app/core/error/failures.dart';
import 'package:health_tracker_app/domain/entities/workout.dart';
import 'package:health_tracker_app/domain/entities/workout_comment.dart';
import 'package:health_tracker_app/domain/entities/workout_summary.dart';

abstract class WorkoutRepository {
  // Lấy lịch sử bài tập
  Future<Either<Failure, List<Workout>>> getMyWorkouts();

  // Ghi (log) một bài tập mới
  Future<Either<Failure, Workout>> logWorkout({
    required WorkoutType workoutType,
    required int durationInMinutes,
    required DateTime startedAt,
    double? caloriesBurned,
    double? distanceInKm,
    String? routePolyline,
  });

  Future<Either<Failure, List<Workout>>> getCommunityFeed(int page, int size);

  Future<Either<Failure, Workout>> toggleWorkoutLike(int workoutId);

  Future<Either<Failure, List<WorkoutComment>>> getComments(int workoutId);
  Future<Either<Failure, WorkoutComment>> addComment({
    required int workoutId,
    required String text,
  });

  Future<Either<Failure, List<WorkoutSummary>>> getWorkoutSummary({
    required DateTime startDate,
    required DateTime endDate,
  });
}
