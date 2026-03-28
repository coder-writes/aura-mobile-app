import 'package:flutter/material.dart';
import '../../data/models/doctor_model.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

class DoctorCard extends StatelessWidget {
  final DoctorModel doctor;
  final VoidCallback onBookNow;
  final bool isAvailableToday;

  const DoctorCard({
    super.key,
    required this.doctor,
    required this.onBookNow,
    this.isAvailableToday = true,
  });

  /// Get avatar background color based on specialty
  Color _getAvatarBgColor() {
    // Color mapping based on expertise
    final specialtyLower = doctor.expertise.toLowerCase();
    if (specialtyLower.contains('cardio')) {
      return const Color(0xFF83d6c2); // primary-fixed-dim
    } else if (specialtyLower.contains('pediatric')) {
      return const Color(0xFFffb95f); // secondary-fixed-dim
    } else if (specialtyLower.contains('ent') || specialtyLower.contains('derma')) {
      return const Color(0xFFbdc9c6); // tertiary-fixed-dim
    }
    return const Color(0xFF83d6c2); // default
  }

  /// Get avatar text color based on background
  Color _getAvatarTextColor() {
    final specialtyLower = doctor.expertise.toLowerCase();
    if (specialtyLower.contains('cardio')) {
      return const Color(0xFF005144); // on-primary-fixed-variant
    } else if (specialtyLower.contains('pediatric')) {
      return const Color(0xFF653e00); // on-secondary-fixed-variant
    } else if (specialtyLower.contains('ent') || specialtyLower.contains('derma')) {
      return const Color(0xFF3e4947); // on-tertiary-fixed-variant
    }
    return const Color(0xFF005144); // default
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: const BorderRadius.all(Radius.circular(24)),
        border: AppColors.ghostBorder,
        boxShadow: AppColors.ambientShadow,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Doctor card content - header with avatar, name, specialty
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getAvatarBgColor(),
                  border: Border.all(
                    color: AppColors.surfaceContainerLowest,
                    width: 4,
                  ),
                ),
                child: Center(
                  child: Text(
                    doctor.initials,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: _getAvatarTextColor(),
                      fontFamily: 'Baloo 2',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Doctor info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and Rating row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Dr. ${doctor.fullName}',
                            style: AppTextStyles.titleLarge,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEA619).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star,
                                size: 12,
                                color: Color(0xFFFEA619),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '4.${doctor.experience % 10}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF684000),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Expertise badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2F1),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text(
                        doctor.expertise,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Location
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: AppColors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            doctor.displayLocation,
                            style: AppTextStyles.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Availability
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: isAvailableToday
                              ? AppColors.primary
                              : AppColors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isAvailableToday
                              ? 'Available Today'
                              : 'Next: Tomorrow, 10:00 AM',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isAvailableToday
                                ? AppColors.primary
                                : AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Book Now button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: Container(
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onBookNow,
                  borderRadius: BorderRadius.circular(16),
                  child: const Center(
                    child: Text(
                      'Book Now',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
