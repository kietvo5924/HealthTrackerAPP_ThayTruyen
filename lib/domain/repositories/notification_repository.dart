import 'package:fpdart/fpdart.dart';
import 'package:health_tracker_app/core/error/failures.dart';

abstract class NotificationRepository {
  // Lấy FCM token từ Firebase
  Future<Either<Failure, String>> getFcmToken();

  // Gửi token lên server Spring Boot
  Future<Either<Failure, void>> saveFcmToken(String token);

  // Yêu cầu quyền
  Future<void> requestPermissions();
}
