import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../data/models/appointment_model.dart';
import '../cubit/appointment_cubit.dart';

class AppointmentHistoryScreen extends StatefulWidget {
  const AppointmentHistoryScreen({super.key});

  @override
  State<AppointmentHistoryScreen> createState() =>
      _AppointmentHistoryScreenState();
}

class _AppointmentHistoryScreenState extends State<AppointmentHistoryScreen> {
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final authState = context.read<AuthCubit>().state;
      final userId = authState is AuthAuthenticated ? authState.user.id : null;
      context.read<AppointmentCubit>().loadAppointments(
        forceRefresh: true,
        currentUserId: userId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          'Appointment History',
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: _FilterChipButton(
                    label: 'All',
                    selected: _filter == 'all',
                    onTap: () => setState(() => _filter = 'all'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _FilterChipButton(
                    label: 'Self',
                    selected: _filter == 'self',
                    onTap: () => setState(() => _filter = 'self'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _FilterChipButton(
                    label: 'Family',
                    selected: _filter == 'family',
                    onTap: () => setState(() => _filter = 'family'),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<AppointmentCubit, AppointmentState>(
              builder: (context, state) {
                if (state is AppointmentHistoryLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is AppointmentHistoryError) {
                  return _HistoryMessage(
                    text: state.message,
                    actionLabel: 'Retry',
                    onTap: () {
                      final authState = context.read<AuthCubit>().state;
                      final userId = authState is AuthAuthenticated
                          ? authState.user.id
                          : null;
                      context.read<AppointmentCubit>().loadAppointments(
                        forceRefresh: true,
                        currentUserId: userId,
                      );
                    },
                  );
                }

                final appointments = state is AppointmentHistoryLoaded
                    ? state.appointments
                    : <AppointmentModel>[];

                final filtered = appointments
                    .where((item) {
                      if (_filter == 'all') return true;
                      return (item.patientType ?? 'self').toLowerCase() ==
                          _filter;
                    })
                    .toList(growable: false);

                if (filtered.isEmpty) {
                  return _HistoryMessage(
                    text: 'There is no history for current user.',
                    actionLabel: 'Refresh',
                    onTap: () {
                      final authState = context.read<AuthCubit>().state;
                      final userId = authState is AuthAuthenticated
                          ? authState.user.id
                          : null;
                      context.read<AppointmentCubit>().loadAppointments(
                        forceRefresh: true,
                        currentUserId: userId,
                      );
                    },
                  );
                }

                return RefreshIndicator(
                  onRefresh: () {
                    final authState = context.read<AuthCubit>().state;
                    final userId = authState is AuthAuthenticated
                        ? authState.user.id
                        : null;
                    return context.read<AppointmentCubit>().loadAppointments(
                      forceRefresh: true,
                      currentUserId: userId,
                    );
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                    itemCount: filtered.length,
                    separatorBuilder: (context, _) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final appointment = filtered[index];
                      return _HistoryCard(appointment: appointment);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  const _FilterChipButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.outlineVariant,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.labelLarge.copyWith(
              color: selected ? Colors.white : AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.appointment});

  final AppointmentModel appointment;

  @override
  Widget build(BuildContext context) {
    final patientType = (appointment.patientType ?? 'self').toLowerCase();
    final isSelf = patientType == 'self';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  appointment.doctorName == null ||
                          appointment.doctorName!.trim().isEmpty
                      ? 'Doctor ID: ${appointment.doctorId}'
                      : 'Dr. ${appointment.doctorName}',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isSelf
                      ? const Color(0xFFE8F5F1)
                      : const Color(0xFFFFF2DF),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  isSelf ? 'Self' : 'Family',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isSelf ? AppColors.primary : const Color(0xFF9F6A00),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (appointment.doctorExpertise != null &&
              appointment.doctorExpertise!.trim().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              appointment.doctorExpertise!,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Text(appointment.reasonForVisit, style: AppTextStyles.bodyMedium),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.event_rounded,
                size: 16,
                color: AppColors.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                '${appointment.formattedDate} • ${appointment.formattedTime}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                size: 16,
                color: AppColors.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                'Status: ${appointment.status}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          if (appointment.notes != null &&
              appointment.notes!.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'Notes: ${appointment.notes}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HistoryMessage extends StatelessWidget {
  const _HistoryMessage({
    required this.text,
    required this.actionLabel,
    required this.onTap,
  });

  final String text;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onTap, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}
