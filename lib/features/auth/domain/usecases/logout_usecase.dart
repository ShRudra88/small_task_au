import 'package:small_task_au/core/utils/result.dart';
import 'package:small_task_au/features/auth/domain/repositories/auth_repository.dart';

class LogoutUseCase {
  final AuthRepository _repository;

  LogoutUseCase(this._repository);

  Future<Result<void>> call() {
    return _repository.logout();
  }
}
