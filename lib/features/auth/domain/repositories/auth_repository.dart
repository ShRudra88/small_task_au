import 'package:small_task_au/core/utils/result.dart';
import 'package:small_task_au/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<Result<User>> login({
    required String username,
    required String password,
  });

  Future<Result<User?>> checkAuthStatus();

  Future<Result<void>> logout();
}
