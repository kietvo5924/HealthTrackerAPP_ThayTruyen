import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:health_tracker_app/data/models/health_data_model.dart';
import 'package:health_tracker_app/domain/entities/health_data.dart';
import 'package:health_tracker_app/domain/usecases/get_health_data_usecase.dart';
import 'package:health_tracker_app/domain/usecases/log_health_data_usecase.dart';
import 'package:pedometer/pedometer.dart';

part 'health_data_event.dart';
part 'health_data_state.dart';

class HealthDataBloc extends Bloc<HealthDataEvent, HealthDataState> {
  final GetHealthDataUseCase _getHealthDataUseCase;
  final LogHealthDataUseCase _logHealthDataUseCase;

  StreamSubscription<StepCount>? _stepCountSubscription;
  int _initialSteps = 0;

  HealthDataBloc({
    required GetHealthDataUseCase getHealthDataUseCase,
    required LogHealthDataUseCase logHealthDataUseCase,
  }) : _getHealthDataUseCase = getHealthDataUseCase,
       _logHealthDataUseCase = logHealthDataUseCase,
       super(HealthDataState.initial()) {
    // Dùng constructor factory
    on<HealthDataFetched>(_onHealthDataFetched);
    on<HealthDataWaterChanged>(_onHealthDataWaterChanged);
    on<HealthDataWeightChanged>(_onHealthDataWeightChanged);
    on<HealthDataLogged>(_onHealthDataLogged);
    on<HealthDataStepSensorStarted>(_onStepSensorStarted);
    on<_HealthDataStepSensorUpdated>(_onStepSensorUpdated);
  }

  @override
  Future<void> close() {
    _stepCountSubscription?.cancel();
    return super.close();
  }

  Future<void> _onHealthDataFetched(
    HealthDataFetched event,
    Emitter<HealthDataState> emit,
  ) async {
    emit(state.copyWith(status: HealthDataStatus.loading));

    final result = await _getHealthDataUseCase(event.date);

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: HealthDataStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (healthData) {
        emit(
          state.copyWith(
            status: HealthDataStatus.success,
            healthData: healthData,
          ),
        );

        add(HealthDataStepSensorStarted());
      },
    );
  }

  // Hàm này chỉ cập nhật state ở UI, chưa gọi API
  void _onHealthDataWaterChanged(
    HealthDataWaterChanged event,
    Emitter<HealthDataState> emit,
  ) {
    // Dùng HealthDataModel để copy
    final updatedData = HealthDataModel(
      id: state.healthData.id,
      date: state.healthData.date,
      steps: state.healthData.steps,
      caloriesBurnt: state.healthData.caloriesBurnt,
      sleepHours: state.healthData.sleepHours,
      waterIntake: event.waterIntake, // Cập nhật
      weight: state.healthData.weight,
    );
    emit(state.copyWith(healthData: updatedData));
  }

  // Hàm này chỉ cập nhật state ở UI, chưa gọi API
  void _onHealthDataWeightChanged(
    HealthDataWeightChanged event,
    Emitter<HealthDataState> emit,
  ) {
    final updatedData = HealthDataModel(
      id: state.healthData.id,
      date: state.healthData.date,
      steps: state.healthData.steps,
      caloriesBurnt: state.healthData.caloriesBurnt,
      sleepHours: state.healthData.sleepHours,
      waterIntake: state.healthData.waterIntake,
      weight: event.weight, // Cập nhật
    );
    emit(state.copyWith(healthData: updatedData));
  }

  // Hàm này gọi API để lưu
  Future<void> _onHealthDataLogged(
    HealthDataLogged event,
    Emitter<HealthDataState> emit,
  ) async {
    // Dùng state.healthData (đã được cập nhật ở trên) để gửi

    emit(state.copyWith(status: HealthDataStatus.loading)); // Hiển thị loading

    final result = await _logHealthDataUseCase(state.healthData);

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: HealthDataStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (updatedHealthData) {
        // API trả về data đã cập nhật, ta cập nhật lại state
        emit(
          state.copyWith(
            status: HealthDataStatus.success,
            healthData: updatedHealthData,
          ),
        );
      },
    );
  }

  Future<void> _onStepSensorStarted(
    HealthDataStepSensorStarted event,
    Emitter<HealthDataState> emit,
  ) async {
    // Hủy stream cũ nếu có
    await _stepCountSubscription?.cancel();

    try {
      // 1. Lấy số bước hiện tại làm mốc
      // Thư viện Pedometer trả về tổng số bước kể từ khi máy khởi động
      final StepCount now = await Pedometer.stepCountStream.first;
      _initialSteps = now.steps;

      // 2. Lắng nghe thay đổi
      _stepCountSubscription = Pedometer.stepCountStream.listen(
        (StepCount event) {
          // Tính số bước đi mới (tổng - mốc) + số bước đã lưu (từ API)
          final int stepsAlreadySaved = state.healthData.steps ?? 0;
          final int stepsSinceAppOpen = event.steps - _initialSteps;

          final int totalStepsToday = stepsAlreadySaved + stepsSinceAppOpen;

          // Thêm event nội bộ để cập nhật
          add(_HealthDataStepSensorUpdated(totalStepsToday));
        },
        onError: (error) {
          // (Bạn có thể emit lỗi ở đây)
        },
      );
    } catch (error) {
      // (Bạn có thể emit lỗi ở đây, ví dụ: "Không có cảm biến")
    }
  }

  void _onStepSensorUpdated(
    _HealthDataStepSensorUpdated event,
    Emitter<HealthDataState> emit,
  ) {
    // Chỉ cập nhật nếu số bước mới > số bước cũ
    if (event.steps > (state.healthData.steps ?? 0)) {
      final updatedData = HealthDataModel(
        id: state.healthData.id,
        date: state.healthData.date,
        steps: event.steps, // Cập nhật
        caloriesBurnt: state.healthData.caloriesBurnt,
        sleepHours: state.healthData.sleepHours,
        waterIntake: state.healthData.waterIntake,
        weight: state.healthData.weight,
      );
      emit(
        state.copyWith(
          healthData: updatedData,
          // Chuyển sang success để UI cập nhật
          status: HealthDataStatus.success,
        ),
      );

      // (Nâng cao: Bạn có thể thêm logic để gọi HealthDataLogged()
      // chỉ sau 100 bước hoặc 5 phút để tránh gọi API liên tục)
    }
  }
}
