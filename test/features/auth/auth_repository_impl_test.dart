import 'package:flutter_test/flutter_test.dart';
import 'package:small_task_au/core/errors/exceptions.dart';
import 'package:small_task_au/core/errors/failures.dart';
import 'package:small_task_au/core/storage/secure_storage_service.dart';
import 'package:small_task_au/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:small_task_au/features/auth/data/models/auth_response_model.dart';
import 'package:small_task_au/features/auth/data/models/user_model.dart';
import 'package:small_task_au/features/auth/data/repositories/auth_repository_impl.dart';

class MockAuthRemoteDataSource implements AuthRemoteDataSource {
  bool shouldThrowServerException = false;
  bool shouldThrowNetworkException = false;

  @override
  Future<AuthResponseModel> login({required String username, required String password}) async {
    if (shouldThrowServerException) {
      throw const ServerException('Invalid credentials', 400);
    }
    if (shouldThrowNetworkException) {
      throw const NetworkException('No internet connection');
    }
    return const AuthResponseModel(
      token: 'mock_access_token_123',
      user: UserModel(
        id: 1,
        username: 'emilys',
        email: 'emily@dummy.com',
        firstName: 'Emily',
        lastName: 'Smith',
      ),
    );
  }
}

class FakeSecureStorageService implements SecureStorageService {
  String? _token;
  String? _userData;

  @override
  Future<void> saveToken(String token) async => _token = token;

  @override
  Future<String?> getToken() async => _token;

  @override
  Future<void> deleteToken() async {
    _token = null;
    _userData = null;
  }

  @override
  Future<void> saveUserData(String userDataJson) async => _userData = userDataJson;

  @override
  Future<String?> getUserData() async => _userData;
}

void main() {
  late MockAuthRemoteDataSource remoteDataSource;
  late FakeSecureStorageService secureStorage;
  late AuthRepositoryImpl repository;

  setUp(() {
    remoteDataSource = MockAuthRemoteDataSource();
    secureStorage = FakeSecureStorageService();
    repository = AuthRepositoryImpl(
      remoteDataSource: remoteDataSource,
      secureStorage: secureStorage,
    );
  });

  group('login', () {
    test('returns User and saves token on successful login', () async {
      final result = await repository.login(username: 'emilys', password: 'emilyspass');

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull?.username, equals('emilys'));

      final token = await secureStorage.getToken();
      expect(token, equals('mock_access_token_123'));
    });

    test('returns ServerFailure when remote data source throws ServerException', () async {
      remoteDataSource.shouldThrowServerException = true;
      final result = await repository.login(username: 'emilys', password: 'wrong');

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<ServerFailure>());
      expect(result.failureOrNull?.message, equals('Invalid credentials'));
    });

    test('returns NetworkFailure when remote data source throws NetworkException', () async {
      remoteDataSource.shouldThrowNetworkException = true;
      final result = await repository.login(username: 'emilys', password: 'emilyspass');

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<NetworkFailure>());
    });
  });

  group('checkAuthStatus & logout', () {
    test('returns null user when no token saved', () async {
      final result = await repository.checkAuthStatus();
      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull, isNull);
    });

    test('returns user when token and user data exist', () async {
      await repository.login(username: 'emilys', password: 'emilyspass');
      final result = await repository.checkAuthStatus();

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull?.username, equals('emilys'));
    });

    test('deletes token on logout', () async {
      await repository.login(username: 'emilys', password: 'emilyspass');
      await repository.logout();

      final result = await repository.checkAuthStatus();
      expect(result.dataOrNull, isNull);
    });
  });
}
