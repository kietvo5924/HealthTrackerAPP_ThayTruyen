import 'package:fpdart/fpdart.dart';
import 'package:health_tracker_app/core/error/failures.dart';
import 'package:health_tracker_app/core/usecase/usecase.dart';
import 'package:health_tracker_app/domain/entities/food.dart';
import 'package:health_tracker_app/domain/repositories/nutrition_repository.dart';

// Usecase để tìm kiếm thực phẩm
// Input: String (query), Output: List<Food>
class SearchFoodUseCase implements UseCase<List<Food>, String> {
  final NutritionRepository nutritionRepository;

  SearchFoodUseCase(this.nutritionRepository);

  @override
  Future<Either<Failure, List<Food>>> call(String params) async {
    return await nutritionRepository.searchFood(params);
  }
}
