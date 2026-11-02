import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:small_task_au/core/errors/exceptions.dart';

abstract class SecureStorageService {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> deleteToken();
  Future<void> saveUserData(String userDataJson);
  Future<String?> getUserData();
}

class SecureStorageServiceImpl implements SecureStorageService {
  final FlutterSecureStorage _storage;

  static const String _keyToken = 'auth_token';
  static const String _keyUserData = 'user_data';

  SecureStorageServiceImpl({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: _keyToken, value: token);
    } catch (e) {
      throw CacheException('Failed to save secure token: ${e.toString()}');
    }
  }

  @override
  Future<String?> getToken() async {
    try {
      return await _storage.read(key: _keyToken);
    } catch (e) {
      throw CacheException('Failed to read secure token: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteToken() async {
    try {
      await _storage.delete(key: _keyToken);
      await _storage.delete(key: _keyUserData);
    } catch (e) {
      throw CacheException('Failed to delete secure token: ${e.toString()}');
    }
  }

  @override
  Future<void> saveUserData(String userDataJson) async {
    try {
      await _storage.write(key: _keyUserData, value: userDataJson);
    } catch (e) {
      throw CacheException('Failed to save user data: ${e.toString()}');
    }
  }

  @override
  Future<String?> getUserData() async {
    try {
      return await _storage.read(key: _keyUserData);
    } catch (e) {
      throw CacheException('Failed to read user data: ${e.toString()}');
    }
  }
}
