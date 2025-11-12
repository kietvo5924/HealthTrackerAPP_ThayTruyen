import 'package:equatable/equatable.dart';

class Food extends Equatable {
  final int id;
  final String name;
  final String unit;
  final double calories;
  final double proteinGrams;
  final double carbsGrams;
  final double fatGrams;

  const Food({
    required this.id,
    required this.name,
    required this.unit,
    required this.calories,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    unit,
    calories,
    proteinGrams,
    carbsGrams,
    fatGrams,
  ];
}
