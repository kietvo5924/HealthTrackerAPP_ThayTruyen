import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:health_tracker_app/domain/entities/workout.dart';
import 'package:health_tracker_app/domain/usecases/get_community_feed_usecase.dart';
import 'package:health_tracker_app/domain/usecases/toggle_workout_like_usecase.dart';
import 'package:health_tracker_app/core/services/realtime_workout_service.dart';
import 'package:health_tracker_app/domain/entities/workout_realtime_update.dart';

part 'feed_event.dart';
part 'feed_state.dart';

const _postLimit = 10; // Số lượng bài tải mỗi lần

// Hàm hỗ trợ để tránh gọi API liên tục khi cuộn nhanh (Throttle)
EventTransformer<E> _throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  final GetCommunityFeedUseCase _getCommunityFeedUseCase;
  final ToggleWorkoutLikeUseCase _toggleWorkoutLikeUseCase;
  final RealtimeWorkoutService _realtimeWorkoutService;
  StreamSubscription<WorkoutRealtimeUpdate>? _realtimeSubscription;

  FeedBloc({
    required GetCommunityFeedUseCase getCommunityFeedUseCase,
    required ToggleWorkoutLikeUseCase toggleWorkoutLikeUseCase,
    required RealtimeWorkoutService realtimeWorkoutService,
  }) : _getCommunityFeedUseCase = getCommunityFeedUseCase,
       _toggleWorkoutLikeUseCase = toggleWorkoutLikeUseCase,
       _realtimeWorkoutService = realtimeWorkoutService,
       super(const FeedState()) {
    // Xử lý tải lần đầu
    on<FeedFetched>(_onFeedFetched);

    // Xử lý cuộn trang (có throttle 100ms)
    on<FeedScrolled>(
      _onFeedScrolled,
      transformer: _throttleDroppable(const Duration(milliseconds: 100)),
    );

    // Xử lý Like
    on<FeedWorkoutLiked>(_onWorkoutLiked);

    // Lắng nghe realtime updates
    _realtimeSubscription = _realtimeWorkoutService.updates.listen(
      (update) => add(FeedRealtimeUpdateReceived(update)),
    );
    on<FeedRealtimeUpdateReceived>(_onRealtimeUpdate);
  }

  // 1. Logic tải trang đầu tiên
  Future<void> _onFeedFetched(
    FeedFetched event,
    Emitter<FeedState> emit,
  ) async {
    if (state.workouts.isEmpty) {
      emit(state.copyWith(status: FeedStatus.loading));
    }

    // Reset về trang 0
    final result = await _getCommunityFeedUseCase(
      GetCommunityFeedParams(page: 0, size: _postLimit),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: FeedStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (workouts) => emit(
        state.copyWith(
          status: FeedStatus.success,
          workouts: workouts,
          hasReachedMax: workouts.length < _postLimit,
          page: 1, // Tăng lên trang 1 để lần sau tải tiếp
        ),
      ),
    );
  }

  // 2. Logic tải trang tiếp theo (Pagination)
  Future<void> _onFeedScrolled(
    FeedScrolled event,
    Emitter<FeedState> emit,
  ) async {
    // Nếu đã tải hết rồi thì không làm gì nữa
    if (state.hasReachedMax) return;

    final result = await _getCommunityFeedUseCase(
      GetCommunityFeedParams(page: state.page, size: _postLimit),
    );

    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (newWorkouts) {
        if (newWorkouts.isEmpty) {
          emit(state.copyWith(hasReachedMax: true));
        } else {
          emit(
            state.copyWith(
              status: FeedStatus.success,
              // Nối danh sách mới vào đuôi danh sách cũ
              workouts: List.of(state.workouts)..addAll(newWorkouts),
              hasReachedMax: newWorkouts.length < _postLimit,
              page: state.page + 1,
            ),
          );
        }
      },
    );
  }

  // 3. Logic Like (Cập nhật UI ngay lập tức)
  Future<void> _onWorkoutLiked(
    FeedWorkoutLiked event,
    Emitter<FeedState> emit,
  ) async {
    // A. Cập nhật UI giả lập (Optimistic Update)
    final optimisticList = state.workouts.map((workout) {
      if (workout.id == event.workoutId) {
        // Đảo ngược trạng thái Like và cập nhật số lượng
        final isLiked = !workout.likedByCurrentUser;
        return workout.copyWith(
          likedByCurrentUser: isLiked,
          likeCount: isLiked ? workout.likeCount + 1 : workout.likeCount - 1,
        );
      }
      return workout;
    }).toList();

    // Emit state mới ngay lập tức để UI đổi màu tim
    emit(state.copyWith(workouts: optimisticList));

    // B. Gọi API thực tế
    final result = await _toggleWorkoutLikeUseCase(event.workoutId);

    // C. Xử lý kết quả từ Server
    result.fold(
      (failure) {
        // Nếu lỗi API -> Tải lại dữ liệu gốc để hoàn tác (Revert)
        add(FeedFetched());
      },
      (updatedWorkout) {
        // Nếu thành công -> Cập nhật lại đúng dữ liệu từ server trả về cho chắc chắn
        final confirmedList = state.workouts.map((w) {
          if (w.id == updatedWorkout.id) {
            return updatedWorkout;
          }
          return w;
        }).toList();
        emit(state.copyWith(workouts: confirmedList));
      },
    );
  }

  void _onRealtimeUpdate(
    FeedRealtimeUpdateReceived event,
    Emitter<FeedState> emit,
  ) {
    if (state.workouts.isEmpty) {
      return;
    }

    final updatedList = state.workouts.map((workout) {
      if (workout.id == event.update.workoutId) {
        return workout.copyWith(
          likeCount: event.update.likeCount,
          commentCount: event.update.commentCount,
        );
      }
      return workout;
    }).toList();

    emit(state.copyWith(workouts: updatedList));
  }

  @override
  Future<void> close() async {
    await _realtimeSubscription?.cancel();
    _realtimeWorkoutService.disconnect();
    await super.close();
  }
}
