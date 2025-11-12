import 'package:health_tracker_app/domain/entities/workout.dart';

class WorkoutModel extends Workout {
  const WorkoutModel({
    required super.id,
    required super.workoutType,
    required super.durationInMinutes,
    super.caloriesBurned,
    required super.startedAt,
    super.distanceInKm,
    super.routePolyline,
    super.userFullName,
  });

  factory WorkoutModel.fromJson(Map<String, dynamic> json) {
    return WorkoutModel(
      id: json['id'],
      workoutType: _workoutTypeFromString(json['workoutType']),
      durationInMinutes: json['durationInMinutes'],
      caloriesBurned: json['caloriesBurned']?.toDouble(),
      startedAt: DateTime.parse(json['startedAt']), // API trả về ISO 8601
      distanceInKm: json['distanceInKm']?.toDouble(),
      routePolyline: json['routePolyline'],
      userFullName: json['userFullName'],
    );
  }

  // Hàm helper để chuyển String (từ JSON) thành Enum
  static WorkoutType _workoutTypeFromString(String type) {
    switch (type) {
      case 'RUNNING':
        return WorkoutType.RUNNING;
      case 'WALKING':
        return WorkoutType.WALKING;
      case 'CYCLING':
        return WorkoutType.CYCLING;
      case 'GYM':
        return WorkoutType.GYM;
      case 'SWIMMING':
        return WorkoutType.SWIMMING;
      default:
        return WorkoutType.OTHER;
    }
  }
}
