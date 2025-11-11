part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

// Event được gọi khi app khởi động để kiểm tra
class AuthCheckRequested extends AuthEvent {}

// Event được gọi khi đăng nhập thành công
class AuthLoggedIn extends AuthEvent {}

// Event được gọi khi đăng xuất
class AuthLoggedOut extends AuthEvent {}
