import 'package:equatable/equatable.dart';
import '../../data/models/auth_user_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthUnauthenticated extends AuthState {}

class AuthOtpSent extends AuthState {
  final String email;
  final String message;

  const AuthOtpSent({required this.email, required this.message});

  @override
  List<Object?> get props => [email, message];
}

class AuthLoginOtpSent extends AuthState {
  final String message;
  final String? email;
  final String? phone;

  const AuthLoginOtpSent({
    required this.message,
    this.email,
    this.phone,
  });

  @override
  List<Object?> get props => [message, email, phone];
}

class AuthAuthenticated extends AuthState {
  final AuthUserModel user;
  final String token;
  final String message;

  const AuthAuthenticated({
    required this.user,
    required this.token,
    required this.message,
  });

  @override
  List<Object?> get props => [user, token, message];
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
