import 'package:fpdart/fpdart.dart';
import 'package:health_tracker_app/core/error/failures.dart';
import 'package:health_tracker_app/core/usecase/usecase.dart';
import 'package:health_tracker_app/data/models/user_goals_request_model.dart';
import 'package:health_tracker_app/domain/entities/user_profile.dart';
import 'package:health_tracker_app/domain/repositories/user_repository.dart';

class UpdateUserGoalsUseCase
    implements UseCase<UserProfile, UserGoalsRequestModel> {
  final UserRepository repository;

  UpdateUserGoalsUseCase(this.repository);

  @override
  Future<Either<Failure, UserProfile>> call(
    UserGoalsRequestModel params,
  ) async {
    return await repository.updateUserGoals(params);
  }
}
