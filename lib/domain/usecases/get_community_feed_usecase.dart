import 'package:fpdart/fpdart.dart';
import 'package:health_tracker_app/core/error/failures.dart';
import 'package:health_tracker_app/core/usecase/usecase.dart';
import 'package:health_tracker_app/domain/entities/workout.dart';
import 'package:health_tracker_app/domain/repositories/workout_repository.dart';

class GetCommunityFeedUseCase implements UseCase<List<Workout>, NoParams> {
  final WorkoutRepository workoutRepository;

  GetCommunityFeedUseCase(this.workoutRepository);

  @override
  Future<Either<Failure, List<Workout>>> call(NoParams params) async {
    return await workoutRepository.getCommunityFeed();
  }
}
