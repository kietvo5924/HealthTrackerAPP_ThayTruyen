part of 'profile_bloc.dart';

enum ProfileStatus { initial, loading, success, failure, updating }

class ProfileState extends Equatable {
  final ProfileStatus status;
  final UserProfile? userProfile;
  final String errorMessage;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.userProfile,
    this.errorMessage = '',
  });

  // Helper copyWith
  ProfileState copyWith({
    ProfileStatus? status,
    UserProfile? userProfile,
    String? errorMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      userProfile: userProfile ?? this.userProfile,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, userProfile, errorMessage];
}
