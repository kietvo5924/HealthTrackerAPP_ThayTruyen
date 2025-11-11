import 'package:fpdart/fpdart.dart';
import 'package:health_tracker_app/core/error/failures.dart';

abstract class AuthRepository {
  // Đăng nhập
  Future<Either<Failure, void>> login({
    required String email,
    required String password,
  });

  // Đăng ký
  // Trả về String là message thành công từ API
  Future<Either<Failure, String>> signup({
    required String fullName,
    required String phoneNumber,
    required String email,
    required String password,
  });

  // Đăng xuất
  Future<Either<Failure, void>> logout();

  // Kiểm tra xem có token (đã đăng nhập) hay không
  Future<Either<Failure, String?>> getAuthToken();
}
