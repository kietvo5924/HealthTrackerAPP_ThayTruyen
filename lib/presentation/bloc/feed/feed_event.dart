part of 'feed_bloc.dart';

abstract class FeedEvent extends Equatable {
  const FeedEvent();

  @override
  List<Object> get props => [];
}

// Event để tải bảng tin
class FeedFetched extends FeedEvent {}

class FeedWorkoutLiked extends FeedEvent {
  // Sửa thành int
  final int workoutId;
  const FeedWorkoutLiked(this.workoutId);

  @override
  List<Object> get props => [workoutId];
}
