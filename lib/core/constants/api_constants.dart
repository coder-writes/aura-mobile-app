import 'app_env.dart';

class ApiConstants {
  ApiConstants._();

  static String get baseUrl => AppEnv.apiBaseUrl;

  // Auth endpoints
  static const String signup = '/api/auth/signup';
  static const String verifyOtp = '/api/auth/verify-otp';
  static const String login = '/api/auth/login';
  static const String verifyLoginOtp = '/api/auth/verify-login-otp';
  static const String updateProfile = '/api/users/profile';
  static const String getMe = '/api/users/me';

  // Doctor endpoints
  static const String getDoctors = '/api/doctors';
  static const String getDoctorById = '/api/doctors/'; // Append doctor ID

  // Appointment endpoints
  static const String bookAppointment = '/api/appointments/book';
  static const String getAppointments = '/api/appointments';

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
