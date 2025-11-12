part of 'feed_bloc.dart';

enum FeedStatus { initial, loading, success, failure }

class FeedState extends Equatable {
  final FeedStatus status;
  final List<Workout> workouts;
  final String errorMessage;

  const FeedState({
    this.status = FeedStatus.initial,
    this.workouts = const <Workout>[],
    this.errorMessage = '',
  });

  FeedState copyWith({
    FeedStatus? status,
    List<Workout>? workouts,
    String? errorMessage,
  }) {
    return FeedState(
      status: status ?? this.status,
      workouts: workouts ?? this.workouts,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object> get props => [status, workouts, errorMessage];
}
