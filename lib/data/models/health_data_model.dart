import 'package:health_tracker_app/domain/entities/health_data.dart';

class HealthDataModel extends HealthData {
  const HealthDataModel({
    super.id,
    required super.date,
    super.steps,
    super.caloriesBurnt,
    super.sleepHours,
    super.waterIntake,
    super.weight,
  });

  factory HealthDataModel.fromJson(Map<String, dynamic> json) {
    return HealthDataModel(
      id: json['id'],
      date: DateTime.parse(json['date']),
      steps: json['steps'],
      caloriesBurnt: json['caloriesBurnt']?.toDouble(),
      sleepHours: json['sleepHours']?.toDouble(),
      waterIntake: json['waterIntake']?.toDouble(),
      weight: json['weight']?.toDouble(),
    );
  }
}
