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
  final String? userFullName;
  final int likeCount;
  final bool likedByCurrentUser;

  const Workout({
    required this.id,
    required this.workoutType,
    required this.durationInMinutes,
    this.caloriesBurned,
    required this.startedAt,
    this.distanceInKm,
    this.routePolyline,
    this.userFullName,
    required this.likeCount,
    required this.likedByCurrentUser,
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
    userFullName,
    likeCount,
    likedByCurrentUser,
  ];

  Workout copyWith({
    int? id,
    WorkoutType? workoutType,
    int? durationInMinutes,
    double? caloriesBurned,
    DateTime? startedAt,
    double? distanceInKm,
    String? routePolyline,
    String? userFullName,
    int? likeCount,
    bool? likedByCurrentUser,
  }) {
    return Workout(
      id: id ?? this.id,
      workoutType: workoutType ?? this.workoutType,
      durationInMinutes: durationInMinutes ?? this.durationInMinutes,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      startedAt: startedAt ?? this.startedAt,
      distanceInKm: distanceInKm ?? this.distanceInKm,
      routePolyline: routePolyline ?? this.routePolyline,
      userFullName: userFullName ?? this.userFullName,
      likeCount: likeCount ?? this.likeCount,
      likedByCurrentUser: likedByCurrentUser ?? this.likedByCurrentUser,
    );
  }
}
