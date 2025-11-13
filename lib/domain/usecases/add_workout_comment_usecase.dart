import 'package:fpdart/fpdart.dart';
import 'package:health_tracker_app/core/error/failures.dart';
import 'package:health_tracker_app/core/usecase/usecase.dart';
import 'package:health_tracker_app/domain/entities/workout_comment.dart';
import 'package:health_tracker_app/domain/repositories/workout_repository.dart';

class AddWorkoutCommentUseCase
    implements UseCase<WorkoutComment, AddCommentParams> {
  final WorkoutRepository repository;
  AddWorkoutCommentUseCase(this.repository);

  @override
  Future<Either<Failure, WorkoutComment>> call(AddCommentParams params) async {
    return await repository.addComment(
      workoutId: params.workoutId,
      text: params.text,
    );
  }
}

class AddCommentParams {
  final int workoutId;
  final String text;
  AddCommentParams({required this.workoutId, required this.text});
}
