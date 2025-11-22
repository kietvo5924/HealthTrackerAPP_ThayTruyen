import 'package:fpdart/fpdart.dart';
import 'package:health_tracker_app/core/error/failures.dart';
import 'package:health_tracker_app/domain/entities/achievement.dart';

abstract class AchievementRepository {
  Future<Either<Failure, List<UserAchievement>>> getMyAchievements();
}
