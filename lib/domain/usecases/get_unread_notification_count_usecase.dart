import 'package:fpdart/fpdart.dart';
import 'package:health_tracker_app/core/error/failures.dart';
import 'package:health_tracker_app/core/usecase/usecase.dart';
import 'package:health_tracker_app/domain/repositories/notification_repository.dart';

class GetUnreadNotificationCountUseCase implements UseCase<int, NoParams> {
  final NotificationRepository repository;
  GetUnreadNotificationCountUseCase(this.repository);

  @override
  Future<Either<Failure, int>> call(NoParams params) async {
    return await repository.getUnreadCount();
  }
}
