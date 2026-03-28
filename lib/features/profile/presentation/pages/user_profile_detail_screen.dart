import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/data/models/auth_user_model.dart';


class UserProfileDetailScreen extends StatelessWidget {
  final AuthUserModel user;

  const UserProfileDetailScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          'Personal Details',
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoCard(
              title: 'Identity',
              icon: Icons.person_outline,
              items: [
                _InfoItem(label: 'Full Name', value: '${user.firstName} ${user.lastName}'),
                _InfoItem(label: 'ABHA ID', value: user.id),
                _InfoItem(label: 'Gender', value: user.gender ?? 'Not specified'),
                _InfoItem(label: 'Date of Birth', value: user.dateOfBirth ?? 'Not specified'),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              title: 'Family Details',
              icon: Icons.family_restroom_outlined,
              items: [
                _InfoItem(label: 'Mother\'s Name', value: user.motherName ?? 'Not specified'),
                _InfoItem(label: 'Father\'s Name', value: user.fatherName ?? 'Not specified'),
                _InfoItem(label: 'Marital Status', value: user.maritalStatus ?? 'Not specified'),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              title: 'Location',
              icon: Icons.location_on_outlined,
              items: [
                _InfoItem(label: 'State', value: user.state ?? 'Not specified'),
                _InfoItem(label: 'District/City', value: user.district ?? 'Not specified'),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              title: 'Health Profile',
              icon: Icons.health_and_safety_outlined,
              items: [
                _InfoItem(label: 'Blood Group', value: user.bloodGroup ?? 'Not specified'),
                _InfoItem(label: 'Height', value: user.height ?? 'Not specified'),
                _InfoItem(label: 'Weight', value: user.weight ?? 'Not specified'),
                _InfoItem(label: 'Medical Notes', value: user.inbornDiseasesAndNotes ?? 'No notes available'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<_InfoItem> items,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          ...items,
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;

  const _InfoItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
