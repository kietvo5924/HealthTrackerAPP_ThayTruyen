import 'package:fpdart/fpdart.dart';
import 'package:health_tracker_app/core/error/failures.dart';
import 'package:health_tracker_app/core/usecase/usecase.dart';
import 'package:health_tracker_app/domain/repositories/notification_repository.dart';

class SaveFcmTokenUseCase implements UseCase<void, NoParams> {
  final NotificationRepository notificationRepository;

  SaveFcmTokenUseCase(this.notificationRepository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    // 1. Yêu cầu quyền (trên iOS & Android 13+)
    await notificationRepository.requestPermissions();

    // 2. Lấy token
    final tokenResult = await notificationRepository.getFcmToken();

    // 3. Gửi lên server
    return tokenResult.fold((failure) => Left(failure), (token) async {
      if (token.isNotEmpty) {
        return await notificationRepository.saveFcmToken(token);
      }
      return const Left(GenericFailure('Không thể lấy FCM token'));
    });
  }
}
