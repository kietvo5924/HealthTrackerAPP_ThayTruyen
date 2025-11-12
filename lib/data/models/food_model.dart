import 'package:health_tracker_app/domain/entities/food.dart';

class FoodModel extends Food {
  const FoodModel({
    required super.id,
    required super.name,
    required super.unit,
    required super.calories,
    required super.proteinGrams,
    required super.carbsGrams,
    required super.fatGrams,
  });

  factory FoodModel.fromJson(Map<String, dynamic> json) {
    return FoodModel(
      id: json['id'],
      name: json['name'],
      unit: json['unit'],
      calories: json['calories']?.toDouble() ?? 0.0,
      proteinGrams: json['proteinGrams']?.toDouble() ?? 0.0,
      carbsGrams: json['carbsGrams']?.toDouble() ?? 0.0,
      fatGrams: json['fatGrams']?.toDouble() ?? 0.0,
    );
  }
}
