import 'package:fpdart/fpdart.dart';
import 'package:health_tracker_app/core/error/failures.dart';
import 'package:health_tracker_app/data/datasources/remote/achievement_remote_data_source.dart';
import 'package:health_tracker_app/domain/entities/achievement.dart';
import 'package:health_tracker_app/domain/repositories/achievement_repository.dart';
import 'package:dio/dio.dart';

class AchievementRepositoryImpl implements AchievementRepository {
  final AchievementRemoteDataSource remoteDataSource;

  AchievementRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<UserAchievement>>> getMyAchievements() async {
    try {
      final result = await remoteDataSource.getMyAchievements();
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Lỗi server'));
    }
  }
}
