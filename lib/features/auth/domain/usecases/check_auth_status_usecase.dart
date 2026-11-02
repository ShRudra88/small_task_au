import 'package:small_task_au/core/utils/result.dart';
import 'package:small_task_au/features/auth/domain/entities/user.dart';
import 'package:small_task_au/features/auth/domain/repositories/auth_repository.dart';

class CheckAuthStatusUseCase {
  final AuthRepository _repository;

  CheckAuthStatusUseCase(this._repository);

  Future<Result<User?>> call() {
    return _repository.checkAuthStatus();
  }
}
