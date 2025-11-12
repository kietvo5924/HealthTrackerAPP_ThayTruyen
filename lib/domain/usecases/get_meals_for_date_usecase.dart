import 'package:fpdart/fpdart.dart';
import 'package:health_tracker_app/core/error/failures.dart';
import 'package:health_tracker_app/core/usecase/usecase.dart';
import 'package:health_tracker_app/domain/entities/meal.dart';
import 'package:health_tracker_app/domain/repositories/nutrition_repository.dart';

// Usecase để lấy bữa ăn theo ngày
// Input: DateTime (date), Output: List<Meal>
class GetMealsForDateUseCase implements UseCase<List<Meal>, DateTime> {
  final NutritionRepository nutritionRepository;

  GetMealsForDateUseCase(this.nutritionRepository);

  @override
  Future<Either<Failure, List<Meal>>> call(DateTime params) async {
    return await nutritionRepository.getMealsForDate(params);
  }
}
