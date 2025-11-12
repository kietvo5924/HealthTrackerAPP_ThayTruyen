import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:health_tracker_app/core/error/failures.dart';
import 'package:health_tracker_app/core/usecase/usecase.dart';
import 'package:health_tracker_app/domain/entities/workout.dart';
import 'package:health_tracker_app/domain/repositories/workout_repository.dart';

class LogWorkoutUseCase implements UseCase<Workout, LogWorkoutParams> {
  final WorkoutRepository workoutRepository;

  LogWorkoutUseCase(this.workoutRepository);

  @override
  Future<Either<Failure, Workout>> call(LogWorkoutParams params) async {
    return await workoutRepository.logWorkout(
      workoutType: params.workoutType,
      durationInMinutes: params.durationInMinutes,
      startedAt: params.startedAt,
      caloriesBurned: params.caloriesBurned,
      distanceInKm: params.distanceInKm,
      routePolyline: params.routePolyline,
    );
  }
}

// Class tham số cho UseCase
class LogWorkoutParams extends Equatable {
  final WorkoutType workoutType;
  final int durationInMinutes;
  final DateTime startedAt;
  final double? caloriesBurned;
  final double? distanceInKm;
  final String? routePolyline;

  const LogWorkoutParams({
    required this.workoutType,
    required this.durationInMinutes,
    required this.startedAt,
    this.caloriesBurned,
    this.distanceInKm,
    this.routePolyline,
  });

  @override
  List<Object?> get props => [
    workoutType,
    durationInMinutes,
    startedAt,
    caloriesBurned,
    distanceInKm,
    routePolyline,
  ];
}
