import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:health_tracker_app/core/usecase/usecase.dart';
import 'package:health_tracker_app/domain/entities/workout.dart';
import 'package:health_tracker_app/domain/usecases/get_my_workouts_usecase.dart';
import 'package:health_tracker_app/domain/usecases/log_workout_usecase.dart';

part 'workout_event.dart';
part 'workout_state.dart';

class WorkoutBloc extends Bloc<WorkoutEvent, WorkoutState> {
  final GetMyWorkoutsUseCase _getMyWorkoutsUseCase;
  final LogWorkoutUseCase _logWorkoutUseCase;

  WorkoutBloc({
    required GetMyWorkoutsUseCase getMyWorkoutsUseCase,
    required LogWorkoutUseCase logWorkoutUseCase,
  }) : _getMyWorkoutsUseCase = getMyWorkoutsUseCase,
       _logWorkoutUseCase = logWorkoutUseCase,
       super(const WorkoutState()) {
    on<WorkoutsFetched>(_onWorkoutsFetched);
    on<WorkoutAdded>(_onWorkoutAdded);
  }

  Future<void> _onWorkoutsFetched(
    WorkoutsFetched event,
    Emitter<WorkoutState> emit,
  ) async {
    emit(state.copyWith(status: WorkoutStatus.loading));

    final result = await _getMyWorkoutsUseCase(NoParams());

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: WorkoutStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (workouts) {
        emit(state.copyWith(status: WorkoutStatus.success, workouts: workouts));
      },
    );
  }

  Future<void> _onWorkoutAdded(
    WorkoutAdded event,
    Emitter<WorkoutState> emit,
  ) async {
    // Bật loading và xóa lỗi cũ
    emit(state.copyWith(isSubmitting: true, clearSubmissionError: true));

    final result = await _logWorkoutUseCase(event.params);

    result.fold(
      (failure) {
        // Gửi lỗi
        emit(
          state.copyWith(isSubmitting: false, submissionError: failure.message),
        );
      },
      (newWorkout) {
        // Thành công!
        // Thêm bài tập mới vào đầu danh sách
        final updatedList = [newWorkout, ...state.workouts];

        emit(
          state.copyWith(
            isSubmitting: false,
            status: WorkoutStatus.success, // Đảm bảo status là success
            workouts: updatedList,
          ),
        );
      },
    );
  }
}
