import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:health_tracker_app/core/usecase/usecase.dart';
import 'package:health_tracker_app/domain/usecases/get_auth_token_usecase.dart';
import 'package:health_tracker_app/domain/usecases/logout_usecase.dart';
import 'package:health_tracker_app/domain/usecases/save_fcm_token_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final GetAuthTokenUseCase _getAuthTokenUseCase;
  final LogoutUseCase _logoutUseCase;
  final SaveFcmTokenUseCase _saveFcmTokenUseCase;

  AuthBloc({
    required GetAuthTokenUseCase getAuthTokenUseCase,
    required LogoutUseCase logoutUseCase,
    required SaveFcmTokenUseCase saveFcmTokenUseCase,
  }) : _getAuthTokenUseCase = getAuthTokenUseCase,
       _logoutUseCase = logoutUseCase,
       _saveFcmTokenUseCase = saveFcmTokenUseCase,
       super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoggedIn>(_onAuthLoggedIn);
    on<AuthLoggedOut>(_onAuthLoggedOut);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await _getAuthTokenUseCase(NoParams());
    result.fold((failure) => emit(AuthUnauthenticated()), (token) {
      if (token != null && token.isNotEmpty) {
        emit(AuthAuthenticated());
        _saveFcmTokenUseCase(NoParams());
      } else {
        emit(AuthUnauthenticated());
      }
    });
  }

  void _onAuthLoggedIn(AuthLoggedIn event, Emitter<AuthState> emit) {
    emit(AuthAuthenticated());
    _saveFcmTokenUseCase(NoParams());
  }

  Future<void> _onAuthLoggedOut(
    AuthLoggedOut event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading()); // Hiển thị loading khi đăng xuất
    await _logoutUseCase(NoParams()); // Xóa token
    emit(AuthUnauthenticated()); // Chuyển về trạng thái chưa đăng nhập
  }
}
