import 'package:fpdart/fpdart.dart';
import 'package:health_tracker_app/core/error/failures.dart';

// Type: Kiểu dữ liệu trả về khi thành công
// Params: Tham số đầu vào cho usecase
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

// Dùng khi Usecase không cần tham số
class NoParams {}
