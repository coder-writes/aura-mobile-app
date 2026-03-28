import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/doctor_model.dart';
import '../../data/repositories/appointment_repository.dart';

part 'doctor_list_state.dart';

class DoctorListCubit extends Cubit<DoctorListState> {
  final AppointmentRepository repository;

  DoctorListCubit({required this.repository}) : super(DoctorListInitial());

  /// Fetch doctors filtered by state and/or district
  Future<void> fetchDoctors({
    String? state,
    String? district,
  }) async {
    final previousDoctors =
        this.state is DoctorListLoaded ? (this.state as DoctorListLoaded).doctors : <DoctorModel>[];
    emit(DoctorListLoading(previousDoctors: previousDoctors));

    try {
      final result = await repository.getDoctors(state: state, district: district);

      result.fold(
        (failure) {
          emit(DoctorListError(failure.message));
        },
        (doctors) {
          emit(DoctorListLoaded(doctors: doctors));
        },
      );
    } catch (e) {
      emit(DoctorListError('Unexpected error: $e'));
    }
  }

  /// Filter loaded doctors by expertise/specialty
  void filterBySpecialty(String specialty) {
    if (state is DoctorListLoaded) {
      final currentState = state as DoctorListLoaded;
      final filtered = currentState.doctors
          .where((doctor) =>
              doctor.expertise.toLowerCase() == specialty.toLowerCase())
          .toList();

      emit(DoctorListLoaded(
        doctors: filtered,
        selectedSpecialty: specialty,
      ));
    }
  }

  /// Reset to show all doctors
  void resetFilter() {
    if (state is DoctorListLoaded) {
      final currentState = state as DoctorListLoaded;
      emit(DoctorListLoaded(doctors: currentState.allDoctors));
    }
  }
}
