import 'package:fpdart/fpdart.dart';
import 'package:health_tracker_app/core/error/failures.dart';
import 'package:health_tracker_app/core/usecase/usecase.dart';
import 'package:health_tracker_app/domain/entities/notification_entity.dart';
import 'package:health_tracker_app/domain/repositories/notification_repository.dart';

class GetNotificationsParams {
  final int page;
  final int size;
  GetNotificationsParams({required this.page, required this.size});
}

class GetNotificationsUseCase
    implements UseCase<List<NotificationEntity>, GetNotificationsParams> {
  final NotificationRepository repository;
  GetNotificationsUseCase(this.repository);

  @override
  Future<Either<Failure, List<NotificationEntity>>> call(
    GetNotificationsParams params,
  ) async {
    return await repository.getNotifications(params.page, params.size);
  }
}
