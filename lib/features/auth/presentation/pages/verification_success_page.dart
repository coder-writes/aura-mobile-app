import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:aura/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class VerificationSuccessPage extends StatelessWidget {
  const VerificationSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          Positioned(
            top: -80,
            right: -80,
            child: _Blob(
              size: 280,
              color: AppColors.surfaceContainerLow.withValues(alpha: 0.7),
            ),
          ),
          Positioned(
            top: 320,
            left: -120,
            child: _Blob(
              size: 320,
              color: AppColors.surfaceContainerHighest.withValues(alpha: 0.5),
            ),
          ),
          Positioned(
            bottom: -80,
            right: -60,
            child: _Blob(
              size: 220,
              color: AppColors.primary.withValues(alpha: 0.08),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.spa_rounded, color: AppColors.primaryContainer, size: 28),
                      const SizedBox(width: 8),
                      Text(
                        'Aura',
                        style: AppTextStyles.headlineMedium.copyWith(
                          color: AppColors.primaryContainer,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 176,
                          height: 176,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLowest,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.08),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.verified_rounded,
                            color: AppColors.primaryContainer,
                            size: 88,
                          ),
                        ),
                        const SizedBox(height: 36),
                        Text(
                          l10n.verificationSuccessTitleEn,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.headlineMedium.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          l10n.verificationSuccessTitleHi,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.hindiStyle(
                            AppTextStyles.headlineMedium.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          l10n.verificationSuccessSubtitleEn,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.verificationSuccessSubtitleHi,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.hindiStyle(
                            AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                        const SizedBox(height: 44),
                        _PrimaryActionButton(
                          title: l10n.completeProfileEn,
                          subtitle: l10n.completeProfileHi,
                          onTap: () => context.go('/edit-profile'),
                        ),
                        const SizedBox(height: 12),
                        _SecondaryActionButton(
                          title: l10n.goToDashboardEn,
                          subtitle: l10n.goToDashboardHi,
                          onTap: () => context.go('/'),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.primaryContainer, shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Container(width: 6, height: 6, decoration: BoxDecoration(color: AppColors.outlineVariant.withValues(alpha: 0.6), shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Container(width: 6, height: 6, decoration: BoxDecoration(color: AppColors.outlineVariant.withValues(alpha: 0.6), shape: BoxShape.circle)),
                    ],
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

class _PrimaryActionButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _PrimaryActionButton({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
            child: Column(
              children: [
                Text(
                  title,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SecondaryActionButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SecondaryActionButton({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Column(
            children: [
              Text(
                title,
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primary.withValues(alpha: 0.75),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  final double size;
  final Color color;

  const _Blob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}