import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fpdart/fpdart.dart';
import 'package:health_tracker_app/core/error/failures.dart';
import 'package:health_tracker_app/data/datasources/remote/notification_remote_data_source.dart';
import 'package:health_tracker_app/domain/entities/notification_entity.dart';
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

  @override
  Future<Either<Failure, List<NotificationEntity>>> getNotifications(
    int page,
    int size,
  ) async {
    try {
      final result = await _remoteDataSource.getNotifications(page, size);
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Lỗi tải thông báo'));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(int id) async {
    try {
      await _remoteDataSource.markAsRead(id);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Lỗi server'));
    }
  }

  @override
  Future<Either<Failure, void>> markAllAsRead() async {
    try {
      await _remoteDataSource.markAllAsRead();
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Lỗi server'));
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadCount() async {
    try {
      final count = await _remoteDataSource.getUnreadCount();
      return Right(count);
    } on DioException {
      return const Right(0); // Lỗi thì coi như 0
    }
  }
}
