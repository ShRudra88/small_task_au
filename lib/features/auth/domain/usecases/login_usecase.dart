import 'package:small_task_au/core/utils/result.dart';
import 'package:small_task_au/features/auth/domain/entities/user.dart';
import 'package:small_task_au/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<Result<User>> call({
    required String username,
    required String password,
  }) {
    return _repository.login(
      username: username,
      password: password,
    );
  }
}
