part of 'tracking_bloc.dart';

enum TrackingStatus { initial, loading, tracking, paused, failure, success }

class TrackingState extends Equatable {
  final TrackingStatus status;
  final int durationInSeconds; // Thời gian (giây)
  final List<LatLng> routePoints; // Các điểm toạ độ để vẽ đường
  final LocationData? currentLocation; // Vị trí hiện tại
  final String? errorMessage;
  final double currentWeightKg; // Cân nặng của user
  final double caloriesBurned; // Calo đã đốt

  const TrackingState({
    this.status = TrackingStatus.initial,
    this.durationInSeconds = 0,
    this.routePoints = const [],
    this.currentLocation,
    this.errorMessage,
    this.currentWeightKg = 60.0, // Mặc định 60kg
    this.caloriesBurned = 0.0,
  });

  TrackingState copyWith({
    TrackingStatus? status,
    int? durationInSeconds,
    List<LatLng>? routePoints,
    LocationData? currentLocation,
    String? errorMessage,
    double? currentWeightKg,
    double? caloriesBurned,
  }) {
    return TrackingState(
      status: status ?? this.status,
      durationInSeconds: durationInSeconds ?? this.durationInSeconds,
      routePoints: routePoints ?? this.routePoints,
      currentLocation: currentLocation ?? this.currentLocation,
      errorMessage: errorMessage ?? this.errorMessage,
      currentWeightKg: currentWeightKg ?? this.currentWeightKg,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
    );
  }

  @override
  List<Object?> get props => [
    status,
    durationInSeconds,
    routePoints,
    currentLocation,
    errorMessage,
    currentWeightKg,
    caloriesBurned,
  ];
}
