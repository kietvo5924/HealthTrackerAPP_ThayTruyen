part of 'social_bloc.dart';

enum SocialStatus { initial, loading, success, failure }

// Enum trạng thái riêng cho hành động Follow để không ảnh hưởng đến list search
enum FollowStatus { initial, loading, success, failure }

class SocialState extends Equatable {
  final SocialStatus status;
  final List<UserProfile> searchResults;
  final String errorMessage;

  // Trạng thái cho hành động Follow/Unfollow
  final FollowStatus followStatus;
  final int?
  processingUserId; // ID của user đang được xử lý (để hiện spinner trên nút đó)

  const SocialState({
    this.status = SocialStatus.initial,
    this.searchResults = const [],
    this.errorMessage = '',
    this.followStatus = FollowStatus.initial,
    this.processingUserId,
  });

  SocialState copyWith({
    SocialStatus? status,
    List<UserProfile>? searchResults,
    String? errorMessage,
    FollowStatus? followStatus,
    int? processingUserId,
  }) {
    return SocialState(
      status: status ?? this.status,
      searchResults: searchResults ?? this.searchResults,
      errorMessage: errorMessage ?? this.errorMessage,
      followStatus: followStatus ?? this.followStatus,
      processingUserId: processingUserId ?? this.processingUserId,
    );
  }

  @override
  List<Object?> get props => [
    status,
    searchResults,
    errorMessage,
    followStatus,
    processingUserId,
  ];
}
