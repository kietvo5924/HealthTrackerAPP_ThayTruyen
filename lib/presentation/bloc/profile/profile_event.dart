part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

// Event để tải profile
class ProfileFetched extends ProfileEvent {}

// Event khi các trường thay đổi
class ProfileFullNameChanged extends ProfileEvent {
  final String fullName;
  const ProfileFullNameChanged(this.fullName);
}

class ProfilePhoneNumberChanged extends ProfileEvent {
  final String phoneNumber;
  const ProfilePhoneNumberChanged(this.phoneNumber);
}

class ProfileDateOfBirthChanged extends ProfileEvent {
  final DateTime? dateOfBirth;
  const ProfileDateOfBirthChanged(this.dateOfBirth);
}

class ProfileAddressChanged extends ProfileEvent {
  final String address;
  const ProfileAddressChanged(this.address);
}

// ... (thêm cho medicalHistory, allergies nếu cần) ...

// Event khi nhấn nút lưu
class ProfileSubmitted extends ProfileEvent {}
