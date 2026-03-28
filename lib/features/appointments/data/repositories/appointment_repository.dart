import 'package:dartz/dartz.dart';
import '../models/doctor_model.dart';
import '../models/appointment_model.dart';
import '../datasources/appointment_remote_datasource.dart';
import '../../../../core/errors/failure.dart';

class AppointmentRepository {
  final AppointmentRemoteDataSource remoteDataSource;

  AppointmentRepository({required this.remoteDataSource});

  /// Fetch doctors list with optional state/district filters
  Future<Either<Failure, List<DoctorModel>>> getDoctors({
    String? state,
    String? district,
  }) async {
    try {
      final doctors = await remoteDataSource.fetchDoctors(
        state: state,
        district: district,
      );
      return Right(doctors);
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Book an appointment
  Future<Either<Failure, AppointmentModel>> bookAppointment({
    required String doctorId,
    required DateTime appointmentDateTime,
    required String reasonForVisit,
    String? notes,
    String? patientType,
  }) async {
    try {
      final appointment = await remoteDataSource.bookAppointment(
        doctorId: doctorId,
        appointmentDateTime: appointmentDateTime,
        reasonForVisit: reasonForVisit,
        notes: notes,
        patientType: patientType,
      );
      return Right(appointment);
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Fetch user's appointments (optional)
  Future<Either<Failure, List<AppointmentModel>>> getAppointments() async {
    try {
      final appointments = await remoteDataSource.fetchAppointments();
      return Right(appointments);
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
