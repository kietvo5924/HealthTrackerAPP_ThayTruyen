import 'package:equatable/equatable.dart';
import 'package:health_tracker_app/domain/entities/meal_item.dart';

// Enum giống hệt backend
// ignore: constant_identifier_names
enum MealType { BREAKFAST, LUNCH, DINNER, SNACK }

class Meal extends Equatable {
  final int id;
  final MealType mealType;
  final List<MealItem> items;
  final double totalMealCalories;

  const Meal({
    required this.id,
    required this.mealType,
    required this.items,
    required this.totalMealCalories,
  });

  @override
  List<Object?> get props => [id, mealType, items, totalMealCalories];
}
