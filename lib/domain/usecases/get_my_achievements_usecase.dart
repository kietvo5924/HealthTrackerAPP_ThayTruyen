import 'package:fpdart/fpdart.dart';
import 'package:health_tracker_app/core/error/failures.dart';
import 'package:health_tracker_app/core/usecase/usecase.dart';
import 'package:health_tracker_app/domain/entities/achievement.dart';
import 'package:health_tracker_app/domain/repositories/achievement_repository.dart';

class GetMyAchievementsUseCase
    implements UseCase<List<UserAchievement>, NoParams> {
  final AchievementRepository repository;

  GetMyAchievementsUseCase(this.repository);

  @override
  Future<Either<Failure, List<UserAchievement>>> call(NoParams params) async {
    return await repository.getMyAchievements();
  }
}
