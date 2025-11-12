import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:health_tracker_app/core/error/failures.dart';
import 'package:health_tracker_app/core/usecase/usecase.dart';
import 'package:health_tracker_app/domain/entities/meal.dart';
import 'package:health_tracker_app/domain/repositories/nutrition_repository.dart';

// Usecase để thêm món ăn
// Input: AddFoodParams, Output: Meal (bữa ăn đã được cập nhật)
class AddFoodToMealUseCase implements UseCase<Meal, AddFoodParams> {
  final NutritionRepository nutritionRepository;

  AddFoodToMealUseCase(this.nutritionRepository);

  @override
  Future<Either<Failure, Meal>> call(AddFoodParams params) async {
    return await nutritionRepository.addFoodToMeal(
      foodId: params.foodId,
      date: params.date,
      mealType: params.mealType,
      quantity: params.quantity,
    );
  }
}

// Class chứa các tham số cho Usecase
class AddFoodParams extends Equatable {
  final int foodId;
  final DateTime date;
  final MealType mealType;
  final double quantity;

  const AddFoodParams({
    required this.foodId,
    required this.date,
    required this.mealType,
    required this.quantity,
  });

  @override
  List<Object?> get props => [foodId, date, mealType, quantity];
}
