import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:small_task_au/core/errors/exceptions.dart';
import 'package:small_task_au/core/storage/secure_storage_service.dart';

class ApiClient {
  static const String baseUrl = 'https://dummyjson.com';
  final http.Client _client;
  final SecureStorageService _secureStorage;

  ApiClient({
    http.Client? client,
    required SecureStorageService secureStorage,
  })  : _client = client ?? http.Client(),
        _secureStorage = secureStorage;

  Future<Map<String, String>> _headers({bool requiresAuth = false}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requiresAuth) {
      final token = await _secureStorage.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  Future<dynamic> get(String endpoint, {bool requiresAuth = false, Map<String, String>? queryParameters}) async {
    try {
      Uri uri = Uri.parse('$baseUrl$endpoint');
      if (queryParameters != null && queryParameters.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParameters);
      }

      final headers = await _headers(requiresAuth: requiresAuth);
      final response = await _client.get(uri, headers: headers);
      return _processResponse(response);
    } on SocketException {
      throw const NetworkException('No Internet connection');
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Unexpected error occurred: ${e.toString()}');
    }
  }

  Future<dynamic> post(String endpoint, {required Map<String, dynamic> body, bool requiresAuth = false}) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final headers = await _headers(requiresAuth: requiresAuth);
      final response = await _client.post(
        uri,
        headers: headers,
        body: jsonEncode(body),
      );
      return _processResponse(response);
    } on SocketException {
      throw const NetworkException('No Internet connection');
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Unexpected error occurred: ${e.toString()}');
    }
  }

  dynamic _processResponse(http.Response response) {
    dynamic responseJson;
    try {
      responseJson = jsonDecode(response.body);
    } catch (_) {
      responseJson = null;
    }

    switch (response.statusCode) {
      case 200:
      case 201:
        return responseJson;
      case 400:
        final msg = responseJson is Map && responseJson.containsKey('message')
            ? responseJson['message']
            : 'Invalid credentials or request format';
        throw ServerException(msg.toString(), 400);
      case 401:
        final msg = responseJson is Map && responseJson.containsKey('message')
            ? responseJson['message']
            : 'Invalid credentials or session expired';
        throw ServerException(msg.toString(), 401);
      case 404:
        final msg = responseJson is Map && responseJson.containsKey('message')
            ? responseJson['message']
            : 'Resource not found';
        throw ServerException(msg.toString(), 404);
      default:
        final msg = responseJson is Map && responseJson.containsKey('message')
            ? responseJson['message']
            : 'Server error with status code ${response.statusCode}';
        throw ServerException(msg.toString(), response.statusCode);
    }
  }
}
