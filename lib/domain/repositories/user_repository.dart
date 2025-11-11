import 'package:fpdart/fpdart.dart';
import 'package:health_tracker_app/core/error/failures.dart';
import 'package:health_tracker_app/domain/entities/user_profile.dart';

abstract class UserRepository {
  Future<Either<Failure, UserProfile>> getUserProfile();

  Future<Either<Failure, UserProfile>> updateUserProfile(UserProfile profile);
}
