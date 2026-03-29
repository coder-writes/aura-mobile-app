import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:aura/l10n/app_localizations.dart';
import '../../../../components/cards/activity_list_item.dart';
import '../../../../components/cards/quick_action_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../widgets/ai_tip_banner.dart';

class DashboardScreen extends StatelessWidget {
  final Function(int)? onTabChange;

  const DashboardScreen({super.key, this.onTabChange});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            const Icon(Icons.spa_rounded, color: AppColors.primaryContainer),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                l10n.appTitle,
                style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => context.push('/aura-chat'),
            tooltip: 'AURA Chat',
            icon: const Icon(Icons.smart_toy_rounded, color: AppColors.primary),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: InkWell(
              onTap: () {
                context.read<LocaleProvider>().toggleLocale();
              },
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border.all(
                    color: AppColors.outlineVariant.withValues(alpha: 0.5),
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.language_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      l10n.languageSwitch,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Hero Section
            const _HeroSection(),

            const SizedBox(height: 24),

            // 2. Quick Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.bolt_rounded,
                    size: 20,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.quickActions,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.1,
                children: [
                  QuickActionCard(
                    icon: Icons.visibility_rounded,
                    iconColor: AppColors.secondaryContainer,
                    title: l10n.anemiaScan,
                    subtitle: l10n.instantCheck,
                    onTap: () {
                      context.push('/scan-eye');
                    },
                  ),
                  QuickActionCard(
                    icon: Icons.air_rounded,
                    iconColor: Colors.blue.shade500,
                    title: l10n.tbScreening,
                    subtitle: l10n.respiratoryAi,
                    onTap: () {
                      context.push('/scan-tb');
                    },
                  ),
                  QuickActionCard(
                    icon: Icons.calendar_month_rounded,
                    iconColor: AppColors.primaryContainer,
                    title: l10n.appointment,
                    subtitle: l10n.bookVisit,
                    onTap: () {
                      onTabChange?.call(2); // Appointments tab
                    },
                  ),
                  QuickActionCard(
                    icon: Icons.badge_rounded,
                    iconColor: Colors.pink.shade500,
                    title: l10n.abhaId,
                    subtitle: l10n.digitalHealth,
                    onTap: () {
                      onTabChange?.call(3); // ABHA tab
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 3. Recent Activity
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.history_rounded,
                    size: 20,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.recentActivity,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  ActivityListItem(
                    title: l10n.anemiaScanCompleted,
                    subtitle: l10n.resultHealthyRange,
                    time: l10n.time2hAgo,
                    dotColor: AppColors.primary,
                  ),
                  ActivityListItem(
                    title: l10n.linkedToVillageClinic,
                    subtitle: l10n.dataSyncSuccessful,
                    time: l10n.yesterday,
                    dotColor: AppColors.outlineVariant,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 4. AI Tip Banner
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: AITipBanner(tipText: l10n.todayTip),
            ),

            const SizedBox(height: 100), // Padding for bottom nav bar
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(
          bottom: 80.0,
        ), // Padding to clear the bottom nav bar
        child: FloatingActionButton.extended(
          onPressed: () => context.push('/aura-chat'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          icon: const Icon(Icons.auto_awesome_rounded),
          label: const Text(
            'AURA AI',
            style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.5),
          ),
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background Glowing Orbs
          Positioned(
            top: -10,
            right: -10,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withValues(alpha: 0.8),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            left: -20,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),

          // Main Hero Card
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              final user = state is AuthAuthenticated ? state.user : null;
              final firstName = user?.firstName ?? 'Priya';

              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${AppLocalizations.of(context)!.hello}, $firstName 👋',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.onPrimaryContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context)!.heroTagline,
                      style: AppTextStyles.headlineLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Stat Chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 10,
                      children: [
                        _StatChip(
                          label: AppLocalizations.of(context)!.scansDone,
                          color: AppColors.secondaryContainer,
                          icon: Icons.check_circle_outline_rounded,
                        ),
                        _StatChip(
                          label: AppLocalizations.of(
                            context,
                          )!.appointmentsPending,
                          color: AppColors.secondaryContainer,
                          icon: Icons.calendar_today_rounded,
                        ),
                        _StatChip(
                          label: AppLocalizations.of(context)!.abhaLinked,
                          color: AppColors.secondaryContainer,
                          icon: Icons.badge_rounded,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _StatChip({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
