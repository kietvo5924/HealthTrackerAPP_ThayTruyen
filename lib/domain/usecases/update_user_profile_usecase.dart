import 'package:fpdart/fpdart.dart';
import 'package:health_tracker_app/core/error/failures.dart';
import 'package:health_tracker_app/core/usecase/usecase.dart';
import 'package:health_tracker_app/domain/entities/user_profile.dart';
import 'package:health_tracker_app/domain/repositories/user_repository.dart';

class UpdateUserProfileUseCase implements UseCase<UserProfile, UserProfile> {
  final UserRepository userRepository;

  UpdateUserProfileUseCase(this.userRepository);

  @override
  Future<Either<Failure, UserProfile>> call(UserProfile params) async {
    return await userRepository.updateUserProfile(params);
  }
}
