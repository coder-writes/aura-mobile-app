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
      'Dec'
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
    };
  }

  /// Create AppointmentModel from JSON
  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['_id'] ?? json['id'] ?? '',
      doctorId: json['doctor'] ?? json['doctorId'] ?? '',
      patientId: json['patient'] ?? json['patientId'] ?? '',
      appointmentDateTime: DateTime.parse(json['appointmentDateTime'] ?? DateTime.now().toIso8601String()),
      reasonForVisit: json['reasonForVisit'] ?? '',
      notes: json['notes'],
      queueNumber: json['queueNumber'] ?? 0,
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      patientType: json['patientType'],
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
    );
  }

  @override
  String toString() =>
      'AppointmentModel(id: $id, doctorId: $doctorId, dateTime: $formattedDate $formattedTime, queue: #$queueNumber)';
}
