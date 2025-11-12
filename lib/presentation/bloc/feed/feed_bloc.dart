import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:health_tracker_app/core/usecase/usecase.dart';
import 'package:health_tracker_app/domain/entities/workout.dart';
import 'package:health_tracker_app/domain/usecases/get_community_feed_usecase.dart';
import 'package:health_tracker_app/domain/usecases/toggle_workout_like_usecase.dart';

part 'feed_event.dart';
part 'feed_state.dart';

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  final GetCommunityFeedUseCase _getCommunityFeedUseCase;
  final ToggleWorkoutLikeUseCase _toggleWorkoutLikeUseCase;

  FeedBloc({
    required GetCommunityFeedUseCase getCommunityFeedUseCase,
    required ToggleWorkoutLikeUseCase toggleWorkoutLikeUseCase,
  }) : _getCommunityFeedUseCase = getCommunityFeedUseCase,
       _toggleWorkoutLikeUseCase = toggleWorkoutLikeUseCase,
       super(const FeedState()) {
    on<FeedFetched>(_onFeedFetched);
    on<FeedWorkoutLiked>(_onWorkoutLiked);
  }

  Future<void> _onFeedFetched(
    FeedFetched event,
    Emitter<FeedState> emit,
  ) async {
    emit(state.copyWith(status: FeedStatus.loading));

    final result = await _getCommunityFeedUseCase(NoParams());

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: FeedStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (workouts) {
        emit(state.copyWith(status: FeedStatus.success, workouts: workouts));
      },
    );
  }

  Future<void> _onWorkoutLiked(
    FeedWorkoutLiked event,
    Emitter<FeedState> emit,
  ) async {
    // 1. Cập nhật UI ngay lập tức (Optimistic Update)
    final optimisticList = state.workouts.map((workout) {
      if (workout.id == event.workoutId) {
        // Đảm bảo bạn đang dùng copyWith
        return workout.copyWith(
          likedByCurrentUser: !workout.likedByCurrentUser,
          likeCount: workout.likedByCurrentUser
              ? workout.likeCount - 1
              : workout.likeCount + 1,
        );
      }
      return workout;
    }).toList();

    emit(state.copyWith(workouts: optimisticList));

    // 2. Gọi API
    final result = await _toggleWorkoutLikeUseCase(event.workoutId);

    // 3. Xử lý kết quả
    result.fold(
      (failure) {
        // Nếu API lỗi, tải lại toàn bộ list cho chắc
        add(FeedFetched());
      },
      (updatedWorkout) {
        // Nếu API thành công, cập nhật lại list với dữ liệu chính xác
        final confirmedList = state.workouts.map((workout) {
          if (workout.id == updatedWorkout.id) {
            return updatedWorkout;
          }
          return workout;
        }).toList();
        emit(state.copyWith(workouts: confirmedList));
      },
    );
  }
}
