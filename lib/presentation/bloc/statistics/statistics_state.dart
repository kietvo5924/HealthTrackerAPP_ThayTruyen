part of 'statistics_bloc.dart';

enum StatisticsStatus { initial, loading, success, failure }

class StatisticsState extends Equatable {
  final StatisticsStatus status;
  final List<HealthData> healthDataList;
  final String errorMessage;

  const StatisticsState({
    this.status = StatisticsStatus.initial,
    this.healthDataList = const [],
    this.errorMessage = '',
  });

  StatisticsState copyWith({
    StatisticsStatus? status,
    List<HealthData>? healthDataList,
    String? errorMessage,
  }) {
    return StatisticsState(
      status: status ?? this.status,
      healthDataList: healthDataList ?? this.healthDataList,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object> get props => [status, healthDataList, errorMessage];
}
