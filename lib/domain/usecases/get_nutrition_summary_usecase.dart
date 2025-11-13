import 'package:fpdart/fpdart.dart';
import 'package:health_tracker_app/core/error/failures.dart';
import 'package:health_tracker_app/core/usecase/usecase.dart';
import 'package:health_tracker_app/domain/entities/nutrition_summary.dart';
import 'package:health_tracker_app/domain/repositories/nutrition_repository.dart';
import 'package:health_tracker_app/domain/usecases/get_health_data_range_usecase.dart'; // <-- TÁI SỬ DỤNG

class GetNutritionSummaryUseCase
    implements UseCase<List<NutritionSummary>, HealthDataRangeParams> {
  final NutritionRepository nutritionRepository;

  GetNutritionSummaryUseCase(this.nutritionRepository);

  @override
  Future<Either<Failure, List<NutritionSummary>>> call(
    HealthDataRangeParams params,
  ) async {
    return await nutritionRepository.getNutritionSummary(
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}
