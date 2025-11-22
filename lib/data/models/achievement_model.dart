import 'package:health_tracker_app/domain/entities/achievement.dart';

class AchievementModel extends Achievement {
  const AchievementModel({
    required super.id,
    required super.code,
    required super.name,
    required super.description,
    required super.iconUrl,
    required super.targetValue,
    required super.type,
  });

  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    return AchievementModel(
      id: json['id'],
      code: json['code'],
      name: json['name'],
      description: json['description'],
      iconUrl: json['iconUrl'] ?? '',
      targetValue: json['targetValue'],
      type: json['type'],
    );
  }
}

class UserAchievementModel extends UserAchievement {
  const UserAchievementModel({
    required super.id,
    required AchievementModel super.achievement,
    required super.earnedAt,
  });

  factory UserAchievementModel.fromJson(Map<String, dynamic> json) {
    return UserAchievementModel(
      id: json['id'],
      achievement: AchievementModel.fromJson(json['achievement']),
      earnedAt: DateTime.parse(json['earnedAt']),
    );
  }
}
