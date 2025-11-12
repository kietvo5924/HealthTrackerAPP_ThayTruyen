import 'package:fpdart/fpdart.dart';
import 'package:health_tracker_app/core/error/failures.dart';
import 'package:health_tracker_app/core/usecase/usecase.dart';
import 'package:health_tracker_app/domain/entities/workout.dart';
import 'package:health_tracker_app/domain/repositories/workout_repository.dart';

// Usecase này nhận vào int (workoutId) và trả về Workout
class ToggleWorkoutLikeUseCase implements UseCase<Workout, int> {
  final WorkoutRepository repository;

  ToggleWorkoutLikeUseCase(this.repository);

  @override
  Future<Either<Failure, Workout>> call(int params) async {
    return await repository.toggleWorkoutLike(params);
  }
}
