import '../datasources/auth_remote_datasource.dart';
import '../models/auth_response_model.dart';
import '../models/auth_user_model.dart';

class AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepository({required this.remoteDataSource});

  Future<AuthResponseModel> signup({
    required String email,
    required String phone,
    required String password,
  }) {
    return remoteDataSource.signup(email: email, phone: phone, password: password);
  }

  Future<AuthResponseModel> verifyOtp({
    required String email,
    required String otp,
  }) {
    return remoteDataSource.verifyOtp(email: email, otp: otp);
  }

  Future<AuthResponseModel> login({
    String? email,
    String? phone,
  }) {
    return remoteDataSource.login(email: email, phone: phone);
  }

  Future<AuthResponseModel> verifyLoginOtp({
    String? email,
    String? phone,
    required String otp,
  }) {
    return remoteDataSource.verifyLoginOtp(email: email, phone: phone, otp: otp);
  }

  Future<AuthUserModel> updateProfile({
    required String firstName,
    required String lastName,
    String? dateOfBirth,
    String? state,
    String? district,
    String? motherName,
    String? fatherName,
    String? height,
    String? weight,
    String? inbornDiseasesAndNotes,
    String? maritalStatus,
    String? bloodGroup,
    String? gender,
  }) {
    return remoteDataSource.updateProfile(
      firstName: firstName,
      lastName: lastName,
      dateOfBirth: dateOfBirth,
      state: state,
      district: district,
      motherName: motherName,
      fatherName: fatherName,
      height: height,
      weight: weight,
      inbornDiseasesAndNotes: inbornDiseasesAndNotes,
      maritalStatus: maritalStatus,
      bloodGroup: bloodGroup,
      gender: gender,
    );
  }

  Future<AuthUserModel> getMe() {
    return remoteDataSource.getMe();
  }
}
