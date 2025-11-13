import 'package:fpdart/fpdart.dart';
import 'package:health_tracker_app/core/error/failures.dart';
import 'package:health_tracker_app/core/usecase/usecase.dart';
import 'package:health_tracker_app/domain/entities/workout_comment.dart';
import 'package:health_tracker_app/domain/repositories/workout_repository.dart';

class GetWorkoutCommentsUseCase implements UseCase<List<WorkoutComment>, int> {
  final WorkoutRepository repository;
  GetWorkoutCommentsUseCase(this.repository);

  @override
  Future<Either<Failure, List<WorkoutComment>>> call(int params) async {
    return await repository.getComments(params);
  }
}
