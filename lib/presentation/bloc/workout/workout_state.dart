part of 'workout_bloc.dart';

enum WorkoutStatus { initial, loading, success, failure }

class WorkoutState extends Equatable {
  final WorkoutStatus status;
  final List<Workout> workouts;
  final String errorMessage;
  final bool isSubmitting;
  final String? submissionError;

  const WorkoutState({
    this.status = WorkoutStatus.initial,
    this.workouts = const <Workout>[],
    this.errorMessage = '',
    this.isSubmitting = false,
    this.submissionError,
  });

  WorkoutState copyWith({
    WorkoutStatus? status,
    List<Workout>? workouts,
    String? errorMessage,
    bool? isSubmitting,
    String? submissionError,
    bool clearSubmissionError = false,
  }) {
    return WorkoutState(
      status: status ?? this.status,
      workouts: workouts ?? this.workouts,
      errorMessage: errorMessage ?? this.errorMessage,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submissionError: clearSubmissionError
          ? null
          : submissionError ?? this.submissionError,
    );
  }

  @override
  List<Object?> get props => [
    status,
    workouts,
    errorMessage,
    isSubmitting,
    submissionError,
  ];
}
