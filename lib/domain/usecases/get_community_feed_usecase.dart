import 'package:fpdart/fpdart.dart';
import 'package:health_tracker_app/core/error/failures.dart';
import 'package:health_tracker_app/core/usecase/usecase.dart';
import 'package:health_tracker_app/domain/entities/workout.dart';
import 'package:health_tracker_app/domain/repositories/workout_repository.dart';

class GetCommunityFeedParams {
  final int page;
  final int size;

  GetCommunityFeedParams({required this.page, required this.size});
}

class GetCommunityFeedUseCase
    implements UseCase<List<Workout>, GetCommunityFeedParams> {
  final WorkoutRepository workoutRepository;

  GetCommunityFeedUseCase(this.workoutRepository);

  @override
  Future<Either<Failure, List<Workout>>> call(
    GetCommunityFeedParams params,
  ) async {
    return await workoutRepository.getCommunityFeed(params.page, params.size);
  }
}
