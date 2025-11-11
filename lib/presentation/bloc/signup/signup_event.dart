part of 'signup_bloc.dart';

abstract class SignupEvent extends Equatable {
  const SignupEvent();

  @override
  List<Object> get props => [];
}

class SignupFullNameChanged extends SignupEvent {
  final String fullName;
  const SignupFullNameChanged(this.fullName);
}

class SignupPhoneNumberChanged extends SignupEvent {
  final String phoneNumber;
  const SignupPhoneNumberChanged(this.phoneNumber);
}

class SignupEmailChanged extends SignupEvent {
  final String email;
  const SignupEmailChanged(this.email);
}

class SignupPasswordChanged extends SignupEvent {
  final String password;
  const SignupPasswordChanged(this.password);
}

class SignupSubmitted extends SignupEvent {}
