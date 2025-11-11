part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

// Trạng thái ban đầu, chưa biết gì
class AuthInitial extends AuthState {}

// Đang kiểm tra
class AuthLoading extends AuthState {}

// Đã xác thực (đã đăng nhập)
class AuthAuthenticated extends AuthState {}

// Chưa xác thực (chưa đăng nhập)
class AuthUnauthenticated extends AuthState {}
