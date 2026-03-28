import 'auth_user_model.dart';

class AuthResponseModel {
  final bool success;
  final String message;
  final String? token;
  final AuthUserModel? user;

  const AuthResponseModel({
    required this.success,
    required this.message,
    this.token,
    this.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      success: (json['success'] ?? false) as bool,
      message: (json['message'] ?? '').toString(),
      token: json['token']?.toString(),
      user: json['user'] is Map<String, dynamic>
          ? AuthUserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }
}
