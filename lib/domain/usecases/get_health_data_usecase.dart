import 'package:fpdart/fpdart.dart';
import 'package:health_tracker_app/core/error/failures.dart';
import 'package:health_tracker_app/core/usecase/usecase.dart';
import 'package:health_tracker_app/domain/entities/health_data.dart';
import 'package:health_tracker_app/domain/repositories/health_data_repository.dart';

class GetHealthDataUseCase implements UseCase<HealthData, DateTime> {
  final HealthDataRepository healthDataRepository;

  GetHealthDataUseCase(this.healthDataRepository);

  @override
  Future<Either<Failure, HealthData>> call(DateTime params) async {
    return await healthDataRepository.getHealthData(params);
  }
}
