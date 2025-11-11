import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:health_tracker_app/core/error/failures.dart';
import 'package:health_tracker_app/data/datasources/remote/health_data_remote_data_source.dart';
import 'package:health_tracker_app/domain/entities/health_data.dart';
import 'package:health_tracker_app/domain/repositories/health_data_repository.dart';

class HealthDataRepositoryImpl implements HealthDataRepository {
  final HealthDataRemoteDataSource remoteDataSource;

  HealthDataRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, HealthData>> getHealthData(DateTime date) async {
    try {
      final healthDataModel = await remoteDataSource.getHealthData(date);
      return Right(healthDataModel);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Lỗi server'));
    }
  }

  @override
  Future<Either<Failure, HealthData>> logHealthData(
    HealthData healthData,
  ) async {
    try {
      final updatedHealthData = await remoteDataSource.logHealthData(
        healthData,
      );
      return Right(updatedHealthData);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Lỗi server'));
    }
  }

  @override
  Future<Either<Failure, List<HealthData>>> getHealthDataRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final healthDataList = await remoteDataSource.getHealthDataRange(
        startDate: startDate,
        endDate: endDate,
      );
      return Right(healthDataList);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Lỗi server'));
    }
  }
}
