part of 'signup_bloc.dart';

// Dùng 1 enum để quản lý trạng thái
enum SignupStatus { initial, loading, success, failure }

class SignupState extends Equatable {
  final String fullName;
  final String phoneNumber;
  final String email;
  final String password;
  final SignupStatus status;
  final String message; // Để lưu thông báo lỗi hoặc thành công

  const SignupState({
    this.fullName = '',
    this.phoneNumber = '',
    this.email = '',
    this.password = '',
    this.status = SignupStatus.initial,
    this.message = '',
  });

  SignupState copyWith({
    String? fullName,
    String? phoneNumber,
    String? email,
    String? password,
    SignupStatus? status,
    String? message,
  }) {
    return SignupState(
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      password: password ?? this.password,
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [
    fullName,
    phoneNumber,
    email,
    password,
    status,
    message,
  ];
}
