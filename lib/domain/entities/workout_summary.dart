import 'package:equatable/equatable.dart';

class WorkoutSummary extends Equatable {
  final DateTime date;
  final int totalDurationInMinutes;
  final double totalCaloriesBurned;
  final double totalDistanceInKm;

  const WorkoutSummary({
    required this.date,
    required this.totalDurationInMinutes,
    required this.totalCaloriesBurned,
    required this.totalDistanceInKm,
  });

  @override
  List<Object?> get props => [
    date,
    totalDurationInMinutes,
    totalCaloriesBurned,
    totalDistanceInKm,
  ];
}
