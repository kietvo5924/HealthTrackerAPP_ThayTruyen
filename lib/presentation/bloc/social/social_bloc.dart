import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:stream_transform/stream_transform.dart'; // Helper cho debounce
import 'package:health_tracker_app/domain/entities/user_profile.dart';
import 'package:health_tracker_app/domain/repositories/user_repository.dart';

part 'social_event.dart';
part 'social_state.dart';

// Helper function để debounce (trì hoãn) sự kiện tìm kiếm
EventTransformer<E> _debounce<E>(Duration duration) {
  return (events, mapper) => events.debounce(duration).switchMap(mapper);
}

class SocialBloc extends Bloc<SocialEvent, SocialState> {
  final UserRepository userRepository;

  SocialBloc({required this.userRepository}) : super(const SocialState()) {
    // Đăng ký sự kiện tìm kiếm với debounce 500ms
    on<SocialSearchQueryChanged>(
      _onSearchChanged,
      transformer: _debounce(const Duration(milliseconds: 500)),
    );

    // Đăng ký sự kiện Follow
    on<SocialFollowUser>(_onFollowUser);

    // Đăng ký sự kiện Unfollow
    on<SocialUnfollowUser>(_onUnfollowUser);
  }

  Future<void> _onSearchChanged(
    SocialSearchQueryChanged event,
    Emitter<SocialState> emit,
  ) async {
    if (event.query.isEmpty) {
      emit(state.copyWith(searchResults: [], status: SocialStatus.initial));
      return;
    }

    emit(state.copyWith(status: SocialStatus.loading));

    // Gọi Repository để tìm kiếm
    // Lưu ý: Bạn cần đảm bảo UserRepository đã có hàm searchUsers như hướng dẫn trước
    final result = await userRepository.searchUsers(event.query);

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: SocialStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (users) {
        emit(
          state.copyWith(status: SocialStatus.success, searchResults: users),
        );
      },
    );
  }

  Future<void> _onFollowUser(
    SocialFollowUser event,
    Emitter<SocialState> emit,
  ) async {
    // Đặt trạng thái loading cho user cụ thể
    emit(
      state.copyWith(
        followStatus: FollowStatus.loading,
        processingUserId: event.userId,
      ),
    );

    final result = await userRepository.followUser(event.userId);

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            followStatus: FollowStatus.failure,
            errorMessage: failure.message,
            processingUserId: null,
          ),
        );
      },
      (success) {
        // Nếu follow thành công, cập nhật lại danh sách searchResults
        // (Giả sử UI cần cập nhật trạng thái nút thành "Đang theo dõi")
        // Ở đây ta có thể load lại list search hoặc update thủ công

        // Cách đơn giản: giữ nguyên list, chỉ báo thành công để UI xử lý
        emit(
          state.copyWith(
            followStatus: FollowStatus.success,
            processingUserId: null,
          ),
        );

        // (Nâng cao) Nếu muốn cập nhật UI ngay lập tức mà không cần load lại:
        // Bạn có thể clone list searchResults và update trạng thái 'isFollowing' của user đó
      },
    );
  }

  Future<void> _onUnfollowUser(
    SocialUnfollowUser event,
    Emitter<SocialState> emit,
  ) async {
    emit(
      state.copyWith(
        followStatus: FollowStatus.loading,
        processingUserId: event.userId,
      ),
    );

    final result = await userRepository.unfollowUser(event.userId);

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            followStatus: FollowStatus.failure,
            errorMessage: failure.message,
            processingUserId: null,
          ),
        );
      },
      (success) {
        emit(
          state.copyWith(
            followStatus: FollowStatus.success,
            processingUserId: null,
          ),
        );
      },
    );
  }
}
