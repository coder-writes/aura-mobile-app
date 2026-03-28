import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppEnv {
  static String get apiBaseUrl {
    final value = dotenv.env['API_BASE_URL'];
    if (value != null && value.trim().isNotEmpty) {
      return value.trim();
    }
    return 'https://api.devtinder.engineer';
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
    return 'gemini-1.5-flash-latest';
  }
}
