import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:health_tracker_app/data/models/health_data_model.dart';
import 'package:health_tracker_app/domain/entities/health_data.dart';
import 'package:health_tracker_app/domain/usecases/get_health_data_usecase.dart';
import 'package:health_tracker_app/domain/usecases/log_health_data_usecase.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

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
    on<HealthDataStepSensorUpdated>(_onStepSensorUpdated); // Đổi tên event
    on<HealthDataStepsSaved>(_onHealthDataStepsSaved);
    on<HealthDataSleepChanged>(_onHealthDataSleepChanged);
    on<HealthDataCaloriesChanged>(_onHealthDataCaloriesChanged);
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

  // Hàm này chỉ cập nhật state ở UI, chưa gọi API
  void _onHealthDataSleepChanged(
    HealthDataSleepChanged event,
    Emitter<HealthDataState> emit,
  ) {
    final updatedData = HealthDataModel(
      id: state.healthData.id,
      date: state.healthData.date,
      steps: state.healthData.steps,
      caloriesBurnt: state.healthData.caloriesBurnt,
      sleepHours: event.sleepHours, // Cập nhật
      waterIntake: state.healthData.waterIntake,
      weight: state.healthData.weight,
    );
    emit(state.copyWith(healthData: updatedData));
  }

  // Hàm này chỉ cập nhật state ở UI, chưa gọi API
  void _onHealthDataCaloriesChanged(
    HealthDataCaloriesChanged event,
    Emitter<HealthDataState> emit,
  ) {
    // Lưu ý: Chúng ta dùng chung trường 'caloriesBurnt' cho 'calo tiêu thụ'
    // Nếu backend của bạn có trường riêng (ví dụ: caloriesConsumed),
    // bạn cần cập nhật HealthDataModel
    final updatedData = HealthDataModel(
      id: state.healthData.id,
      date: state.healthData.date,
      steps: state.healthData.steps,
      caloriesBurnt: event.calories, // Cập nhật
      sleepHours: state.healthData.sleepHours,
      waterIntake: state.healthData.waterIntake,
      weight: state.healthData.weight,
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
    // Hủy các stream cũ
    await _stepCountSubscription?.cancel();

    try {
      // 1. Yêu cầu quyền (Permission)
      final PermissionStatus status = await Permission.activityRecognition
          .request();

      // 2. Kiểm tra kết quả
      if (status.isGranted) {
        // Nếu được cấp quyền, bắt đầu lắng nghe
        _startListeningToSteps(emit);
      } else if (status.isDenied || status.isPermanentlyDenied) {
        // Nếu bị từ chối, phát ra lỗi
        emit(
          state.copyWith(
            status: HealthDataStatus.failure,
            errorMessage:
                'Quyền truy cập hoạt động thể chất bị từ chối. Vui lòng cấp quyền trong Cài đặt.',
          ),
        );
      }
    } catch (error) {
      emit(
        state.copyWith(
          status: HealthDataStatus.failure,
          errorMessage: 'Thiết bị không hỗ trợ cảm biến bước đi.',
        ),
      );
    }
  }

  // Hàm private mới để khởi động StepCount (chỉ gọi sau khi có quyền)
  Future<void> _startListeningToSteps(Emitter<HealthDataState> emit) async {
    await _stepCountSubscription?.cancel();
    try {
      // Lấy số bước hiện tại làm mốc
      final StepCount now = await Pedometer.stepCountStream.first;
      _initialSteps = now.steps;

      // Lắng nghe thay đổi
      _stepCountSubscription = Pedometer.stepCountStream.listen(
        (StepCount event) {
          final int stepsAlreadySaved = state.healthData.steps ?? 0;
          final int stepsSinceAppOpen = event.steps - _initialSteps;

          // Đảm bảo số bước không bị âm (nếu điện thoại khởi động lại)
          if (stepsSinceAppOpen < 0) {
            _initialSteps = event.steps; // Reset mốc
          }

          final int totalStepsToday =
              stepsAlreadySaved +
              (stepsSinceAppOpen > 0 ? stepsSinceAppOpen : 0);

          add(HealthDataStepSensorUpdated(totalStepsToday));
        },
        onError: (error) {
          emit(
            state.copyWith(
              status: HealthDataStatus.failure,
              errorMessage: 'Lỗi cảm biến bước đi.',
            ),
          );
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: HealthDataStatus.failure,
          errorMessage: 'Không thể khởi động cảm biến bước đi.',
        ),
      );
    }
  }

  void _onStepSensorUpdated(
    HealthDataStepSensorUpdated event, // Đổi tên từ _HealthData...
    Emitter<HealthDataState> emit,
  ) {
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
          status: HealthDataStatus.success, // Cập nhật UI
        ),
      );

      // --- THÊM MỚI: Tự động lưu ---
      // Lưu vào CSDL mỗi khi đi được 20 bước mới
      if (event.steps % 20 == 0) {
        add(HealthDataStepsSaved());
      }
      // --- KẾT THÚC THÊM MỚI ---
    }
  }

  // --- THÊM MỚI: Hàm lưu ngầm ---
  Future<void> _onHealthDataStepsSaved(
    HealthDataStepsSaved event,
    Emitter<HealthDataState> emit,
  ) async {
    // KHÔNG emit(loading) để tránh làm giật UI
    // ignore: avoid_print
    print('Tự động lưu số bước đi: ${state.healthData.steps}');
    final result = await _logHealthDataUseCase(state.healthData);

    result.fold(
      (failure) {
        // Chỉ in ra lỗi, không emit failure để không ảnh hưởng UI
        // ignore: avoid_print
        print('Lỗi tự động lưu bước đi: ${failure.message}');
      },
      (updatedHealthData) {
        // Lưu thành công, cập nhật lại state (với ID mới nếu có)
        // ignore: avoid_print
        print('Đã lưu bước đi thành công.');
        emit(state.copyWith(healthData: updatedHealthData));
      },
    );
  }
}
