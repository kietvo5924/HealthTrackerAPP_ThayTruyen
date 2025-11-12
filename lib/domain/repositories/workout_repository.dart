import 'package:fpdart/fpdart.dart';
import 'package:health_tracker_app/core/error/failures.dart';
import 'package:health_tracker_app/domain/entities/workout.dart';

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

  Future<Either<Failure, List<Workout>>> getCommunityFeed();
}
