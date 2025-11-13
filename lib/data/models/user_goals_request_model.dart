// File này dùng để tạo JSON body gửi lên API
class UserGoalsRequestModel {
  final int? goalSteps;
  final double? goalWater;
  final double? goalSleep;
  final int? goalCaloriesBurnt;
  final int? goalCaloriesConsumed;

  UserGoalsRequestModel({
    this.goalSteps,
    this.goalWater,
    this.goalSleep,
    this.goalCaloriesBurnt,
    this.goalCaloriesConsumed,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    if (goalSteps != null) json['goalSteps'] = goalSteps;
    if (goalWater != null) json['goalWater'] = goalWater;
    if (goalSleep != null) json['goalSleep'] = goalSleep;
    if (goalCaloriesBurnt != null)
      json['goalCaloriesBurnt'] = goalCaloriesBurnt;
    if (goalCaloriesConsumed != null)
      json['goalCaloriesConsumed'] = goalCaloriesConsumed;
    return json;
  }
}
