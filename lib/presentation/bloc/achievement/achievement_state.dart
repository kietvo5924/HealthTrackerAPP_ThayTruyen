part of 'achievement_bloc.dart';

enum AchievementStatus { initial, loading, success, failure }

class AchievementState extends Equatable {
  final AchievementStatus status;
  final List<UserAchievement> achievements;
  final String errorMessage;

  const AchievementState({
    this.status = AchievementStatus.initial,
    this.achievements = const [],
    this.errorMessage = '',
  });

  AchievementState copyWith({
    AchievementStatus? status,
    List<UserAchievement>? achievements,
    String? errorMessage,
  }) {
    return AchievementState(
      status: status ?? this.status,
      achievements: achievements ?? this.achievements,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object> get props => [status, achievements, errorMessage];
}
