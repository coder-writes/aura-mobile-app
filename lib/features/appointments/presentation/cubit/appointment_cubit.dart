import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/appointment_model.dart';
import '../../data/repositories/appointment_repository.dart';

part 'appointment_state.dart';

class AppointmentCubit extends Cubit<AppointmentState> {
  final AppointmentRepository repository;

  AppointmentCubit({required this.repository}) : super(AppointmentInitial());

  /// Book an appointment
  Future<void> bookAppointment({
    required String doctorId,
    required DateTime appointmentDateTime,
    required String reasonForVisit,
    String? notes,
    String? patientType,
  }) async {
    emit(AppointmentBooking());

    try {
      final result = await repository.bookAppointment(
        doctorId: doctorId,
        appointmentDateTime: appointmentDateTime,
        reasonForVisit: reasonForVisit,
        notes: notes,
        patientType: patientType,
      );

      result.fold(
        (failure) {
          emit(AppointmentError(failure.message));
        },
        (appointment) {
          emit(AppointmentBooked(appointment: appointment));
        },
      );
    } catch (e) {
      emit(AppointmentError('Unexpected error: $e'));
    }
  }

  /// Reset state to initial
  void reset() {
    emit(AppointmentInitial());
  }
}
