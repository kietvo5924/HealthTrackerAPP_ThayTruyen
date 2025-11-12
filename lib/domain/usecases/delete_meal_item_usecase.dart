import 'package:fpdart/fpdart.dart';
import 'package:health_tracker_app/core/error/failures.dart';
import 'package:health_tracker_app/core/usecase/usecase.dart';
import 'package:health_tracker_app/domain/repositories/nutrition_repository.dart';

// Usecase để xóa một món ăn
// Input: int (mealItemId), Output: void (null)
class DeleteMealItemUseCase implements UseCase<void, int> {
  final NutritionRepository nutritionRepository;

  DeleteMealItemUseCase(this.nutritionRepository);

  @override
  Future<Either<Failure, void>> call(int params) async {
    return await nutritionRepository.deleteMealItem(params);
  }
}
