class LogWorkoutRequestModel {
  final String workoutType;
  final int durationInMinutes;
  final double? caloriesBurned;
  final String startedAt; // Gửi lên dạng ISO 8601 String
  final double? distanceInKm;
  final String? routePolyline;

  LogWorkoutRequestModel({
    required this.workoutType,
    required this.durationInMinutes,
    this.caloriesBurned,
    required this.startedAt,
    this.distanceInKm,
    this.routePolyline,
  });

  // Tạo JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'workoutType': workoutType,
      'durationInMinutes': durationInMinutes,
      'startedAt': startedAt,
    };

    if (caloriesBurned != null) data['caloriesBurned'] = caloriesBurned;
    if (distanceInKm != null) data['distanceInKm'] = distanceInKm;
    if (routePolyline != null) data['routePolyline'] = routePolyline;

    return data;
  }
}
