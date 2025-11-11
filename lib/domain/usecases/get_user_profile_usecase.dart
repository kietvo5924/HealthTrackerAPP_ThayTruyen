import 'package:fpdart/fpdart.dart';
import 'package:health_tracker_app/core/error/failures.dart';
import 'package:health_tracker_app/core/usecase/usecase.dart';
import 'package:health_tracker_app/domain/entities/user_profile.dart';
import 'package:health_tracker_app/domain/repositories/user_repository.dart';

class GetUserProfileUseCase implements UseCase<UserProfile, NoParams> {
  final UserRepository userRepository;

  GetUserProfileUseCase(this.userRepository);

  @override
  Future<Either<Failure, UserProfile>> call(NoParams params) async {
    return await userRepository.getUserProfile();
  }
}
