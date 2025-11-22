import 'package:fpdart/fpdart.dart';
import 'package:health_tracker_app/core/error/failures.dart';
import 'package:health_tracker_app/core/usecase/usecase.dart';
import 'package:health_tracker_app/domain/repositories/notification_repository.dart';

class MarkNotificationReadUseCase implements UseCase<void, int> {
  final NotificationRepository repository;
  MarkNotificationReadUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(int notificationId) async {
    return await repository.markAsRead(notificationId);
  }
}
