part of 'doctor_list_cubit.dart';

abstract class DoctorListState {}

class DoctorListInitial extends DoctorListState {}

class DoctorListLoading extends DoctorListState {
  final List<DoctorModel> previousDoctors;

  DoctorListLoading({this.previousDoctors = const []});
}

class DoctorListLoaded extends DoctorListState {
  final List<DoctorModel> doctors;
  final List<DoctorModel> allDoctors; // Store all doctors for filtering
  final String? selectedSpecialty;

  DoctorListLoaded({
    required this.doctors,
    List<DoctorModel>? allDoctors,
    this.selectedSpecialty,
  }) : allDoctors = allDoctors ?? doctors;

  /// Get unique specialties from doctors list
  List<String> getUniqueSpecialties() {
    final specialties = <String>{};
    for (final doctor in allDoctors) {
      specialties.add(doctor.expertise);
    }
    return specialties.toList()..sort();
  }

  @override
  String toString() =>
      'DoctorListLoaded(count: ${doctors.length}, specialty: $selectedSpecialty)';
}

class DoctorListError extends DoctorListState {
  final String message;

  DoctorListError(this.message);

  @override
  String toString() => 'DoctorListError($message)';
}
