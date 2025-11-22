import 'package:fpdart/fpdart.dart';
import 'package:health_tracker_app/core/error/failures.dart';
import 'package:health_tracker_app/domain/entities/notification_entity.dart';

abstract class NotificationRepository {
  // Lấy FCM token từ Firebase
  Future<Either<Failure, String>> getFcmToken();

  // Gửi token lên server Spring Boot
  Future<Either<Failure, void>> saveFcmToken(String token);

  // Yêu cầu quyền
  Future<void> requestPermissions();

  Future<Either<Failure, List<NotificationEntity>>> getNotifications(
    int page,
    int size,
  );
  Future<Either<Failure, void>> markAsRead(int id);
  Future<Either<Failure, void>> markAllAsRead();
  Future<Either<Failure, int>> getUnreadCount();
}
