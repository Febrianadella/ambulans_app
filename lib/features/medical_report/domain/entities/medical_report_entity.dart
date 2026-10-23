class MedicalReportEntity {
  final String id;
  final String orderId;
  final String nurseId;
  final String conditionNotes;
  final DateTime createdAt;
  final String? patientName;
  final String? bloodPressure;
  final int? heartRate;
  final int? oxygenSaturation;
  final double? bodyTemperature;
  final String? doctorId;
  final String? doctorNotes;

  const MedicalReportEntity({
    required this.id,
    required this.orderId,
    required this.nurseId,
    required this.conditionNotes,
    required this.createdAt,
    this.patientName,
    this.bloodPressure,
    this.heartRate,
    this.oxygenSaturation,
    this.bodyTemperature,
    this.doctorId,
    this.doctorNotes,
  });
}
