import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:health_tracker_app/core/error/failures.dart';
import 'package:health_tracker_app/domain/entities/health_data.dart';
import 'package:health_tracker_app/domain/entities/nutrition_summary.dart';
import 'package:health_tracker_app/domain/entities/workout_summary.dart';
import 'package:health_tracker_app/domain/usecases/get_health_data_range_usecase.dart';
import 'package:health_tracker_app/domain/usecases/get_nutrition_summary_usecase.dart';
import 'package:health_tracker_app/domain/usecases/get_workout_summary_usecase.dart';

part 'statistics_event.dart';
part 'statistics_state.dart';

class StatisticsBloc extends Bloc<StatisticsEvent, StatisticsState> {
  final GetHealthDataRangeUseCase _getHealthDataRangeUseCase;
  final GetNutritionSummaryUseCase _getNutritionSummaryUseCase;
  final GetWorkoutSummaryUseCase _getWorkoutSummaryUseCase;

  StatisticsBloc({
    required GetHealthDataRangeUseCase getHealthDataRangeUseCase,
    required GetNutritionSummaryUseCase getNutritionSummaryUseCase,
    required GetWorkoutSummaryUseCase getWorkoutSummaryUseCase,
  }) : _getHealthDataRangeUseCase = getHealthDataRangeUseCase,
       _getNutritionSummaryUseCase = getNutritionSummaryUseCase,
       _getWorkoutSummaryUseCase = getWorkoutSummaryUseCase,
       super(const StatisticsState(selectedDays: 7)) {
    on<StatisticsFetched>(_onStatisticsFetched);
    on<StatisticsDaysChanged>(_onDaysChanged);
  }

  Future<void> _onStatisticsFetched(
    StatisticsFetched event,
    Emitter<StatisticsState> emit,
  ) async {
    emit(
      state.copyWith(
        status: StatisticsStatus.loading,
        // Xóa dữ liệu cũ khi tải
        healthDataList: [],
        nutritionSummaryList: [],
        workoutSummaryList: [],
      ),
    );

    final DateTime startDate = event.endDate.subtract(
      Duration(days: event.days - 1),
    );
    final params = HealthDataRangeParams(
      startDate: startDate,
      endDate: event.endDate,
    );

    // === GỌI CẢ 3 API CÙNG LÚC ===
    final results = await Future.wait([
      _getHealthDataRangeUseCase(params),
      _getNutritionSummaryUseCase(params),
      _getWorkoutSummaryUseCase(params),
    ]);

    // === XỬ LÝ KẾT QUẢ ===
    final healthDataResult = results[0] as Either<Failure, List<HealthData>>;
    final nutritionResult =
        results[1] as Either<Failure, List<NutritionSummary>>;
    final workoutResult = results[2] as Either<Failure, List<WorkoutSummary>>;

    // Xử lý lỗi (nếu bất kỳ API nào lỗi, báo lỗi chung)
    String? errorMessage;
    healthDataResult.fold((f) => errorMessage = f.message, (r) => null);
    nutritionResult.fold((f) => errorMessage = f.message, (r) => null);
    workoutResult.fold((f) => errorMessage = f.message, (r) => null);

    if (errorMessage != null) {
      emit(
        state.copyWith(
          status: StatisticsStatus.failure,
          errorMessage: errorMessage,
          selectedDays: event.days,
        ),
      );
    } else {
      // Nếu tất cả thành công
      emit(
        state.copyWith(
          status: StatisticsStatus.success,
          healthDataList: healthDataResult.getOrElse((_) => []),
          nutritionSummaryList: nutritionResult.getOrElse((_) => []),
          workoutSummaryList: workoutResult.getOrElse((_) => []),
          selectedDays: event.days,
        ),
      );
    }
  }

  Future<void> _onDaysChanged(
    StatisticsDaysChanged event,
    Emitter<StatisticsState> emit,
  ) async {
    // 1. Phát ra state loading với số ngày mới
    emit(
      state.copyWith(
        selectedDays: event.days,
        status: StatisticsStatus.loading,
      ),
    );

    // 2. Kích hoạt lại việc tải dữ liệu bằng event StatisticsFetched
    add(StatisticsFetched(endDate: DateTime.now(), days: event.days));
  }
}
