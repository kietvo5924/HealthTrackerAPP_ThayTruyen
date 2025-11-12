import 'package:health_tracker_app/domain/entities/meal_item.dart';

class MealItemModel extends MealItem {
  const MealItemModel({
    required super.id,
    required super.foodId,
    required super.foodName,
    required super.quantity,
    required super.unit,
    required super.totalCalories,
    required super.totalProtein,
    required super.totalCarbs,
    required super.totalFat,
  });

  factory MealItemModel.fromJson(Map<String, dynamic> json) {
    return MealItemModel(
      id: json['id'],
      foodId: json['foodId'],
      foodName: json['foodName'],
      quantity: json['quantity']?.toDouble() ?? 0.0,
      unit: json['unit'],
      totalCalories: json['totalCalories']?.toDouble() ?? 0.0,
      totalProtein: json['totalProtein']?.toDouble() ?? 0.0,
      totalCarbs: json['totalCarbs']?.toDouble() ?? 0.0,
      totalFat: json['totalFat']?.toDouble() ?? 0.0,
    );
  }
}
