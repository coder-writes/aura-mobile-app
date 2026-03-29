class AppointmentModel {
  final String id;
  final String doctorId;
  final String patientId;
  final DateTime appointmentDateTime;
  final String reasonForVisit;
  final String? notes;
  final int queueNumber;
  final String status;
  final DateTime createdAt;
  final String? patientType; // 'self' or 'family'
  final String? doctorName;
  final String? doctorExpertise;

  AppointmentModel({
    required this.id,
    required this.doctorId,
    required this.patientId,
    required this.appointmentDateTime,
    required this.reasonForVisit,
    this.notes,
    required this.queueNumber,
    required this.status,
    required this.createdAt,
    this.patientType,
    this.doctorName,
    this.doctorExpertise,
  });

  /// Format appointment date for display (e.g., "Oct 12, 2023")
  String get formattedDate {
    return '${_monthName(appointmentDateTime.month)} ${appointmentDateTime.day}, ${appointmentDateTime.year}';
  }

  /// Format appointment time for display (e.g., "09:30 AM")
  String get formattedTime {
    final hour = appointmentDateTime.hour;
    final minute = appointmentDateTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }

  /// Get formatted datetime string suitable for API (ISO 8601)
  String get isoDateTime => appointmentDateTime.toIso8601String();

  /// Helper to get month name
  static String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  /// Convert AppointmentModel to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'doctor': doctorId,
      'patient': patientId,
      'appointmentDateTime': isoDateTime,
      'reasonForVisit': reasonForVisit,
      'notes': notes,
      'queueNumber': queueNumber,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'patientType': patientType,
      'doctorName': doctorName,
      'doctorExpertise': doctorExpertise,
    };
  }

  /// Create AppointmentModel from JSON
  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    final dynamic doctorRaw = json['doctor'];
    final String parsedDoctorId;
    String? parsedDoctorName;
    String? parsedDoctorExpertise;

    if (doctorRaw is Map<String, dynamic>) {
      parsedDoctorId =
          doctorRaw['_id']?.toString() ?? doctorRaw['id']?.toString() ?? '';
      final firstName = doctorRaw['firstName']?.toString() ?? '';
      final lastName = doctorRaw['lastName']?.toString() ?? '';
      final fullName = '$firstName $lastName'.trim();
      parsedDoctorName = fullName.isEmpty ? null : fullName;

      final expertiseRaw = doctorRaw['expertise'];
      if (expertiseRaw is List && expertiseRaw.isNotEmpty) {
        parsedDoctorExpertise = expertiseRaw.first.toString();
      } else if (expertiseRaw != null) {
        parsedDoctorExpertise = expertiseRaw.toString();
      }
    } else {
      parsedDoctorId =
          doctorRaw?.toString() ?? json['doctorId']?.toString() ?? '';
    }

    parsedDoctorName ??= json['doctorName']?.toString();
    parsedDoctorExpertise ??= json['doctorExpertise']?.toString();

    return AppointmentModel(
      id: json['_id'] ?? json['id'] ?? '',
      doctorId: parsedDoctorId,
      patientId: json['patient'] ?? json['patientId'] ?? '',
      appointmentDateTime: DateTime.parse(
        json['appointmentDateTime'] ?? DateTime.now().toIso8601String(),
      ),
      reasonForVisit: json['reasonForVisit'] ?? '',
      notes: json['notes'],
      queueNumber: json['queueNumber'] ?? 0,
      status: json['status'] ?? 'Scheduled',
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      patientType: json['patientType']?.toString(),
      doctorName: parsedDoctorName,
      doctorExpertise: parsedDoctorExpertise,
    );
  }

  /// Create a copy of AppointmentModel
  AppointmentModel copyWith({
    String? id,
    String? doctorId,
    String? patientId,
    DateTime? appointmentDateTime,
    String? reasonForVisit,
    String? notes,
    int? queueNumber,
    String? status,
    DateTime? createdAt,
    String? patientType,
    String? doctorName,
    String? doctorExpertise,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      doctorId: doctorId ?? this.doctorId,
      patientId: patientId ?? this.patientId,
      appointmentDateTime: appointmentDateTime ?? this.appointmentDateTime,
      reasonForVisit: reasonForVisit ?? this.reasonForVisit,
      notes: notes ?? this.notes,
      queueNumber: queueNumber ?? this.queueNumber,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      patientType: patientType ?? this.patientType,
      doctorName: doctorName ?? this.doctorName,
      doctorExpertise: doctorExpertise ?? this.doctorExpertise,
    );
  }

  @override
  String toString() =>
      'AppointmentModel(id: $id, doctorId: $doctorId, dateTime: $formattedDate $formattedTime, queue: #$queueNumber)';
}
