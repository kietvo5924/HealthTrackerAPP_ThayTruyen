import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:health_tracker_app/core/error/failures.dart';
import 'package:health_tracker_app/data/datasources/remote/user_remote_data_source.dart';
import 'package:health_tracker_app/data/models/notification_settings_request_model.dart';
import 'package:health_tracker_app/data/models/user_profile_model.dart';
import 'package:health_tracker_app/domain/entities/user_profile.dart';
import 'package:health_tracker_app/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;

  UserRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, UserProfile>> getUserProfile() async {
    try {
      final profileModel = await remoteDataSource.getUserProfile();
      return Right(profileModel);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Lỗi server'));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> updateUserProfile(
    UserProfile profile,
  ) async {
    try {
      // Chuyển đổi entity sang model
      final profileModel = UserProfileModel(
        id: profile.id,
        fullName: profile.fullName,
        email: profile.email,
        phoneNumber: profile.phoneNumber,
        role: profile.role,
        dateOfBirth: profile.dateOfBirth,
        address: profile.address,
        medicalHistory: profile.medicalHistory,
        allergies: profile.allergies,
        remindWater: profile.remindWater,
        remindSleep: profile.remindSleep,
      );

      final updatedProfile = await remoteDataSource.updateUserProfile(
        profileModel,
      );
      return Right(updatedProfile);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Lỗi server'));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> updateNotificationSettings(
    NotificationSettingsRequestModel settings,
  ) async {
    try {
      final updatedProfile = await remoteDataSource.updateNotificationSettings(
        settings,
      );
      return Right(updatedProfile);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Lỗi server'));
    }
  }
}
