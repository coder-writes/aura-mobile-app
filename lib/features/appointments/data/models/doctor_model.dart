class DoctorModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String expertise;
  final String state;
  final String district;
  final int experience;
  final double consultationFee;
  final String? about;

  DoctorModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.expertise,
    required this.state,
    required this.district,
    required this.experience,
    required this.consultationFee,
    this.about,
  });

  /// Get doctor's full name
  String get fullName => '$firstName $lastName';

  /// Get avatar initials from first and last name
  String get initials {
    final first = firstName.isNotEmpty ? firstName[0] : '';
    final last = lastName.isNotEmpty ? lastName[0] : '';
    return (first + last).toUpperCase();
  }

  /// Get display location
  String get displayLocation => '$district, $state';

  /// Convert DoctorModel to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'expertise': expertise,
      'state': state,
      'district': district,
      'experience': experience,
      'consultationFee': consultationFee,
      'about': about,
    };
  }

  /// Create DoctorModel from JSON
  /// Handles expertise as either string or array from backend
  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    String primaryExpertise = '';
    
    // Backend returns expertise as an array like ["Cardiologist"]
    if (json['expertise'] is List && (json['expertise'] as List).isNotEmpty) {
      primaryExpertise = (json['expertise'] as List).first.toString();
    } else if (json['expertise'] is String) {
      primaryExpertise = json['expertise'] ?? '';
    }
    
    return DoctorModel(
      id: json['_id'] ?? json['id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      expertise: primaryExpertise,
      state: json['state'] ?? '',
      district: json['district'] ?? '',
      experience: json['experience'] ?? 0,
      consultationFee: (json['consultationFee'] ?? 0).toDouble(),
      about: json['about'],
    );
  }

  /// Create a copy of DoctorModel
  DoctorModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? expertise,
    String? state,
    String? district,
    int? experience,
    double? consultationFee,
    String? about,
  }) {
    return DoctorModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      expertise: expertise ?? this.expertise,
      state: state ?? this.state,
      district: district ?? this.district,
      experience: experience ?? this.experience,
      consultationFee: consultationFee ?? this.consultationFee,
      about: about ?? this.about,
    );
  }

  @override
  String toString() =>
      'DoctorModel(id: $id, name: $fullName, expertise: $expertise, state: $state, district: $district)';
}
