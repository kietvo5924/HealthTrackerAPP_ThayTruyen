import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:health_tracker_app/domain/usecases/login_usecase.dart';
import 'package:health_tracker_app/presentation/bloc/auth/auth_bloc.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginUseCase _loginUseCase;
  final AuthBloc _authBloc;

  LoginBloc({required LoginUseCase loginUseCase, required AuthBloc authBloc})
    : _loginUseCase = loginUseCase,
      _authBloc = authBloc,
      super(const LoginState()) {
    on<LoginEmailChanged>(_onEmailChanged);
    on<LoginPasswordChanged>(_onPasswordChanged);
    on<LoginSubmitted>(_onSubmitted);
  }

  void _onEmailChanged(LoginEmailChanged event, Emitter<LoginState> emit) {
    emit(state.copyWith(email: event.email));
  }

  void _onPasswordChanged(
    LoginPasswordChanged event,
    Emitter<LoginState> emit,
  ) {
    emit(state.copyWith(password: event.password));
  }

  Future<void> _onSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    final result = await _loginUseCase(
      LoginParams(email: state.email, password: state.password),
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false, errorMessage: failure.message));
      },
      (success) {
        // Thông báo cho AuthBloc toàn app biết là đã đăng nhập
        _authBloc.add(AuthLoggedIn());
        emit(state.copyWith(isLoading: false, isSuccess: true));
      },
    );
  }
}
