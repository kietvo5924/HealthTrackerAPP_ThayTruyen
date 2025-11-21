import 'package:fpdart/fpdart.dart';
import 'package:health_tracker_app/core/error/failures.dart';
import 'package:health_tracker_app/data/models/notification_settings_request_model.dart';
import 'package:health_tracker_app/data/models/user_goals_request_model.dart';
import 'package:health_tracker_app/domain/entities/user_profile.dart';

abstract class UserRepository {
  Future<Either<Failure, UserProfile>> getUserProfile();

  Future<Either<Failure, UserProfile>> updateUserProfile(UserProfile profile);

  Future<Either<Failure, UserProfile>> updateNotificationSettings(
    NotificationSettingsRequestModel settings,
  );

  Future<Either<Failure, UserProfile>> updateUserGoals(
    UserGoalsRequestModel goals,
  );

  Future<Either<Failure, List<UserProfile>>> searchUsers(String query);
  Future<Either<Failure, void>> followUser(int userId);
  Future<Either<Failure, void>> unfollowUser(int userId);
}
