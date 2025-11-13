import 'package:fpdart/fpdart.dart';
import 'package:health_tracker_app/core/error/failures.dart';
import 'package:health_tracker_app/data/models/notification_settings_request_model.dart';
import 'package:health_tracker_app/domain/entities/user_profile.dart';

abstract class UserRepository {
  Future<Either<Failure, UserProfile>> getUserProfile();

  Future<Either<Failure, UserProfile>> updateUserProfile(UserProfile profile);

  Future<Either<Failure, UserProfile>> updateNotificationSettings(
    NotificationSettingsRequestModel settings,
  );
}
