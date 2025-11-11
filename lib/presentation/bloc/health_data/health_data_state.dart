part of 'health_data_bloc.dart';

enum HealthDataStatus { initial, loading, success, failure }

class HealthDataState extends Equatable {
  final HealthDataStatus status;
  final HealthData healthData;
  final String errorMessage;

  // Constructor chính
  const HealthDataState({
    required this.status,
    required this.healthData,
    this.errorMessage = '',
  });

  // Constructor khởi tạo
  factory HealthDataState.initial() {
    return HealthDataState(
      status: HealthDataStatus.initial,
      healthData: HealthData.emptyToday(), // Dùng factory của Entity
    );
  }

  HealthDataState copyWith({
    HealthDataStatus? status,
    HealthData? healthData,
    String? errorMessage,
  }) {
    return HealthDataState(
      status: status ?? this.status,
      healthData: healthData ?? this.healthData,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object> get props => [status, healthData, errorMessage];
}
