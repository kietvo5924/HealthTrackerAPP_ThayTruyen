part of 'tracking_bloc.dart';

abstract class TrackingEvent extends Equatable {
  const TrackingEvent();

  @override
  List<Object> get props => [];
}

// Yêu cầu quyền và chuẩn bị map
class TrackingStarted extends TrackingEvent {}

// Bắt đầu chạy (bấm nút Play)
class TrackingResumed extends TrackingEvent {}

// Tạm dừng (bấm nút Pause)
class TrackingPaused extends TrackingEvent {}

// Dừng hẳn (bấm nút Stop)
class TrackingStopped extends TrackingEvent {}

// Event nội bộ khi nhận được vị trí mới
class _TrackingLocationChanged extends TrackingEvent {
  final LocationData locationData;
  const _TrackingLocationChanged(this.locationData);
}
