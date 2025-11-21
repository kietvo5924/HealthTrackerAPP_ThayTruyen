part of 'social_bloc.dart';

abstract class SocialEvent extends Equatable {
  const SocialEvent();

  @override
  List<Object> get props => [];
}

// Sự kiện khi người dùng thay đổi từ khóa tìm kiếm
class SocialSearchQueryChanged extends SocialEvent {
  final String query;
  const SocialSearchQueryChanged(this.query);

  @override
  List<Object> get props => [query];
}

// Sự kiện khi người dùng nhấn nút Follow
class SocialFollowUser extends SocialEvent {
  final int userId;
  const SocialFollowUser(this.userId);

  @override
  List<Object> get props => [userId];
}

// Sự kiện khi người dùng nhấn nút Unfollow (nếu cần sau này)
class SocialUnfollowUser extends SocialEvent {
  final int userId;
  const SocialUnfollowUser(this.userId);

  @override
  List<Object> get props => [userId];
}
