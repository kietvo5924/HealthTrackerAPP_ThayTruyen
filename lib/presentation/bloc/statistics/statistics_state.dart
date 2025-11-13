part of 'statistics_bloc.dart';

enum StatisticsStatus { initial, loading, success, failure }

class StatisticsState extends Equatable {
  final StatisticsStatus status;
  final List<HealthData> healthDataList;
  final String errorMessage;
  final int selectedDays;
  final List<NutritionSummary> nutritionSummaryList;
  final List<WorkoutSummary> workoutSummaryList;

  const StatisticsState({
    this.status = StatisticsStatus.initial,
    this.healthDataList = const [],
    this.errorMessage = '',
    this.selectedDays = 7,
    this.nutritionSummaryList = const [],
    this.workoutSummaryList = const [],
  });

  StatisticsState copyWith({
    StatisticsStatus? status,
    List<HealthData>? healthDataList,
    String? errorMessage,
    int? selectedDays,
    List<NutritionSummary>? nutritionSummaryList,
    List<WorkoutSummary>? workoutSummaryList,
  }) {
    return StatisticsState(
      status: status ?? this.status,
      healthDataList: healthDataList ?? this.healthDataList,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedDays: selectedDays ?? this.selectedDays,
      nutritionSummaryList: nutritionSummaryList ?? this.nutritionSummaryList,
      workoutSummaryList: workoutSummaryList ?? this.workoutSummaryList,
    );
  }

  @override
  List<Object> get props => [
    status,
    healthDataList,
    errorMessage,
    selectedDays,
    nutritionSummaryList,
    workoutSummaryList,
  ];
}
