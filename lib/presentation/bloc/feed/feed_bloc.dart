import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:health_tracker_app/core/usecase/usecase.dart';
import 'package:health_tracker_app/domain/entities/workout.dart';
import 'package:health_tracker_app/domain/usecases/get_community_feed_usecase.dart';

part 'feed_event.dart';
part 'feed_state.dart';

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  final GetCommunityFeedUseCase _getCommunityFeedUseCase;

  FeedBloc({required GetCommunityFeedUseCase getCommunityFeedUseCase})
    : _getCommunityFeedUseCase = getCommunityFeedUseCase,
      super(const FeedState()) {
    on<FeedFetched>(_onFeedFetched);
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
}
