import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fpdart/fpdart.dart';
import 'package:health_tracker_app/core/error/failures.dart';
import 'package:health_tracker_app/data/datasources/remote/notification_remote_data_source.dart';
import 'package:health_tracker_app/domain/repositories/notification_repository.dart';
import 'package:dio/dio.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final FirebaseMessaging _firebaseMessaging;
  final NotificationRemoteDataSource _remoteDataSource;

  NotificationRepositoryImpl(this._firebaseMessaging, this._remoteDataSource);

  @override
  Future<void> requestPermissions() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  @override
  Future<Either<Failure, String>> getFcmToken() async {
    try {
      // Lấy token từ Firebase
      final token = await _firebaseMessaging.getToken();
      if (token == null) {
        return const Left(GenericFailure('Không nhận được token'));
      }
      return Right(token);
    } catch (e) {
      return Left(GenericFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveFcmToken(String token) async {
    try {
      // Gọi API Spring Boot
      await _remoteDataSource.saveFcmToken(token);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Lỗi server'));
    }
  }
}
