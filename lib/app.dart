import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:aura/l10n/app_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/appointments/data/datasources/appointment_remote_datasource.dart';
import 'features/appointments/data/repositories/appointment_repository.dart';
import 'features/appointments/presentation/cubit/doctor_list_cubit.dart';
import 'features/appointments/presentation/cubit/appointment_cubit.dart';
import 'features/chatbot/data/datasources/gemini_chat_remote_datasource.dart';
import 'features/chatbot/data/repositories/chatbot_repository.dart';
import 'features/chatbot/presentation/cubit/chatbot_cubit.dart';
import 'core/network/api_client.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/locale_provider.dart';
import 'router.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<void> _providersFuture;
  late final AuthRepository _authRepository;
  late final FlutterSecureStorage _secureStorage;

  @override
  void initState() {
    super.initState();
    _secureStorage = const FlutterSecureStorage();
    final apiClient = ApiClient(secureStorage: _secureStorage);
    _authRepository = AuthRepository(
      remoteDataSource: AuthRemoteDataSourceImpl(
        apiClient: apiClient,
      ),
    );
    _providersFuture = _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Initialize services here
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    final apiClient = ApiClient(secureStorage: _secureStorage);
    final appointmentRepository = AppointmentRepository(
      remoteDataSource: AppointmentRemoteDataSource(apiClient: apiClient),
    );
    final chatbotRepository = ChatbotRepository(
      remoteDataSource: GeminiChatRemoteDataSource(),
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        BlocProvider<AuthCubit>(
          create: (_) => AuthCubit(
            authRepository: _authRepository,
            secureStorage: _secureStorage,
          )..checkAuth(),
        ),
        BlocProvider<DoctorListCubit>(
          create: (_) => DoctorListCubit(repository: appointmentRepository),
        ),
        BlocProvider<AppointmentCubit>(
          create: (_) => AppointmentCubit(repository: appointmentRepository),
        ),
        BlocProvider<ChatbotCubit>(
          create: (context) => ChatbotCubit(
            repository: chatbotRepository,
            authCubit: context.read<AuthCubit>(),
          )..loadHistory(),
        ),
      ],
      child: FutureBuilder<void>(
        future: _providersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
            );
          }

          if (snapshot.hasError) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              home: Scaffold(
                body: Center(child: Text('Initialization Error: ${snapshot.error}')),
              ),
            );
          }

          return const _AppContent();
        },
      ),
    );
  }
}

class _AppContent extends StatefulWidget {
  const _AppContent();

  @override
  State<_AppContent> createState() => _AppContentState();
}

class _AppContentState extends State<_AppContent> {
  late final AppRouter _appRouter;
  final GlobalKey<ScaffoldMessengerState> _messengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    _appRouter = AppRouter(authCubit: context.read<AuthCubit>());
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context)?.appTitle ?? 'Aura Health',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      locale: localeProvider.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      scaffoldMessengerKey: _messengerKey,
      routerConfig: _appRouter.router,
      builder: (context, child) {
        return ScrollConfiguration(
          behavior: const ScrollBehavior().copyWith(
            physics: const BouncingScrollPhysics(),
          ),
          child: child!,
        );
      },
    );
  }
}
