import 'package:health_tracker_app/domain/entities/nutrition_summary.dart';

class NutritionSummaryModel extends NutritionSummary {
  const NutritionSummaryModel({
    required super.date,
    required super.totalProtein,
    required super.totalCarbs,
    required super.totalFat,
    required super.totalCalories,
  });

  factory NutritionSummaryModel.fromJson(Map<String, dynamic> json) {
    return NutritionSummaryModel(
      date: DateTime.parse(json['date']),
      totalProtein: (json['totalProtein'] as num?)?.toDouble() ?? 0.0,
      totalCarbs: (json['totalCarbs'] as num?)?.toDouble() ?? 0.0,
      totalFat: (json['totalFat'] as num?)?.toDouble() ?? 0.0,
      totalCalories: (json['totalCalories'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
