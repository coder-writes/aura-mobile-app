import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

class TimeSlotWidget extends StatefulWidget {
  final Function(TimeOfDay) onTimeSelected;
  final TimeOfDay? selectedTime;

  const TimeSlotWidget({
    super.key,
    required this.onTimeSelected,
    this.selectedTime,
  });

  @override
  State<TimeSlotWidget> createState() => _TimeSlotWidgetState();
}

class _TimeSlotWidgetState extends State<TimeSlotWidget> {
  late List<TimeOfDay> morningSlots;
  late List<TimeOfDay> afternoonSlots;

  @override
  void initState() {
    super.initState();
    _generateTimeSlots();
  }

  void _generateTimeSlots() {
    morningSlots = [];
    afternoonSlots = [];

    // Generate slots from 9:00 AM to 5:00 PM in 30-minute intervals
    for (int hour = 9; hour <= 17; hour++) {
      for (int minute = 0; minute < 60; minute += 30) {
        final slot = TimeOfDay(hour: hour, minute: minute);
        if (hour < 12 || (hour == 12)) {
          morningSlots.add(slot);
        } else {
          afternoonSlots.add(slot);
        }
      }
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  Widget _timeSlotButton(TimeOfDay time) {
    final isSelected = widget.selectedTime == time;
    return GestureDetector(
      onTap: () => widget.onTimeSelected(time),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.15)
              : AppColors.surfaceContainerLow,
          border: isSelected
              ? Border.all(color: AppColors.primary, width: 2)
              : Border.all(color: Colors.transparent, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            _formatTime(time),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isSelected ? AppColors.primary : AppColors.onSurface,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Morning Slots
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Text(
              'MORNING SLOTS',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                letterSpacing: 1.0,
              ),
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: morningSlots.length,
            itemBuilder: (context, index) => _timeSlotButton(morningSlots[index]),
          ),
          const SizedBox(height: 16),
          // Afternoon Slots
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Text(
              'AFTERNOON SLOTS',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                letterSpacing: 1.0,
              ),
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: afternoonSlots.length,
            itemBuilder: (context, index) => _timeSlotButton(afternoonSlots[index]),
          ),
        ],
      ),
    );
  }
}
