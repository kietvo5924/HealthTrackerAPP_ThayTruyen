import 'package:fpdart/fpdart.dart';
import 'package:health_tracker_app/core/error/failures.dart';
import 'package:health_tracker_app/core/usecase/usecase.dart';
import 'package:health_tracker_app/domain/entities/health_data.dart';
import 'package:health_tracker_app/domain/repositories/health_data_repository.dart';

// Tham số là HealthData, trả về cũng là HealthData (đã cập nhật)
class LogHealthDataUseCase implements UseCase<HealthData, HealthData> {
  final HealthDataRepository healthDataRepository;

  LogHealthDataUseCase(this.healthDataRepository);

  @override
  Future<Either<Failure, HealthData>> call(HealthData params) async {
    return await healthDataRepository.logHealthData(params);
  }
}
