import 'package:fpdart/fpdart.dart';
import 'package:health_tracker_app/core/error/failures.dart';
import 'package:health_tracker_app/core/usecase/usecase.dart';
import 'package:health_tracker_app/data/models/notification_settings_request_model.dart';
import 'package:health_tracker_app/domain/entities/user_profile.dart';
import 'package:health_tracker_app/domain/repositories/user_repository.dart';

// Input là DTO, Output là Entity
class UpdateNotificationSettingsUseCase
    implements UseCase<UserProfile, NotificationSettingsRequestModel> {
  final UserRepository repository;

  UpdateNotificationSettingsUseCase(this.repository);

  @override
  Future<Either<Failure, UserProfile>> call(
    NotificationSettingsRequestModel params,
  ) async {
    return await repository.updateNotificationSettings(params);
  }
}
