import 'package:equatable/equatable.dart';

class HealthData extends Equatable {
  final int? id;
  final DateTime date;
  final int? steps;
  final double? caloriesBurnt;
  final double? sleepHours;
  final double? waterIntake;
  final double? weight;

  const HealthData({
    this.id,
    required this.date,
    this.steps,
    this.caloriesBurnt,
    this.sleepHours,
    this.waterIntake,
    this.weight,
  });

  // Một factory để tạo đối tượng rỗng cho ngày hôm nay
  factory HealthData.emptyToday() {
    return HealthData(date: DateTime.now());
  }

  @override
  List<Object?> get props => [
    id,
    date,
    steps,
    caloriesBurnt,
    sleepHours,
    waterIntake,
    weight,
  ];
}
