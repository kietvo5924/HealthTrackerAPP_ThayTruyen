part of 'health_data_bloc.dart';

abstract class HealthDataEvent extends Equatable {
  const HealthDataEvent();

  @override
  List<Object> get props => [];
}

// Event để tải dữ liệu cho một ngày
class HealthDataFetched extends HealthDataEvent {
  final DateTime date;
  const HealthDataFetched(this.date);
}

// Event chung để log, chúng ta sẽ cập nhật state hiện tại
// và sau đó gọi event này để lưu
class HealthDataLogged extends HealthDataEvent {}

// Event để cập nhật state tạm thời (trước khi lưu)
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
class _HealthDataStepSensorUpdated extends HealthDataEvent {
  final int steps;
  const _HealthDataStepSensorUpdated(this.steps);
}
