import 'dart:convert';
import 'package:small_task_au/core/errors/exceptions.dart';
import 'package:small_task_au/core/errors/failures.dart';
import 'package:small_task_au/core/storage/secure_storage_service.dart';
import 'package:small_task_au/core/utils/result.dart';
import 'package:small_task_au/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:small_task_au/features/auth/data/models/user_model.dart';
import 'package:small_task_au/features/auth/domain/entities/user.dart';
import 'package:small_task_au/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final SecureStorageService _secureStorage;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required SecureStorageService secureStorage,
  })  : _remoteDataSource = remoteDataSource,
        _secureStorage = secureStorage;

  @override
  Future<Result<User>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _remoteDataSource.login(
        username: username,
        password: password,
      );

      await _secureStorage.saveToken(response.token);
      await _secureStorage.saveUserData(jsonEncode(response.user.toJson()));

      return Result.success(response.user.toEntity());
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(e.message, e.statusCode));
    } on NetworkException catch (e) {
      return Result.failure(NetworkFailure(e.message));
    } catch (e) {
      return Result.failure(AuthFailure('Login failed: ${e.toString()}'));
    }
  }

  @override
  Future<Result<User?>> checkAuthStatus() async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null || token.isEmpty) {
        return const Result.success(null);
      }

      final userDataJson = await _secureStorage.getUserData();
      if (userDataJson != null && userDataJson.isNotEmpty) {
        final Map<String, dynamic> userMap = jsonDecode(userDataJson);
        final userModel = UserModel.fromJson(userMap);
        return Result.success(userModel.toEntity());
      }

      return const Result.success(null);
    } catch (e) {
      return Result.failure(CacheFailure('Failed to check auth status: ${e.toString()}'));
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      await _secureStorage.deleteToken();
      return const Result.success(null);
    } catch (e) {
      return Result.failure(CacheFailure('Failed to log out: ${e.toString()}'));
    }
  }
}
