import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:stream_transform/stream_transform.dart';
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
    // 1. Cập nhật UI NGAY LẬP TỨC (Optimistic Update)
    // Tạo danh sách mới với user đã được cập nhật trạng thái
    final updatedList = state.searchResults.map((user) {
      if (user.id == event.userId) {
        return user.copyWith(
          isFollowing: true, // Đánh dấu là đã follow
          followersCount: user.followersCount + 1, // Tăng số lượng follow ảo
        );
      }
      return user;
    }).toList();

    // Emit state mới ngay lập tức để giao diện đổi nút
    emit(
      state.copyWith(
        searchResults: updatedList, // Cập nhật danh sách hiển thị
        followStatus: FollowStatus.loading,
        processingUserId: event.userId,
      ),
    );

    // 2. Gọi API thực tế
    final result = await userRepository.followUser(event.userId);

    // 3. Xử lý kết quả từ Server
    result.fold(
      (failure) {
        // Nếu API lỗi -> Hoàn tác lại UI hoặc báo lỗi
        emit(
          state.copyWith(
            followStatus: FollowStatus.failure,
            errorMessage: failure.message,
            processingUserId: null,
          ),
        );

        // Mẹo: Gọi lại search để đồng bộ dữ liệu chính xác từ server nếu cần
        if (state.searchResults.isNotEmpty) {
          // add(SocialSearchQueryChanged(...));
        }
      },
      (success) {
        // Thành công -> Chỉ cần tắt trạng thái loading
        emit(
          state.copyWith(
            followStatus: FollowStatus.success,
            processingUserId: null,
          ),
        );
      },
    );
  }

  Future<void> _onUnfollowUser(
    SocialUnfollowUser event,
    Emitter<SocialState> emit,
  ) async {
    // 1. Cập nhật UI NGAY LẬP TỨC (Optimistic Update)
    final updatedList = state.searchResults.map((user) {
      if (user.id == event.userId) {
        return user.copyWith(
          isFollowing: false, // Đánh dấu là hủy follow
          followersCount: (user.followersCount - 1) < 0
              ? 0
              : user.followersCount - 1,
        );
      }
      return user;
    }).toList();

    // Emit state mới ngay lập tức
    emit(
      state.copyWith(
        searchResults: updatedList,
        followStatus: FollowStatus.loading,
        processingUserId: event.userId,
      ),
    );

    // 2. Gọi API thực tế
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
