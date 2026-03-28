import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:aura/app.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');
  
  // Initialize services e.g., DotEnv, Firebase here as needed.
  
  if (!kDebugMode) {
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      // report to crashlytics
    };

    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      // report to crashlytics
      return true;
    };
  } else {
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
    };
  }

  runApp(const MyApp());
}
