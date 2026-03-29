import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/cubit/auth_state.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/otp_page.dart';
import 'features/auth/presentation/pages/signup_page.dart';
import 'features/auth/presentation/pages/verification_success_page.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/profile/presentation/pages/edit_profile_page.dart';
import 'features/chatbot/presentation/pages/chatbot_page.dart';
import 'features/scan/presentation/pages/scan_page.dart';
import 'splash_screen.dart';

class AppRouter {
  final AuthCubit authCubit;

  AppRouter({required this.authCubit});

  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();

  late final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: true,
    refreshListenable: GoRouterRefreshStream(authCubit.stream),

    redirect: (context, state) {
      final authState = authCubit.state;
      final isPublicAuthRoute =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup' ||
          state.matchedLocation == '/otp' ||
          state.matchedLocation == '/splash';
      final isVerificationSuccessRoute =
          state.matchedLocation == '/verification-success';
      final isAuthenticated = authState is AuthAuthenticated;
      final isLoading = authState is AuthLoading || authState is AuthInitial;

      if (isLoading) {
        if (isPublicAuthRoute || isVerificationSuccessRoute) return null;
        if (state.matchedLocation != '/splash') return '/splash';
        return null;
      }

      if (!isAuthenticated && !isPublicAuthRoute && !isVerificationSuccessRoute)
        return '/splash';
      if (!isAuthenticated && isVerificationSuccessRoute) return '/login';
      if (isAuthenticated &&
          (isPublicAuthRoute || state.matchedLocation == '/splash'))
        return '/';

      return null;
    },

    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) {
          final initialPhone = state.extra as String?;
          return SignupPage(initialPhone: initialPhone);
        },
      ),
      GoRoute(
        path: '/otp',
        name: 'otp',
        builder: (context, state) {
          final extra = state.extra;
          if (extra is Map<String, dynamic>) {
            return OtpPage(
              flow: (extra['flow'] ?? 'signup').toString(),
              email: extra['email']?.toString(),
              phone: extra['phone']?.toString(),
            );
          }

          final email = extra as String?;
          return OtpPage(flow: 'signup', email: email);
        },
      ),
      GoRoute(
        path: '/verification-success',
        name: 'verification-success',
        builder: (context, state) => const VerificationSuccessPage(),
      ),
      GoRoute(
        path: '/edit-profile',
        name: 'edit-profile',
        builder: (context, state) => const EditProfilePage(),
      ),
      GoRoute(
        path: '/aura-chat',
        name: 'aura-chat',
        builder: (context, state) => const ChatbotPage(),
      ),
      GoRoute(
        path: '/scan-eye',
        name: 'scan-eye',
        builder: (context, state) =>
            const ScanPage(initialMode: ScanMode.eye, lockMode: true),
      ),
      GoRoute(
        path: '/scan-tb',
        name: 'scan-tb',
        builder: (context, state) =>
            const ScanPage(initialMode: ScanMode.tb, lockMode: true),
      ),
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) {
          final tab = state.uri.queryParameters['tab'];
          final initialTabIndex = switch (tab) {
            'scan' => 1,
            'appointments' => 2,
            'abha' => 3,
            'profile' => 4,
            _ => 0,
          };
          return HomePage(initialTabIndex: initialTabIndex);
        },
      ),
    ],

    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.uri.path}')),
    ),
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
