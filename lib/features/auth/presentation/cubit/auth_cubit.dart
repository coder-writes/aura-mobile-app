import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../data/models/auth_user_model.dart';
import '../../data/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;
  final FlutterSecureStorage secureStorage;

  AuthCubit({
    required this.authRepository,
    required this.secureStorage,
  }) : super(AuthInitial());

  static const _authTokenKey = 'auth_token';
  static const _authEmailKey = 'auth_email';
  static const _authPhoneKey = 'auth_phone';
  static const _authUserIdKey = 'auth_user_id';
  static const _firstNameKey = 'first_name';
  static const _lastNameKey = 'last_name';
  static const _bloodGroupKey = 'blood_group';
  static const _genderKey = 'gender';
  static const _dateOfBirthKey = 'date_of_birth';
  static const _stateKey = 'state';
  static const _districtKey = 'district';
  static const _isProfileCompleteKey = 'is_profile_complete';

  Future<void> checkAuth() async {
    emit(AuthLoading());

    final token = await secureStorage.read(key: _authTokenKey);
    final email = await secureStorage.read(key: _authEmailKey);
    final phone = await secureStorage.read(key: _authPhoneKey);
    final userId = await secureStorage.read(key: _authUserIdKey);
    final firstName = await secureStorage.read(key: _firstNameKey);
    final lastName = await secureStorage.read(key: _lastNameKey);
    final bloodGroup = await secureStorage.read(key: _bloodGroupKey);
    final gender = await secureStorage.read(key: _genderKey);
    final dateOfBirth = await secureStorage.read(key: _dateOfBirthKey);
    final stateName = await secureStorage.read(key: _stateKey);
    final district = await secureStorage.read(key: _districtKey);
    final isProfileComplete =
      (await secureStorage.read(key: _isProfileCompleteKey)) == 'true';

    if (token != null && token.isNotEmpty) {
      try {
        final freshUser = await authRepository.getMe();
        await _persistUser(freshUser);
        emit(
          AuthAuthenticated(
            user: freshUser,
            token: token,
            message: 'Welcome back',
          ),
        );
        return;
      } catch (_) {
        // Fallback to cached user details if /me fails
      }
    }

    if (token != null && email != null && phone != null && userId != null) {
      emit(
        AuthAuthenticated(
          user: AuthUserModel(
            id: userId,
            email: email,
            phone: phone,
            isVerified: true,
            firstName: firstName,
            lastName: lastName,
            bloodGroup: bloodGroup,
            gender: gender,
            dateOfBirth: dateOfBirth,
            state: stateName,
            district: district,
            isProfileComplete: isProfileComplete,
          ),
          token: token,
          message: 'Welcome back',
        ),
      );
      return;
    }

    emit(AuthUnauthenticated());
  }

  Future<void> signup({required String email, required String phone, required String password}) async {
    emit(AuthLoading());
    try {
      final response = await authRepository.signup(
        email: email,
        phone: phone,
        password: password,
      );

      if (!response.success) {
        emit(AuthError(response.message));
        return;
      }

      emit(AuthOtpSent(email: email, message: response.message));
    } catch (error) {
      emit(AuthError(error.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> verifyOtp({required String email, required String otp}) async {
    emit(AuthLoading());
    try {
      final response = await authRepository.verifyOtp(email: email, otp: otp);

      if (!response.success || response.token == null || response.user == null) {
        emit(AuthError(response.message.isEmpty ? 'OTP verification failed' : response.message));
        return;
      }

      await secureStorage.write(key: _authTokenKey, value: response.token);
      await _persistUser(response.user!);

      emit(
        AuthAuthenticated(
          user: response.user!,
          token: response.token!,
          message: response.message,
        ),
      );
    } catch (error) {
      emit(AuthError(error.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> login({String? email, String? phone}) async {
    emit(AuthLoading());
    try {
      final response = await authRepository.login(email: email, phone: phone);

      if (!response.success) {
        emit(AuthError(response.message));
        return;
      }

      emit(
        AuthLoginOtpSent(
          message: response.message,
          email: email,
          phone: phone,
        ),
      );
    } catch (error) {
      emit(AuthError(error.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> verifyLoginOtp({String? email, String? phone, required String otp}) async {
    emit(AuthLoading());
    try {
      final response = await authRepository.verifyLoginOtp(email: email, phone: phone, otp: otp);

      if (!response.success || response.token == null || response.user == null) {
        emit(AuthError(response.message.isEmpty ? 'OTP verification failed' : response.message));
        return;
      }

      await secureStorage.write(key: _authTokenKey, value: response.token);
      await _persistUser(response.user!);

      emit(
        AuthAuthenticated(
          user: response.user!,
          token: response.token!,
          message: response.message,
        ),
      );
    } catch (error) {
      emit(AuthError(error.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> logout() async {
    await secureStorage.deleteAll();
    emit(AuthUnauthenticated());
  }

  Future<void> updateProfile({
    required String firstName,
    required String lastName,
    String? dateOfBirth,
    String? stateName,
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
    final currentState = state;
    if (currentState is! AuthAuthenticated) {
      emit(const AuthError('Please login again to update profile'));
      return;
    }
    final authenticatedState = currentState;

    emit(AuthLoading());
    try {
      final updatedUser = await authRepository.updateProfile(
        firstName: firstName,
        lastName: lastName,
        dateOfBirth: dateOfBirth,
        state: stateName,
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

      await _persistUser(updatedUser);

      emit(
        AuthAuthenticated(
          user: updatedUser,
          token: authenticatedState.token,
          message: 'Profile updated successfully',
        ),
      );
    } catch (error) {
      emit(AuthError(error.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _persistUser(AuthUserModel user) async {
    await secureStorage.write(key: _authEmailKey, value: user.email);
    await secureStorage.write(key: _authPhoneKey, value: user.phone);
    await secureStorage.write(key: _authUserIdKey, value: user.id);
    await secureStorage.write(key: _firstNameKey, value: user.firstName ?? '');
    await secureStorage.write(key: _lastNameKey, value: user.lastName ?? '');
    await secureStorage.write(key: _bloodGroupKey, value: user.bloodGroup ?? '');
    await secureStorage.write(key: _genderKey, value: user.gender ?? '');
    await secureStorage.write(key: _dateOfBirthKey, value: user.dateOfBirth ?? '');
    await secureStorage.write(key: _stateKey, value: user.state ?? '');
    await secureStorage.write(key: _districtKey, value: user.district ?? '');
    await secureStorage.write(
      key: _isProfileCompleteKey,
      value: user.isProfileComplete ? 'true' : 'false',
    );
  }

  void resetState() {
    emit(AuthUnauthenticated());
  }
}
