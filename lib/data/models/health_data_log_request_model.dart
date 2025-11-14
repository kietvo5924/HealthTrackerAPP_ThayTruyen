import 'package:health_tracker_app/domain/entities/health_data.dart';
import 'package:intl/intl.dart';

class HealthDataLogRequestModel {
  final String date;
  final int? steps;
  final double? sleepHours;
  final double? waterIntake;
  final double? weight;

  HealthDataLogRequestModel({
    required this.date,
    this.steps,
    this.sleepHours,
    this.waterIntake,
    this.weight,
  });

  // Chuyển đổi từ Entity (mà BLoC đang giữ) sang Request Model
  factory HealthDataLogRequestModel.fromEntity(HealthData entity) {
    return HealthDataLogRequestModel(
      date: DateFormat('yyyy-MM-dd').format(entity.date),
      steps: entity.steps,
      sleepHours: entity.sleepHours,
      waterIntake: entity.waterIntake,
      weight: entity.weight,
    );
  }

  // Tạo JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {'date': date};
    // Chỉ thêm vào JSON nếu giá trị không null
    if (steps != null) data['steps'] = steps;
    if (sleepHours != null) data['sleepHours'] = sleepHours;
    if (waterIntake != null) data['waterIntake'] = waterIntake;
    if (weight != null) data['weight'] = weight;
    return data;
  }
}
