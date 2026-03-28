import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:aura/l10n/app_localizations.dart';

import '../../../../core/providers/locale_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/data/models/auth_user_model.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import 'user_profile_detail_screen.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = context.watch<AuthCubit>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          Positioned(
            top: -80,
            right: -120,
            child: _OrganicBlob(
              size: 260,
              color: AppColors.primary.withValues(alpha: 0.08),
            ),
          ),
          Positioned(
            top: 380,
            left: -140,
            child: _OrganicBlob(
              size: 320,
              color: AppColors.secondary.withValues(alpha: 0.06),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 130),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TopBar(onEditProfile: () => context.push('/edit-profile')),
                  const SizedBox(height: 16),
                  _ProfileHeroCard(l10n: l10n, user: user),
                  const SizedBox(height: 24),
                  /*
                  Text(
                    l10n.profileVitalMetrics,
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _GaugeCard(
                          title: l10n.profileBmiIndex,
                          value: '22.4',
                          unit: 'kg/m²',
                          badge: l10n.profileNormal,
                          progress: 0.68,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _GaugeCard(
                          title: l10n.profileHemoglobin,
                          value: '14.2',
                          unit: 'g/dL',
                          badge: l10n.profileHealthy,
                          progress: 0.85,
                          color: AppColors.secondaryContainer,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  */
                  Text(
                    l10n.profileScanHistory,
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _ScanHistoryTimeline(l10n: l10n),
                  const SizedBox(height: 24),
                  Text(
                    l10n.profileSettings,
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _SettingsCard(
                    l10n: l10n,
                    onEditProfile: () => context.push('/edit-profile'),
                    onLogout: () async {
                      await context.read<AuthCubit>().logout();
                      if (context.mounted) {
                        context.go('/login');
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final VoidCallback onEditProfile;

  const _TopBar({required this.onEditProfile});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        const Icon(Icons.spa_rounded, color: AppColors.primaryContainer),
        const SizedBox(width: 8),
        Text(
          l10n.appTitle,
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: onEditProfile,
          tooltip: l10n.profileEditPersonalInfo,
          icon: const Icon(Icons.edit_rounded, color: AppColors.primary),
        ),
        InkWell(
          onTap: () => context.read<LocaleProvider>().toggleLocale(),
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                const Icon(Icons.language_rounded, size: 16, color: AppColors.primary),
                const SizedBox(width: 4),
                Text(
                  l10n.languageSwitch,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileHeroCard extends StatelessWidget {
  final AppLocalizations l10n;
  final AuthUserModel? user;

  const _ProfileHeroCard({required this.l10n, required this.user});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: user != null
          ? () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserProfileDetailScreen(user: user!),
                ),
              )
          : null,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.15),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: AppColors.secondaryFixed,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    user?.initials ?? l10n.profileInitials,
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: AppColors.onSecondaryContainer,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.fullName ?? l10n.profileName,
                        style: AppTextStyles.headlineSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.badge_rounded, size: 14, color: Colors.white70),
                            const SizedBox(width: 4),
                            Text(
                              '${l10n.profileAbhaPrefix}: ${_displayProfileId(user, l10n)}',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Colors.white70),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _MiniStatCard(
                    label: l10n.profileAge,
                    value: user?.age?.toString() ?? '28',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MiniStatCard(
                    label: l10n.profileGender,
                    value: user?.gender ?? l10n.profileGenderValue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MiniStatCard(
                    label: l10n.profileBlood,
                    value: user?.bloodGroup ?? 'O+',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final String label;
  final String value;

  const _MiniStatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: Colors.white70,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.titleMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}



class _ScanHistoryTimeline extends StatelessWidget {
  final AppLocalizations l10n;

  const _ScanHistoryTimeline({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 10,
          top: 8,
          bottom: 8,
          child: Container(width: 2, color: AppColors.outlineVariant.withValues(alpha: 0.35)),
        ),
        Column(
          children: [
            _TimelineItem(
              date: l10n.profileScanDate1,
              title: l10n.profileScanTitle1,
              subtitle: l10n.profileScanSubtitle1,
              badge: l10n.profileNormal,
              color: AppColors.primary,
            ),
            const SizedBox(height: 12),
            _TimelineItem(
              date: l10n.profileScanDate2,
              title: l10n.profileScanTitle2,
              subtitle: l10n.profileScanSubtitle2,
              badge: l10n.profileFollowUp,
              color: AppColors.secondary,
            ),
            const SizedBox(height: 12),
            _TimelineItem(
              date: l10n.profileScanDate3,
              title: l10n.profileScanTitle3,
              subtitle: l10n.profileScanSubtitle3,
              badge: l10n.profileNormal,
              color: AppColors.primary,
            ),
          ],
        ),
      ],
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final String date;
  final String title;
  final String subtitle;
  final String badge;
  final Color color;

  const _TimelineItem({
    required this.date,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 4),
          width: 22,
          alignment: Alignment.center,
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        date,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: color,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        title,
                        style: AppTextStyles.titleSmall.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(subtitle, style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    badge,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final AppLocalizations l10n;
  final VoidCallback onEditProfile;
  final VoidCallback onLogout;

  const _SettingsCard({
    required this.l10n,
    required this.onEditProfile,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          _SettingTile(
            icon: Icons.person_rounded,
            title: l10n.profileEditPersonalInfo,
            subtitle: l10n.profileEditPersonalInfoSubtitle,
            onTap: onEditProfile,
          ),
          _SettingTile(
            icon: Icons.verified_user_rounded,
            title: l10n.profilePrivacySecurity,
            subtitle: l10n.profilePrivacySecuritySubtitle,
          ),
          _SettingTile(
            icon: Icons.language_rounded,
            title: l10n.profileLanguagePreference,
            subtitle: l10n.profileLanguagePreferenceSubtitle,
          ),
          _SettingTile(
            icon: Icons.logout_rounded,
            title: l10n.profileLogout,
            subtitle: '',
            isLogout: true,
            onTap: onLogout,
          ),
        ],
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isLogout;
  final VoidCallback? onTap;

  const _SettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.isLogout = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = isLogout ? Colors.red.shade700 : AppColors.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.titleSmall.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall,
                    ),
                ],
              ),
            ),
            Icon(
              isLogout ? Icons.logout_rounded : Icons.chevron_right_rounded,
              color: accent,
            ),
          ],
        ),
      ),
    );
  }
}

class _OrganicBlob extends StatelessWidget {
  final double size;
  final Color color;

  const _OrganicBlob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size / 2),
      ),
    );
  }
}

String _displayProfileId(AuthUserModel? user, AppLocalizations l10n) {
  if (user == null || user.id.trim().isEmpty) return l10n.profileAbhaId;
  final id = user.id.trim();
  return id.length > 12 ? id.substring(0, 12) : id;
}
