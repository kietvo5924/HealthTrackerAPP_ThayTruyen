part of 'feed_bloc.dart';

abstract class FeedEvent extends Equatable {
  const FeedEvent();

  @override
  List<Object> get props => [];
}

// Sự kiện 1: Tải bảng tin lần đầu (hoặc khi refresh)
class FeedFetched extends FeedEvent {}

// Sự kiện 2: Cuộn xuống đáy để tải thêm (Phân trang)
class FeedScrolled extends FeedEvent {}

// Sự kiện 3: Bấm Like một bài tập
class FeedWorkoutLiked extends FeedEvent {
  final int workoutId;
  const FeedWorkoutLiked(this.workoutId);

  @override
  List<Object> get props => [workoutId];
}

// Sự kiện 4: Nhận cập nhật realtime từ WebSocket
class FeedRealtimeUpdateReceived extends FeedEvent {
  final WorkoutRealtimeUpdate update;

  const FeedRealtimeUpdateReceived(this.update);

  @override
  List<Object> get props => [update];
}
