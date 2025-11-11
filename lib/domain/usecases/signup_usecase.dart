import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:health_tracker_app/core/error/failures.dart';
import 'package:health_tracker_app/core/usecase/usecase.dart';
import 'package:health_tracker_app/domain/repositories/auth_repository.dart';

class SignupUseCase implements UseCase<String, SignupParams> {
  final AuthRepository authRepository;

  SignupUseCase(this.authRepository);

  @override
  Future<Either<Failure, String>> call(SignupParams params) async {
    return await authRepository.signup(
      fullName: params.fullName,
      phoneNumber: params.phoneNumber,
      email: params.email,
      password: params.password,
    );
  }
}

class SignupParams extends Equatable {
  final String fullName;
  final String phoneNumber;
  final String email;
  final String password;

  const SignupParams({
    required this.fullName,
    required this.phoneNumber,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [fullName, phoneNumber, email, password];
}
