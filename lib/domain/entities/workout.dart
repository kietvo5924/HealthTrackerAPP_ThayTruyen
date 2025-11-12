import 'package:equatable/equatable.dart';

// Định nghĩa Enum giống hệt backend
// ignore: constant_identifier_names
enum WorkoutType { RUNNING, WALKING, CYCLING, GYM, SWIMMING, OTHER }

class Workout extends Equatable {
  final int id;
  final WorkoutType workoutType;
  final int durationInMinutes;
  final double? caloriesBurned;
  final DateTime startedAt;
  final double? distanceInKm;
  final String? routePolyline;

  const Workout({
    required this.id,
    required this.workoutType,
    required this.durationInMinutes,
    this.caloriesBurned,
    required this.startedAt,
    this.distanceInKm,
    this.routePolyline,
  });

  @override
  List<Object?> get props => [
    id,
    workoutType,
    durationInMinutes,
    caloriesBurned,
    startedAt,
    distanceInKm,
    routePolyline,
  ];
}
