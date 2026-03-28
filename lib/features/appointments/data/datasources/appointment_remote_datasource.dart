import 'package:dio/dio.dart';
import '../models/doctor_model.dart';
import '../models/appointment_model.dart';
import '../../../../../../core/constants/api_constants.dart';
import '../../../../../../core/network/api_client.dart';

class AppointmentRemoteDataSource {
  final ApiClient apiClient;

  AppointmentRemoteDataSource({required this.apiClient});

  /// Fetch doctors list with optional state/district filters
  Future<List<DoctorModel>> fetchDoctors({
    String? state,
    String? district,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (state != null && state.isNotEmpty) {
        queryParams['state'] = state;
      }
      if (district != null && district.isNotEmpty) {
        queryParams['district'] = district;
      }

      final response = await apiClient.get(
        ApiConstants.getDoctors,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final doctors = List<DoctorModel>.from(
          (data['doctors'] as List).map((doctor) => DoctorModel.fromJson(doctor)),
        );
        return doctors;
      } else {
        throw Exception('Failed to fetch doctors: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching doctors: $e');
    }
  }

  /// Book an appointment
  Future<AppointmentModel> bookAppointment({
    required String doctorId,
    required DateTime appointmentDateTime,
    required String reasonForVisit,
    String? notes,
    String? patientType, // 'self' or 'family'
  }) async {
    try {
      final requestBody = {
        'doctorId': doctorId,
        'appointmentDateTime': appointmentDateTime.toIso8601String(),
        'reasonForVisit': reasonForVisit,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
        'patientType': ?patientType,
      };

      final response = await apiClient.post(
        ApiConstants.bookAppointment,
        data: requestBody,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data;
        final appointment = AppointmentModel.fromJson(data['appointment']);
        return appointment;
      } else {
        throw Exception('Failed to book appointment: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error booking appointment: $e');
    }
  }

  /// Fetch user's appointments (optional, for future use)
  Future<List<AppointmentModel>> fetchAppointments() async {
    try {
      final response = await apiClient.get(ApiConstants.getAppointments);

      if (response.statusCode == 200) {
        final data = response.data;
        final appointments = List<AppointmentModel>.from(
          (data['appointments'] as List).map((apt) => AppointmentModel.fromJson(apt)),
        );
        return appointments;
      } else {
        throw Exception('Failed to fetch appointments: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching appointments: $e');
    }
  }
}
