import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../data/models/doctor_model.dart';
import '../cubit/appointment_cubit.dart';
import '../widgets/time_slot_widget.dart';
import 'appointment_confirmation_screen.dart';

class BookingScreen extends StatefulWidget {
  final DoctorModel doctor;

  const BookingScreen({
    super.key,
    required this.doctor,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _patientType = 'self'; // 'self' or 'family'
  late TextEditingController _reasonController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _reasonController = TextEditingController();
    _notesController = TextEditingController();
    _selectedDate = DateTime.now().add(const Duration(days: 1));
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dayName = days[date.weekday - 1];
    return '$dayName\n${date.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.primaryContainer,
        elevation: 8,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Book Slot',
              style: AppTextStyles.headlineMedium.copyWith(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            Text(
              'Dr. ${widget.doctor.fullName}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      body: BlocListener<AppointmentCubit, AppointmentState>(
        listener: (context, state) {
          if (state is AppointmentBooked) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => AppointmentConfirmationScreen(
                  appointment: state.appointment,
                  doctor: widget.doctor,
                ),
              ),
            );
          } else if (state is AppointmentError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Self/Family Toggle
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _patientType = 'self'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _patientType == 'self'
                                  ? Colors.white
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                'Self',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _patientType == 'self'
                                      ? AppColors.primary
                                      : AppColors.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _patientType = 'family'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _patientType == 'family'
                                  ? Colors.white
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                'Family',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _patientType == 'family'
                                      ? AppColors.primary
                                      : AppColors.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Date Selection
                Text(
                  'SELECT DATE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 7,
                    itemBuilder: (context, index) {
                      final date =
                          DateTime.now().add(Duration(days: index + 1));
                      final isSelected = _selectedDate?.day == date.day &&
                          _selectedDate?.month == date.month &&
                          _selectedDate?.year == date.year;

                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedDate = date),
                          child: Container(
                            width: 64,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Text(
                                _formatDate(date),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                // Time Slots
                Text(
                  'SELECT TIME',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 12),
                TimeSlotWidget(
                  selectedTime: _selectedTime,
                  onTimeSelected: (time) {
                    setState(() => _selectedTime = time);
                  },
                ),
                const SizedBox(height: 24),
                // Reason for Visit
                Text(
                  'REASON FOR VISIT',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _reasonController,
                  decoration: InputDecoration(
                    hintText: 'e.g., Regular checkup, Heart checkup...',
                    filled: true,
                    fillColor: AppColors.surfaceContainerLow,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.outlineVariant.withValues(alpha: 0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.outlineVariant.withValues(alpha: 0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                // Notes
                Text(
                  'ADDITIONAL NOTES (Optional)',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _notesController,
                  decoration: InputDecoration(
                    hintText: 'Add any additional information...',
                    filled: true,
                    fillColor: AppColors.surfaceContainerLow,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.outlineVariant.withValues(alpha: 0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.outlineVariant.withValues(alpha: 0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 32),
                // Confirm Button
                BlocBuilder<AppointmentCubit, AppointmentState>(
                  builder: (context, state) {
                    final isLoading = state is AppointmentBooking;

                    return SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: isLoading
                                ? null
                                : () {
                                    if (_selectedDate == null ||
                                        _selectedTime == null ||
                                        _reasonController.text.isEmpty) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Please fill all required fields',
                                          ),
                                          backgroundColor: Colors.orange,
                                        ),
                                      );
                                      return;
                                    }

                                    final appointmentDateTime = DateTime(
                                      _selectedDate!.year,
                                      _selectedDate!.month,
                                      _selectedDate!.day,
                                      _selectedTime!.hour,
                                      _selectedTime!.minute,
                                    );

                                    final authState = context.read<AuthCubit>().state;
                                    final currentUserId = authState is AuthAuthenticated
                                        ? authState.user.id
                                        : null;

                                    context.read<AppointmentCubit>()
                                        .bookAppointment(
                                          doctorId: widget.doctor.id,
                                          appointmentDateTime:
                                              appointmentDateTime,
                                        doctorName: widget.doctor.fullName,
                                        doctorExpertise: widget.doctor.expertise,
                                          reasonForVisit:
                                              _reasonController.text,
                                          notes: _notesController.text
                                                  .isNotEmpty
                                              ? _notesController.text
                                              : null,
                                          patientType: _patientType,
                                          currentUserId: currentUserId,
                                        );
                                  },
                            borderRadius: BorderRadius.circular(16),
                            child: Center(
                              child: isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Confirm Appointment',
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
                    );
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
