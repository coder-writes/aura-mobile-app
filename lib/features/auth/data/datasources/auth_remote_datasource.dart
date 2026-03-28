import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/auth_response_model.dart';
import '../models/auth_user_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> signup({
    required String email,
    required String phone,
    required String password,
  });

  Future<AuthResponseModel> verifyOtp({
    required String email,
    required String otp,
  });

  Future<AuthResponseModel> login({
    String? email,
    String? phone,
  });

  Future<AuthResponseModel> verifyLoginOtp({
    String? email,
    String? phone,
    required String otp,
  });

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
  });

  Future<AuthUserModel> getMe();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<AuthResponseModel> signup({
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final response = await apiClient.post(
        ApiConstants.signup,
        data: {
          'email': email,
          'phone': phone,
          'password': password,
        },
      );

      return AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
    } on AppException catch (error) {
      throw Exception(error.message);
    }
  }

  @override
  Future<AuthResponseModel> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await apiClient.post(
        ApiConstants.verifyOtp,
        data: {
          'email': email,
          'otp': otp,
        },
      );

      return AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
    } on AppException catch (error) {
      throw Exception(error.message);
    }
  }

  @override
  Future<AuthResponseModel> login({
    String? email,
    String? phone,
  }) async {
    try {
      final response = await apiClient.post(
        ApiConstants.login,
        data: {
          if (email != null && email.trim().isNotEmpty) 'email': email,
          if (phone != null && phone.trim().isNotEmpty) 'phone': phone,
        },
      );

      return AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
    } on AppException catch (error) {
      throw Exception(error.message);
    }
  }

  @override
  Future<AuthResponseModel> verifyLoginOtp({
    String? email,
    String? phone,
    required String otp,
  }) async {
    try {
      final response = await apiClient.post(
        ApiConstants.verifyLoginOtp,
        data: {
          if (email != null && email.trim().isNotEmpty) 'email': email,
          if (phone != null && phone.trim().isNotEmpty) 'phone': phone,
          'otp': otp,
        },
      );

      return AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
    } on AppException catch (error) {
      throw Exception(error.message);
    }
  }

  @override
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
  }) async {
    try {
      final response = await apiClient.put(
        ApiConstants.updateProfile,
        data: {
          'firstName': firstName,
          'lastName': lastName,
          if (dateOfBirth != null && dateOfBirth.trim().isNotEmpty) 'dateOfBirth': dateOfBirth,
          if (state != null && state.trim().isNotEmpty) 'state': state,
          if (district != null && district.trim().isNotEmpty) 'district': district,
          if (motherName != null && motherName.trim().isNotEmpty) 'motherName': motherName,
          if (fatherName != null && fatherName.trim().isNotEmpty) 'fatherName': fatherName,
          if (height != null && height.trim().isNotEmpty) 'height': height,
          if (weight != null && weight.trim().isNotEmpty) 'weight': weight,
          if (inbornDiseasesAndNotes != null && inbornDiseasesAndNotes.trim().isNotEmpty)
            'inbornDiseasesAndNotes': inbornDiseasesAndNotes,
          if (maritalStatus != null && maritalStatus.trim().isNotEmpty) 'maritalStatus': maritalStatus,
          if (bloodGroup != null && bloodGroup.trim().isNotEmpty) 'bloodGroup': bloodGroup,
          if (gender != null && gender.trim().isNotEmpty) 'gender': gender,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final profileJson = data['profile'] is Map<String, dynamic>
          ? data['profile'] as Map<String, dynamic>
          : (data['user'] as Map<String, dynamic>? ?? <String, dynamic>{});

      return AuthUserModel.fromJson(profileJson);
    } on AppException catch (error) {
      throw Exception(error.message);
    }
  }

  @override
  Future<AuthUserModel> getMe() async {
    try {
      final response = await apiClient.get(ApiConstants.getMe);
      final data = response.data as Map<String, dynamic>;
      final userJson = data['user'] as Map<String, dynamic>?;

      if (userJson == null) {
        throw Exception('User details missing in /me response');
      }

      return AuthUserModel.fromJson(userJson);
    } on AppException catch (error) {
      throw Exception(error.message);
    }
  }
}
