import 'package:small_task_au/core/network/api_client.dart';
import 'package:small_task_au/features/auth/data/models/auth_response_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login({
    required String username,
    required String password,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSourceImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<AuthResponseModel> login({
    required String username,
    required String password,
  }) async {
    final response = await _apiClient.post(
      '/auth/login',
      body: {
        'username': username,
        'password': password,
        'expiresInMins': 60,
      },
    );
    return AuthResponseModel.fromJson(response as Map<String, dynamic>);
  }
}
