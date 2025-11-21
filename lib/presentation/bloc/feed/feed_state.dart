part of 'feed_bloc.dart';

enum FeedStatus { initial, loading, success, failure }

class FeedState extends Equatable {
  final FeedStatus status;
  final List<Workout> workouts;
  final bool hasReachedMax; // Đánh dấu đã hết dữ liệu để tải chưa
  final String errorMessage;
  final int page; // Trang hiện tại

  const FeedState({
    this.status = FeedStatus.initial,
    this.workouts = const [],
    this.hasReachedMax = false,
    this.errorMessage = '',
    this.page = 0,
  });

  FeedState copyWith({
    FeedStatus? status,
    List<Workout>? workouts,
    bool? hasReachedMax,
    String? errorMessage,
    int? page,
  }) {
    return FeedState(
      status: status ?? this.status,
      workouts: workouts ?? this.workouts,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      errorMessage: errorMessage ?? this.errorMessage,
      page: page ?? this.page,
    );
  }

  @override
  List<Object> get props => [
    status,
    workouts,
    hasReachedMax,
    errorMessage,
    page,
  ];
}
