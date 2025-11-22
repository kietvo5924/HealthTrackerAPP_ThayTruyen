import 'package:equatable/equatable.dart';

class Achievement extends Equatable {
  final int id;
  final String code;
  final String name;
  final String description;
  final String iconUrl;
  final int targetValue;
  final String type;

  const Achievement({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.targetValue,
    required this.type,
  });

  @override
  List<Object?> get props => [
    id,
    code,
    name,
    description,
    iconUrl,
    targetValue,
    type,
  ];
}

class UserAchievement extends Equatable {
  final int id;
  final Achievement achievement;
  final DateTime earnedAt;

  const UserAchievement({
    required this.id,
    required this.achievement,
    required this.earnedAt,
  });

  @override
  List<Object?> get props => [id, achievement, earnedAt];
}
