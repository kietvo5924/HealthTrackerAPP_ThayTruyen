import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:health_tracker_app/domain/usecases/get_health_data_usecase.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

part 'tracking_event.dart';
part 'tracking_state.dart';

class TrackingBloc extends Bloc<TrackingEvent, TrackingState> {
  final Location _location;
  final GetHealthDataUseCase _getHealthDataUseCase;
  StreamSubscription<LocationData>? _locationSubscription;
  Timer? _timer; // Bây giờ chúng ta sẽ dùng biến này

  TrackingBloc({
    required Location location,
    required GetHealthDataUseCase getHealthDataUseCase,
  }) : _location = location,
       _getHealthDataUseCase = getHealthDataUseCase,
       super(const TrackingState()) {
    on<TrackingStarted>(_onTrackingStarted);
    on<TrackingResumed>(_onTrackingResumed);
    on<TrackingPaused>(_onTrackingPaused);
    on<TrackingStopped>(_onTrackingStopped);
    on<_TrackingLocationChanged>(_onTrackingLocationChanged);

    // Đăng ký event xử lý timer
    on<_TrackingTimerTicked>(_onTimerTicked);
  }

  @override
  Future<void> close() {
    _locationSubscription?.cancel();
    _timer?.cancel(); // Đảm bảo timer bị hủy khi BLoC đóng
    return super.close();
  }

  Future<void> _onTrackingStarted(
    TrackingStarted event,
    Emitter<TrackingState> emit,
  ) async {
    emit(state.copyWith(status: TrackingStatus.loading));
    try {
      // 1. Kiểm tra Dịch vụ
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          emit(
            state.copyWith(
              status: TrackingStatus.failure,
              errorMessage: 'Vui lòng bật GPS.',
            ),
          );
          return;
        }
      }

      // 2. Kiểm tra Quyền
      PermissionStatus permissionGranted = await _location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await _location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          emit(
            state.copyWith(
              status: TrackingStatus.failure,
              errorMessage: 'Cần cấp quyền truy cập vị trí.',
            ),
          );
          return;
        }
      }

      // 3. Lấy cân nặng (MỚI)
      double weight = state.currentWeightKg;
      final healthDataResult = await _getHealthDataUseCase(DateTime.now());
      healthDataResult.fold(
        (l) => null, // Bỏ qua nếu lỗi, dùng cân nặng mặc định
        (healthData) {
          if (healthData.weight != null && healthData.weight! > 0) {
            weight = healthData.weight!;
          }
        },
      );

      // 4. Lấy vị trí đầu tiên
      final LocationData initialLocation = await _location.getLocation();
      emit(
        state.copyWith(
          status: TrackingStatus.paused, // Sẵn sàng, đang tạm dừng
          currentLocation: initialLocation,
          currentWeightKg: weight,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: TrackingStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // Sửa lỗi: Dùng Timer và add event
  void _onTrackingResumed(TrackingResumed event, Emitter<TrackingState> emit) {
    emit(state.copyWith(status: TrackingStatus.tracking));

    // Bắt đầu timer
    _timer?.cancel(); // Hủy timer cũ (nếu có)
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // THAY VÌ EMIT, CHÚNG TA ADD EVENT
      add(_TrackingTimerTicked());
    });

    // Bắt đầu lắng nghe GPS
    _locationSubscription?.cancel();
    _locationSubscription = _location.onLocationChanged.listen((
      LocationData currentLocation,
    ) {
      add(_TrackingLocationChanged(currentLocation));
    });
  }

  // Sửa lỗi: Hàm này giờ sẽ hoạt động
  void _onTrackingPaused(TrackingPaused event, Emitter<TrackingState> emit) {
    _timer?.cancel(); // Hủy timer
    _locationSubscription?.cancel(); // Hủy GPS
    emit(state.copyWith(status: TrackingStatus.paused));
  }

  // Sửa lỗi: Hàm này giờ sẽ hoạt động
  void _onTrackingStopped(TrackingStopped event, Emitter<TrackingState> emit) {
    _timer?.cancel(); // Hủy timer
    _locationSubscription?.cancel(); // Hủy GPS
    emit(state.copyWith(status: TrackingStatus.success));
  }

  void _onTrackingLocationChanged(
    _TrackingLocationChanged event,
    Emitter<TrackingState> emit,
  ) {
    if (emit.isDone) return;

    final newPoint = LatLng(
      event.locationData.latitude!,
      event.locationData.longitude!,
    );

    emit(
      state.copyWith(
        currentLocation: event.locationData,
        routePoints: [...state.routePoints, newPoint], // Thêm điểm mới
      ),
    );
  }

  // Hàm xử lý Timer Tick
  void _onTimerTicked(_TrackingTimerTicked event, Emitter<TrackingState> emit) {
    if (emit.isDone) return;

    // Tính Calo
    final double caloriesPerSecond = _calculateCaloriesPerSecond();
    final double newTotalCalories = state.caloriesBurned + caloriesPerSecond;

    emit(
      state.copyWith(
        durationInSeconds: state.durationInSeconds + 1,
        caloriesBurned: newTotalCalories,
      ),
    );
  }

  // Tính Calo/Giây dùng công thức MET
  double _calculateCaloriesPerSecond() {
    // 1. Lấy MET value (ước lượng)
    const double metValue = 9.8; // MET cho Chạy bộ

    // 2. Lấy cân nặng
    final double weight = state.currentWeightKg;
    if (weight <= 0) return 0;

    // 3. Công thức: (MET * 3.5 * Cân nặng (kg)) / 200 = Calo/Phút
    final double caloriesPerMinute = (metValue * 3.5 * weight) / 200.0;

    // 4. Trả về Calo/Giây
    return caloriesPerMinute / 60.0;
  }
}
