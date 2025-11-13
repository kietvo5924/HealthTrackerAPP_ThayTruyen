import 'package:equatable/equatable.dart';

class NutritionSummary extends Equatable {
  final DateTime date;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final double totalCalories;

  const NutritionSummary({
    required this.date,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    required this.totalCalories,
  });

  @override
  List<Object?> get props => [
    date,
    totalProtein,
    totalCarbs,
    totalFat,
    totalCalories,
  ];
}
