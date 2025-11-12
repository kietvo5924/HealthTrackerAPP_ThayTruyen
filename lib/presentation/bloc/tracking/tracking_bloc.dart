import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

part 'tracking_event.dart';
part 'tracking_state.dart';

class TrackingBloc extends Bloc<TrackingEvent, TrackingState> {
  final Location _location;
  StreamSubscription<LocationData>? _locationSubscription;
  Timer? _timer;

  TrackingBloc({required Location location})
    : _location = location,
      super(const TrackingState()) {
    on<TrackingStarted>(_onTrackingStarted);
    on<TrackingResumed>(_onTrackingResumed);
    on<TrackingPaused>(_onTrackingPaused);
    on<TrackingStopped>(_onTrackingStopped);
    on<_TrackingLocationChanged>(_onTrackingLocationChanged);
  }

  @override
  Future<void> close() {
    _locationSubscription?.cancel();
    _timer?.cancel();
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

      // 3. Lấy vị trí đầu tiên
      final LocationData initialLocation = await _location.getLocation();
      emit(
        state.copyWith(
          status: TrackingStatus.paused, // Sẵn sàng, đang tạm dừng
          currentLocation: initialLocation,
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

  // ----- BẮT ĐẦU SỬA LỖI 1 (BLoC) -----
  // Dùng Emitter.forEach để giữ event handler "sống"
  Future<void> _onTrackingResumed(
    TrackingResumed event,
    Emitter<TrackingState> emit,
  ) async {
    await _locationSubscription?.cancel();
    _timer?.cancel();

    emit(state.copyWith(status: TrackingStatus.tracking));

    // Lắng nghe GPS
    _locationSubscription = _location.onLocationChanged.listen((
      LocationData currentLocation,
    ) {
      add(_TrackingLocationChanged(currentLocation));
    });

    // Dùng Emitter.forEach cho Timer
    // Nó sẽ giữ event handler này "sống"
    await emit.forEach<int>(
      Stream.periodic(const Duration(seconds: 1), (x) => x),
      onData: (tick) {
        return state.copyWith(durationInSeconds: state.durationInSeconds + 1);
      },
    );
  }

  Future<void> _onTrackingPaused(
    TrackingPaused event,
    Emitter<TrackingState> emit,
  ) async {
    // Khi pause, chúng ta phải hủy các stream
    await _locationSubscription?.cancel();
    _timer?.cancel();

    // (Quan trọng) Hủy Emitter.forEach của _onTrackingResumed
    // bằng cách emit một state MỚI (không phải từ forEach)
    emit(state.copyWith(status: TrackingStatus.paused));
  }

  Future<void> _onTrackingStopped(
    TrackingStopped event,
    Emitter<TrackingState> emit,
  ) async {
    // Tương tự _onTrackingPaused, hủy mọi thứ
    await _locationSubscription?.cancel();
    _timer?.cancel();
    emit(state.copyWith(status: TrackingStatus.success));
  }
  // ----- KẾT THÚC SỬA LỖI 1 -----

  void _onTrackingLocationChanged(
    _TrackingLocationChanged event,
    Emitter<TrackingState> emit,
  ) {
    // (Kiểm tra xem BLoC còn hoạt động không)
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
}
