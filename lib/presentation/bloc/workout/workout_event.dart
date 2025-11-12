part of 'workout_bloc.dart';

abstract class WorkoutEvent extends Equatable {
  const WorkoutEvent();

  @override
  List<Object> get props => [];
}

// Event để tải danh sách bài tập
class WorkoutsFetched extends WorkoutEvent {}

// Event để thêm một bài tập mới
class WorkoutAdded extends WorkoutEvent {
  // Dùng luôn LogWorkoutParams từ UseCase cho tiện
  final LogWorkoutParams params;
  const WorkoutAdded(this.params);

  @override
  List<Object> get props => [params];
}
