import 'package:fpdart/fpdart.dart';
import 'package:health_tracker_app/core/error/failures.dart';
import 'package:health_tracker_app/domain/entities/health_data.dart';

abstract class HealthDataRepository {
  // Lấy dữ liệu của một ngày cụ thể
  Future<Either<Failure, HealthData>> getHealthData(DateTime date);

  // Ghi (log) dữ liệu mới. Trả về HealthData đã được cập nhật.
  Future<Either<Failure, HealthData>> logHealthData(HealthData healthData);

  // Lấy dữ liệu trong một khoảng thời gian
  Future<Either<Failure, List<HealthData>>> getHealthDataRange({
    required DateTime startDate,
    required DateTime endDate,
  });
}
