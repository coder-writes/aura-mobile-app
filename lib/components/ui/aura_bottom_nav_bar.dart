import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:aura/l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class AuraBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AuraBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        border: Border(
          top: BorderSide(
            color: AppColors.outlineVariant.withValues(alpha: 0.2),
          ),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x140A6E5E), // 8% opacity teal tint
            offset: Offset(0, -8),
            blurRadius: 24,
          ),
        ],
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _NavItem(
                    icon: Icons.home_rounded,
                    label: l10n.navHome,
                    isSelected: currentIndex == 0,
                    onTap: () => onTap(0),
                  ),
                  _NavItem(
                    icon: Icons.filter_center_focus_rounded,
                    label: l10n.navScan,
                    isSelected: currentIndex == 1,
                    onTap: () => onTap(1),
                  ),
                  _NavItem(
                    icon: Icons.calendar_today_rounded,
                    label: l10n.navAppointments,
                    isSelected: currentIndex == 2,
                    onTap: () => onTap(2),
                  ),
                  _NavItem(
                    icon: Icons.badge_rounded,
                    label: l10n.navAbha,
                    isSelected: currentIndex == 3,
                    onTap: () => onTap(3),
                  ),
                  _NavItem(
                    icon: Icons.person_rounded,
                    label: l10n.navProfile,
                    isSelected: currentIndex == 4,
                    onTap: () => onTap(4),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 8,
          vertical: 8,
        ),
        decoration: isSelected
            ? BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              )
            : const BoxDecoration(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey.shade500,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: isSelected ? Colors.white : Colors.grey.shade500,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
