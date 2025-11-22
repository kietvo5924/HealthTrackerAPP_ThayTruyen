import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:health_tracker_app/core/usecase/usecase.dart';
import 'package:health_tracker_app/domain/entities/achievement.dart';
import 'package:health_tracker_app/domain/usecases/get_my_achievements_usecase.dart';

part 'achievement_event.dart';
part 'achievement_state.dart';

class AchievementBloc extends Bloc<AchievementEvent, AchievementState> {
  final GetMyAchievementsUseCase _getMyAchievementsUseCase;

  AchievementBloc({required GetMyAchievementsUseCase getMyAchievementsUseCase})
    : _getMyAchievementsUseCase = getMyAchievementsUseCase,
      super(const AchievementState()) {
    on<AchievementFetched>(_onFetched);
  }

  Future<void> _onFetched(
    AchievementFetched event,
    Emitter<AchievementState> emit,
  ) async {
    emit(state.copyWith(status: AchievementStatus.loading));

    final result = await _getMyAchievementsUseCase(NoParams());

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AchievementStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (data) => emit(
        state.copyWith(status: AchievementStatus.success, achievements: data),
      ),
    );
  }
}
