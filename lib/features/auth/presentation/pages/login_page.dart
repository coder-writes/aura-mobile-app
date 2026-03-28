import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:aura/l10n/app_localizations.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _inputController = TextEditingController();

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _onContinue() {
    final input = _inputController.text.trim();
    if (input.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your mobile or email')),
      );
      return;
    }

    final isEmail = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}").hasMatch(input);
    final isPhone = RegExp(r"^\d{10}$").hasMatch(input);

    if (isEmail) {
      context.read<AuthCubit>().login(email: input);
    } else if (isPhone) {
      context.read<AuthCubit>().login(phone: input);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 10-digit mobile or email'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthLoginOtpSent) {
            final input = _inputController.text.trim();
            final isEmail = RegExp(
              r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}",
            ).hasMatch(input);

            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
            context.push(
              '/otp',
              extra: {
                'flow': 'login',
                'phone': isEmail ? null : input,
                'email': isEmail ? input : null,
              },
            );
          }

          if (state is AuthError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: Stack(
          children: [
            Positioned(
              top: -100,
              right: -50,
              child: _buildBlob(300, AppColors.primary.withValues(alpha: 0.05)),
            ),
            Positioned(
              bottom: 100,
              left: -80,
              child: _buildBlob(250, AppColors.amberAccent.withValues(alpha: 0.08)),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isCompact = constraints.maxHeight < 760;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Welcome to Aura',
                                    style: theme.textTheme.headlineLarge,
                                  ),
                                  Text(
                                    'आभा में आपका स्वागत है',
                                    style: AppTextStyles.hindiStyle(
                                      theme.textTheme.titleLarge!,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            InkWell(
                              onTap: () =>
                                  context.read<LocaleProvider>().toggleLocale(),
                              borderRadius: BorderRadius.circular(24),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.language_rounded,
                                      size: 16,
                                      color: AppColors.primary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      l10n.languageSwitch,
                                      style: theme.textTheme.labelMedium
                                          ?.copyWith(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: isCompact ? 8 : 12),
                        Text(
                          'Step into your digital sanctuary for health and well-being.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(height: isCompact ? 12 : 16),
                        Flexible(
                          fit: FlexFit.tight,
                          child: Container(
                            padding: EdgeInsets.all(isCompact ? 14 : 18),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildFeatureRow(
                                  Icons.security_outlined,
                                  'Secure ABHA Linking',
                                  'सुरक्षित आभा लिंकिंग',
                                  compact: isCompact,
                                ),
                                SizedBox(height: isCompact ? 12 : 18),
                                _buildFeatureRow(
                                  Icons.document_scanner_outlined,
                                  'AI Health Scans',
                                  'स्वास्थ्य स्कैन',
                                  compact: isCompact,
                                ),
                                SizedBox(height: isCompact ? 12 : 18),
                                _buildFeatureRow(
                                  Icons.health_and_safety_outlined,
                                  'Priority Care',
                                  'प्राथमिकता देखभाल',
                                  compact: isCompact,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: isCompact ? 10 : 14),
                        Text(
                          'Mobile or Email / मोबाइल या ईमेल',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _inputController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _onContinue(),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: const InputDecoration(
                            hintText: '98765 43210 or hello@example.com',
                            prefixIcon: Icon(Icons.contact_mail_outlined),
                          ),
                        ),
                        SizedBox(height: isCompact ? 10 : 14),
                        BlocBuilder<AuthCubit, AuthState>(
                          builder: (context, state) {
                            if (state is AuthLoading) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            return _buildPrimaryButton();
                          },
                        ),
                        const SizedBox(height: 6),
                        Center(
                          child: TextButton(
                            onPressed: () => context.push('/signup'),
                            child: Text(
                              l10n.dontHaveAccount,
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        if (!isCompact) const Spacer(),
                        Center(
                          child: Text(
                            'By continuing, you agree to our Terms and Privacy Policy',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlob(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _buildFeatureRow(
    IconData icon,
    String title,
    String subtitle, {
    bool compact = false,
  }) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(compact ? 10 : 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppColors.ambientShadow,
          ),
          child: Icon(icon, color: AppColors.primary, size: compact ? 20 : 24),
        ),
        SizedBox(width: compact ? 12 : 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: compact ? 14 : null,
                ),
              ),
              Text(
                subtitle,
                style: AppTextStyles.hindiStyle(theme.textTheme.labelSmall!),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton() {
    return Container(
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.ambientShadow,
      ),
      child: ElevatedButton(
        onPressed: _onContinue,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        child: const Text('Continue / जारी रखें'),
      ),
    );
  }
}
