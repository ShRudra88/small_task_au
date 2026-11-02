import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:small_task_au/features/auth/domain/usecases/check_auth_status_usecase.dart';
import 'package:small_task_au/features/auth/domain/usecases/login_usecase.dart';
import 'package:small_task_au/features/auth/domain/usecases/logout_usecase.dart';
import 'package:small_task_au/features/auth/presentation/bloc/auth_event.dart';
import 'package:small_task_au/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;
  final CheckAuthStatusUseCase _checkAuthStatusUseCase;
  final LogoutUseCase _logoutUseCase;

  AuthBloc({
    required LoginUseCase loginUseCase,
    required CheckAuthStatusUseCase checkAuthStatusUseCase,
    required LogoutUseCase logoutUseCase,
  })  : _loginUseCase = loginUseCase,
        _checkAuthStatusUseCase = checkAuthStatusUseCase,
        _logoutUseCase = logoutUseCase,
        super(AuthInitial()) {
    on<CheckAuthStatusRequested>(_onCheckAuthStatusRequested);
    on<LoginSubmitted>(_onLoginSubmitted);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onCheckAuthStatusRequested(
    CheckAuthStatusRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await _checkAuthStatusUseCase();
    result.fold(
      (failure) => emit(Unauthenticated()),
      (user) {
        if (user != null) {
          emit(Authenticated(user));
        } else {
          emit(Unauthenticated());
        }
      },
    );
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await _loginUseCase(
      username: event.username,
      password: event.password,
    );
    result.fold(
      (failure) => emit(AuthFailureState(failure.message)),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    await _logoutUseCase();
    emit(Unauthenticated());
  }
}
