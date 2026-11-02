import 'package:flutter_test/flutter_test.dart';
import 'package:small_task_au/core/errors/failures.dart';
import 'package:small_task_au/core/utils/result.dart';
import 'package:small_task_au/features/auth/domain/entities/user.dart';
import 'package:small_task_au/features/auth/domain/repositories/auth_repository.dart';
import 'package:small_task_au/features/auth/domain/usecases/check_auth_status_usecase.dart';
import 'package:small_task_au/features/auth/domain/usecases/login_usecase.dart';
import 'package:small_task_au/features/auth/domain/usecases/logout_usecase.dart';
import 'package:small_task_au/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:small_task_au/features/auth/presentation/bloc/auth_event.dart';
import 'package:small_task_au/features/auth/presentation/bloc/auth_state.dart';

class MockAuthRepository implements AuthRepository {
  User? mockUser;
  bool shouldFailLogin = false;

  @override
  Future<Result<User>> login({required String username, required String password}) async {
    if (shouldFailLogin) {
      return const Result.failure(AuthFailure('Invalid credentials'));
    }
    mockUser = User(
      id: 1,
      username: username,
      email: '$username@dummy.com',
      firstName: 'Emily',
      lastName: 'Smith',
    );
    return Result.success(mockUser!);
  }

  @override
  Future<Result<User?>> checkAuthStatus() async {
    return Result.success(mockUser);
  }

  @override
  Future<Result<void>> logout() async {
    mockUser = null;
    return const Result.success(null);
  }
}

void main() {
  late MockAuthRepository repository;
  late LoginUseCase loginUseCase;
  late CheckAuthStatusUseCase checkAuthStatusUseCase;
  late LogoutUseCase logoutUseCase;
  late AuthBloc authBloc;

  setUp(() {
    repository = MockAuthRepository();
    loginUseCase = LoginUseCase(repository);
    checkAuthStatusUseCase = CheckAuthStatusUseCase(repository);
    logoutUseCase = LogoutUseCase(repository);
    authBloc = AuthBloc(
      loginUseCase: loginUseCase,
      checkAuthStatusUseCase: checkAuthStatusUseCase,
      logoutUseCase: logoutUseCase,
    );
  });

  tearDown(() {
    authBloc.close();
  });

  test('initial state is AuthInitial', () {
    expect(authBloc.state, isA<AuthInitial>());
  });

  test('emits [AuthLoading, Unauthenticated] when checkAuthStatus is called with no saved user', () async {
    final expectedStates = [
      isA<AuthLoading>(),
      isA<Unauthenticated>(),
    ];

    expectLater(authBloc.stream, emitsInOrder(expectedStates));
    authBloc.add(CheckAuthStatusRequested());
  });

  test('emits [AuthLoading, Authenticated] on successful login', () async {
    final expectedStates = [
      isA<AuthLoading>(),
      isA<Authenticated>(),
    ];

    expectLater(authBloc.stream, emitsInOrder(expectedStates));
    authBloc.add(const LoginSubmitted(username: 'emilys', password: 'emilyspass'));
  });

  test('emits [AuthLoading, AuthFailureState] on failed login', () async {
    repository.shouldFailLogin = true;
    final expectedStates = [
      isA<AuthLoading>(),
      isA<AuthFailureState>(),
    ];

    expectLater(authBloc.stream, emitsInOrder(expectedStates));
    authBloc.add(const LoginSubmitted(username: 'wrong', password: 'wrong'));
  });
}
