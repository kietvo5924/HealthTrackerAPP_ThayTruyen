import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:health_tracker_app/core/error/failures.dart';
import 'package:health_tracker_app/data/datasources/local/auth_local_data_source.dart';
import 'package:health_tracker_app/data/datasources/remote/auth_remote_data_source.dart';
import 'package:health_tracker_app/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  // (Bạn có thể thêm networkInfo để kiểm tra kết nối mạng)

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, void>> login({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Gọi API
      final remoteResponse = await remoteDataSource.login(email, password);

      // 2. Lưu token vào local
      await localDataSource.cacheToken(remoteResponse.token);

      return const Right(null); // Thành công
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Lỗi server'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> signup({
    required String fullName,
    required String phoneNumber,
    required String email,
    required String password,
  }) async {
    try {
      // 1. Gọi API đăng ký
      final successMessage = await remoteDataSource.signup(
        fullName: fullName,
        phoneNumber: phoneNumber,
        email: email,
        password: password,
      );

      // 2. Trả về message thành công
      return Right(successMessage);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Lỗi server'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String?>> getAuthToken() async {
    try {
      final token = await localDataSource.getToken();
      return Right(token);
    } on CacheFailure catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await localDataSource.deleteToken();
      return const Right(null);
    } on CacheFailure catch (e) {
      return Left(e);
    }
  }
}
