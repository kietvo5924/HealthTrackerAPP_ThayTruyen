import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:health_tracker_app/domain/entities/health_data.dart';
import 'package:health_tracker_app/domain/usecases/get_health_data_range_usecase.dart';

part 'statistics_event.dart';
part 'statistics_state.dart';

class StatisticsBloc extends Bloc<StatisticsEvent, StatisticsState> {
  final GetHealthDataRangeUseCase _getHealthDataRangeUseCase;

  StatisticsBloc({required GetHealthDataRangeUseCase getHealthDataRangeUseCase})
    : _getHealthDataRangeUseCase = getHealthDataRangeUseCase,
      super(const StatisticsState()) {
    on<StatisticsFetched>(_onStatisticsFetched);
  }

  Future<void> _onStatisticsFetched(
    StatisticsFetched event,
    Emitter<StatisticsState> emit,
  ) async {
    emit(state.copyWith(status: StatisticsStatus.loading));

    // Tính ngày bắt đầu
    final DateTime startDate = event.endDate.subtract(
      Duration(days: event.days - 1),
    );

    final result = await _getHealthDataRangeUseCase(
      HealthDataRangeParams(startDate: startDate, endDate: event.endDate),
    );

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: StatisticsStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (dataList) {
        emit(
          state.copyWith(
            status: StatisticsStatus.success,
            healthDataList: dataList,
          ),
        );
      },
    );
  }
}
