import 'package:small_task_au/features/auth/data/models/user_model.dart';

class AuthResponseModel {
  final String token;
  final UserModel user;

  const AuthResponseModel({
    required this.token,
    required this.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    final token = json['accessToken'] as String? ?? json['token'] as String? ?? '';
    final userModel = UserModel.fromJson(json);
    return AuthResponseModel(
      token: token,
      user: userModel,
    );
  }
}
