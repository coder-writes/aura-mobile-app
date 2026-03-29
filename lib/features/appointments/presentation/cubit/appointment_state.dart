part of 'appointment_cubit.dart';

abstract class AppointmentState {}

class AppointmentInitial extends AppointmentState {}

class AppointmentBooking extends AppointmentState {}

class AppointmentBooked extends AppointmentState {
  final AppointmentModel appointment;

  AppointmentBooked({required this.appointment});

  @override
  String toString() =>
      'AppointmentBooked(queue: #${appointment.queueNumber}, date: ${appointment.formattedDate}, time: ${appointment.formattedTime})';
}

class AppointmentError extends AppointmentState {
  final String message;

  AppointmentError(this.message);

  @override
  String toString() => 'AppointmentError($message)';
}

class AppointmentHistoryLoading extends AppointmentState {}

class AppointmentHistoryLoaded extends AppointmentState {
  final List<AppointmentModel> appointments;

  AppointmentHistoryLoaded({required this.appointments});
}

class AppointmentHistoryError extends AppointmentState {
  final String message;

  AppointmentHistoryError(this.message);
}
