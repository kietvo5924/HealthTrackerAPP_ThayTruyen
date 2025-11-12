import 'package:fpdart/fpdart.dart';
import 'package:health_tracker_app/core/error/failures.dart';
import 'package:health_tracker_app/domain/entities/food.dart';
import 'package:health_tracker_app/domain/entities/meal.dart';

// Hợp đồng cho tất cả các hoạt động liên quan đến Dinh dưỡng
abstract class NutritionRepository {
  /// API: GET /api/nutrition/food?query=...
  Future<Either<Failure, List<Food>>> searchFood(String query);

  /// API: GET /api/nutrition/meals?date=...
  Future<Either<Failure, List<Meal>>> getMealsForDate(DateTime date);

  /// API: POST /api/nutrition/meals/item
  Future<Either<Failure, Meal>> addFoodToMeal({
    required int foodId,
    required DateTime date,
    required MealType mealType,
    required double quantity,
  });

  /// API: DELETE /api/nutrition/meals/item/{itemId}
  Future<Either<Failure, void>> deleteMealItem(int mealItemId);
}
