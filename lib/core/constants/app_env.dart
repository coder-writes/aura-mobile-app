import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppEnv {
  static const String _defaultCoreApiBaseUrl = 'https://api.devtinder.engineer';

  static String get apiBaseUrl {
    final value = dotenv.env['API_BASE_URL'];
    if (value != null && value.trim().isNotEmpty) {
      final normalized = value.trim();
      // Keep core APIs (auth/doctors/appointments) on the normal backend.
      if (normalized.toLowerCase().contains('ngrok')) {
        return _defaultCoreApiBaseUrl;
      }
      return normalized;
    }
    return _defaultCoreApiBaseUrl;
  }

  static String get scanApiBaseUrl {
    final value = dotenv.env['SCAN_API_BASE_URL'];
    if (value != null && value.trim().isNotEmpty) {
      return value.trim();
    }
    return 'https://phenetic-unpieced-zola.ngrok-free.dev';
  }

  static String get geminiApiKey {
    final value = dotenv.env['GEMINI_API_KEY'];
    if (value != null && value.trim().isNotEmpty) {
      return value.trim();
    }
    return '';
  }

  static String get geminiModel {
    final value = dotenv.env['GEMINI_MODEL'];
    if (value != null && value.trim().isNotEmpty) {
      return value.trim();
    }
    return 'gemini-2.5-flash';
  }
}
