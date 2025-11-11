import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:health_tracker_app/domain/usecases/signup_usecase.dart';

part 'signup_event.dart';
part 'signup_state.dart';

class SignupBloc extends Bloc<SignupEvent, SignupState> {
  final SignupUseCase _signupUseCase;

  SignupBloc({required SignupUseCase signupUseCase})
    : _signupUseCase = signupUseCase,
      super(const SignupState()) {
    on<SignupFullNameChanged>(_onFullNameChanged);
    on<SignupPhoneNumberChanged>(_onPhoneNumberChanged);
    on<SignupEmailChanged>(_onEmailChanged);
    on<SignupPasswordChanged>(_onPasswordChanged);
    on<SignupSubmitted>(_onSubmitted);
  }

  void _onFullNameChanged(
    SignupFullNameChanged event,
    Emitter<SignupState> emit,
  ) {
    emit(state.copyWith(fullName: event.fullName));
  }

  void _onPhoneNumberChanged(
    SignupPhoneNumberChanged event,
    Emitter<SignupState> emit,
  ) {
    emit(state.copyWith(phoneNumber: event.phoneNumber));
  }

  void _onEmailChanged(SignupEmailChanged event, Emitter<SignupState> emit) {
    emit(state.copyWith(email: event.email));
  }

  void _onPasswordChanged(
    SignupPasswordChanged event,
    Emitter<SignupState> emit,
  ) {
    emit(state.copyWith(password: event.password));
  }

  Future<void> _onSubmitted(
    SignupSubmitted event,
    Emitter<SignupState> emit,
  ) async {
    emit(state.copyWith(status: SignupStatus.loading, message: ''));

    final result = await _signupUseCase(
      SignupParams(
        fullName: state.fullName,
        phoneNumber: state.phoneNumber,
        email: state.email,
        password: state.password,
      ),
    );

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: SignupStatus.failure,
            message: failure.message,
          ),
        );
      },
      (successMessage) {
        emit(
          state.copyWith(status: SignupStatus.success, message: successMessage),
        );
      },
    );
  }
}
