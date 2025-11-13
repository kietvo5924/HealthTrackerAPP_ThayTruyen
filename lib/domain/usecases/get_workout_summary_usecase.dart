import 'package:fpdart/fpdart.dart';
import 'package:health_tracker_app/core/error/failures.dart';
import 'package:health_tracker_app/core/usecase/usecase.dart';
import 'package:health_tracker_app/domain/entities/workout_summary.dart';
import 'package:health_tracker_app/domain/repositories/workout_repository.dart';
import 'package:health_tracker_app/domain/usecases/get_health_data_range_usecase.dart'; // <-- TÁI SỬ DỤNG

class GetWorkoutSummaryUseCase
    implements UseCase<List<WorkoutSummary>, HealthDataRangeParams> {
  final WorkoutRepository workoutRepository;

  GetWorkoutSummaryUseCase(this.workoutRepository);

  @override
  Future<Either<Failure, List<WorkoutSummary>>> call(
    HealthDataRangeParams params,
  ) async {
    return await workoutRepository.getWorkoutSummary(
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}
