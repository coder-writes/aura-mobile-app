import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/appointment_model.dart';
import '../../data/repositories/appointment_repository.dart';

part 'appointment_state.dart';

class AppointmentCubit extends Cubit<AppointmentState> {
  final AppointmentRepository repository;
  List<AppointmentModel> _cachedAppointments = [];
  String? _activeUserId;

  AppointmentCubit({required this.repository}) : super(AppointmentInitial());

  String _localHistoryKey(String userId) => 'appointment_history_$userId';

  Future<List<AppointmentModel>> _readLocalAppointments(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_localHistoryKey(userId)) ?? const <String>[];

    return raw
        .map((item) {
          try {
            final parsed = jsonDecode(item);
            if (parsed is Map<String, dynamic>) {
              return AppointmentModel.fromJson(parsed);
            }
          } catch (_) {
            // Ignore malformed rows.
          }
          return null;
        })
        .whereType<AppointmentModel>()
        .toList(growable: false);
  }

  Future<void> _writeLocalAppointments(
    String userId,
    List<AppointmentModel> appointments,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = appointments.map((item) => jsonEncode(item.toJson())).toList(growable: false);
    await prefs.setStringList(_localHistoryKey(userId), payload);
  }

  String? _pickBetterText(String? first, String? second) {
    final normalizedFirst = first?.trim();
    if (normalizedFirst != null && normalizedFirst.isNotEmpty) return normalizedFirst;
    final normalizedSecond = second?.trim();
    if (normalizedSecond != null && normalizedSecond.isNotEmpty) return normalizedSecond;
    return null;
  }

  AppointmentModel _mergeAppointment(AppointmentModel base, AppointmentModel incoming) {
    return base.copyWith(
      doctorName: _pickBetterText(base.doctorName, incoming.doctorName),
      doctorExpertise: _pickBetterText(base.doctorExpertise, incoming.doctorExpertise),
      notes: _pickBetterText(base.notes, incoming.notes),
      patientType: _pickBetterText(base.patientType, incoming.patientType),
      status: _pickBetterText(base.status, incoming.status) ?? base.status,
      reasonForVisit: _pickBetterText(base.reasonForVisit, incoming.reasonForVisit) ?? base.reasonForVisit,
      doctorId: _pickBetterText(base.doctorId, incoming.doctorId) ?? base.doctorId,
      patientId: _pickBetterText(base.patientId, incoming.patientId) ?? base.patientId,
    );
  }

  List<AppointmentModel> _mergeUniqueById(List<AppointmentModel> primary, List<AppointmentModel> secondary) {
    final merged = <AppointmentModel>[];
    final indexById = <String, int>{};

    for (final item in [...primary, ...secondary]) {
      final id = item.id.trim();
      if (id.isEmpty) {
        merged.add(item);
        continue;
      }

      final existingIndex = indexById[id];
      if (existingIndex == null) {
        indexById[id] = merged.length;
        merged.add(item);
      } else {
        final existing = merged[existingIndex];
        merged[existingIndex] = _mergeAppointment(existing, item);
      }
    }

    return merged;
  }

  /// Book an appointment
  Future<void> bookAppointment({
    required String doctorId,
    required DateTime appointmentDateTime,
    String? doctorName,
    String? doctorExpertise,
    required String reasonForVisit,
    String? notes,
    String? patientType,
    String? currentUserId,
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
        (appointment) async {
          final normalizedDoctorName = doctorName?.trim();
          final normalizedDoctorExpertise = doctorExpertise?.trim();

          final enrichedAppointment = appointment.copyWith(
            doctorName: (appointment.doctorName?.trim().isNotEmpty ?? false)
                ? appointment.doctorName
                : (normalizedDoctorName?.isNotEmpty == true ? normalizedDoctorName : null),
            doctorExpertise: (appointment.doctorExpertise?.trim().isNotEmpty ?? false)
                ? appointment.doctorExpertise
                : (normalizedDoctorExpertise?.isNotEmpty == true ? normalizedDoctorExpertise : null),
          );

          final resolvedUserId = (currentUserId != null && currentUserId.trim().isNotEmpty)
              ? currentUserId.trim()
              : enrichedAppointment.patientId.trim();

          _cachedAppointments = _mergeUniqueById([enrichedAppointment], _cachedAppointments);

          if (resolvedUserId.isNotEmpty) {
            final local = await _readLocalAppointments(resolvedUserId);
            final updatedLocal = _mergeUniqueById([enrichedAppointment], local);
            await _writeLocalAppointments(resolvedUserId, updatedLocal);
          }

          emit(AppointmentBooked(appointment: enrichedAppointment));
        },
      );
    } catch (e) {
      emit(AppointmentError('Unexpected error: $e'));
    }
  }

  Future<void> loadAppointments({
    bool forceRefresh = false,
    String? currentUserId,
  }) async {
    final userId = currentUserId?.trim() ?? '';

    if (_activeUserId != userId) {
      _activeUserId = userId;
      _cachedAppointments = [];
    }

    final localAppointments = userId.isEmpty ? const <AppointmentModel>[] : await _readLocalAppointments(userId);

    if (!forceRefresh && _cachedAppointments.isNotEmpty) {
      emit(AppointmentHistoryLoaded(appointments: _cachedAppointments));
      return;
    }

    if (!forceRefresh && localAppointments.isNotEmpty) {
      _cachedAppointments = localAppointments;
      emit(AppointmentHistoryLoaded(appointments: localAppointments));
      return;
    }

    emit(AppointmentHistoryLoading());

    try {
      final result = await repository.getAppointments();
      result.fold(
        (failure) {
          final message = failure.message.toLowerCase();

          if (message.contains('404') || localAppointments.isNotEmpty) {
            _cachedAppointments = localAppointments;
            emit(AppointmentHistoryLoaded(appointments: localAppointments));
            return;
          }

          emit(AppointmentHistoryError(failure.message));
        },
        (appointments) async {
          final merged = _mergeUniqueById(appointments, localAppointments);
          _cachedAppointments = merged;

          if (userId.isNotEmpty) {
            await _writeLocalAppointments(userId, merged);
          }

          emit(AppointmentHistoryLoaded(appointments: merged));
        },
      );
    } catch (e) {
      if (localAppointments.isNotEmpty) {
        _cachedAppointments = localAppointments;
        emit(AppointmentHistoryLoaded(appointments: localAppointments));
        return;
      }
      emit(AppointmentHistoryError('Unexpected error: $e'));
    }
  }

  /// Reset state to initial
  void reset() {
    emit(AppointmentInitial());
  }
}
