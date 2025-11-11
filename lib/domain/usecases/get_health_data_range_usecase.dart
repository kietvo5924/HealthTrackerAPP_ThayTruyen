import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:health_tracker_app/core/error/failures.dart';
import 'package:health_tracker_app/core/usecase/usecase.dart';
import 'package:health_tracker_app/domain/entities/health_data.dart';
import 'package:health_tracker_app/domain/repositories/health_data_repository.dart';

class GetHealthDataRangeUseCase
    implements UseCase<List<HealthData>, HealthDataRangeParams> {
  final HealthDataRepository healthDataRepository;

  GetHealthDataRangeUseCase(this.healthDataRepository);

  @override
  Future<Either<Failure, List<HealthData>>> call(
    HealthDataRangeParams params,
  ) async {
    return await healthDataRepository.getHealthDataRange(
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}

class HealthDataRangeParams extends Equatable {
  final DateTime startDate;
  final DateTime endDate;

  const HealthDataRangeParams({required this.startDate, required this.endDate});

  @override
  List<Object?> get props => [startDate, endDate];
}
