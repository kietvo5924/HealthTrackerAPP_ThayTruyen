part of 'health_data_bloc.dart';

abstract class HealthDataEvent extends Equatable {
  const HealthDataEvent();

  @override
  List<Object> get props => [];
}

class HealthDataFetched extends HealthDataEvent {
  final DateTime date;
  const HealthDataFetched(this.date);
}

class HealthDataLogged extends HealthDataEvent {}

class HealthDataWaterChanged extends HealthDataEvent {
  final double waterIntake;
  const HealthDataWaterChanged(this.waterIntake);
}

class HealthDataWeightChanged extends HealthDataEvent {
  final double weight;
  const HealthDataWeightChanged(this.weight);
}

// Event để khởi tạo việc lắng nghe cảm biến
class HealthDataStepSensorStarted extends HealthDataEvent {}

// Event nội bộ, được kích hoạt khi cảm biến có dữ liệu mới
// (Đổi tên _HealthDataStepSensorUpdated -> HealthDataStepSensorUpdated)
class HealthDataStepSensorUpdated extends HealthDataEvent {
  final int steps;
  const HealthDataStepSensorUpdated(this.steps);
}

// Event nội bộ, để lưu số bước đi vào API (một cách âm thầm)
class HealthDataStepsSaved extends HealthDataEvent {}
