import 'package:health_tracker_app/domain/entities/workout_summary.dart';

class WorkoutSummaryModel extends WorkoutSummary {
  const WorkoutSummaryModel({
    required super.date,
    required super.totalDurationInMinutes,
    required super.totalCaloriesBurned,
    required super.totalDistanceInKm,
  });

  factory WorkoutSummaryModel.fromJson(Map<String, dynamic> json) {
    return WorkoutSummaryModel(
      date: DateTime.parse(json['date']),
      totalDurationInMinutes:
          (json['totalDurationInMinutes'] as num?)?.toInt() ?? 0,
      totalCaloriesBurned:
          (json['totalCaloriesBurned'] as num?)?.toDouble() ?? 0.0,
      totalDistanceInKm: (json['totalDistanceInKm'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
