import 'package:equatable/equatable.dart';

class MealItem extends Equatable {
  final int id;
  final int foodId;
  final String foodName;
  final double quantity;
  final String unit;
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;

  const MealItem({
    required this.id,
    required this.foodId,
    required this.foodName,
    required this.quantity,
    required this.unit,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
  });

  @override
  List<Object?> get props => [
    id,
    foodId,
    foodName,
    quantity,
    unit,
    totalCalories,
    totalProtein,
    totalCarbs,
    totalFat,
  ];
}
