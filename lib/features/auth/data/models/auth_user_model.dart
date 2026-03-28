class AuthUserModel {
  final String id;
  final String email;
  final String phone;
  final bool isVerified;
  final String? firstName;
  final String? lastName;
  final String? dateOfBirth;
  final String? state;
  final String? district;
  final String? motherName;
  final String? fatherName;
  final String? height;
  final String? weight;
  final String? inbornDiseasesAndNotes;
  final String? bloodGroup;
  final String? gender;
  final String? maritalStatus;
  final bool isProfileComplete;

  const AuthUserModel({
    required this.id,
    required this.email,
    required this.phone,
    required this.isVerified,
    this.firstName,
    this.lastName,
    this.dateOfBirth,
    this.state,
    this.district,
    this.motherName,
    this.fatherName,
    this.height,
    this.weight,
    this.inbornDiseasesAndNotes,
    this.bloodGroup,
    this.gender,
    this.maritalStatus,
    this.isProfileComplete = false,
  });

  String get fullName {
    final fn = (firstName ?? '').trim();
    final ln = (lastName ?? '').trim();
    final joined = '$fn $ln'.trim();
    return joined.isEmpty ? email : joined;
  }

  String get initials {
    final fn = (firstName ?? '').trim();
    final ln = (lastName ?? '').trim();
    if (fn.isEmpty && ln.isEmpty) {
      return email.isNotEmpty ? email.substring(0, 1).toUpperCase() : 'AU';
    }
    final first = fn.isNotEmpty ? fn.substring(0, 1) : '';
    final second = ln.isNotEmpty ? ln.substring(0, 1) : '';
    return (first + second).toUpperCase();
  }

  int? get age {
    if (dateOfBirth == null || dateOfBirth!.trim().isEmpty) return null;
    final dob = DateTime.tryParse(dateOfBirth!);
    if (dob == null) return null;
    final now = DateTime.now();
    var years = now.year - dob.year;
    final hasBirthdayPassed =
        now.month > dob.month || (now.month == dob.month && now.day >= dob.day);
    if (!hasBirthdayPassed) years--;
    return years >= 0 ? years : null;
  }

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    String? normalize(dynamic value) {
      if (value == null) return null;
      final text = value.toString().trim();
      return text.isEmpty ? null : text;
    }

    return AuthUserModel(
      id: (json['_id'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      isVerified: (json['isVerified'] ?? false) as bool,
      firstName: normalize(json['firstName']),
      lastName: normalize(json['lastName']),
      dateOfBirth: normalize(json['dateOfBirth']),
      state: normalize(json['state']),
      district: normalize(json['district']),
      motherName: normalize(json['motherName']),
      fatherName: normalize(json['fatherName']),
      height: normalize(json['height']),
      weight: normalize(json['weight']),
      inbornDiseasesAndNotes: normalize(json['inbornDiseasesAndNotes']),
      bloodGroup: normalize(json['bloodGroup']),
      gender: normalize(json['gender']),
      maritalStatus: normalize(json['maritalStatus']),
      isProfileComplete: (json['isProfileComplete'] ?? false) as bool,
    );
  }
}
