import '../../domain/entities/medical_report_entity.dart';

class MedicalReportModel extends MedicalReportEntity {
  const MedicalReportModel({
    required super.id,
    required super.orderId,
    required super.nurseId,
    required super.conditionNotes,
    required super.createdAt,
    super.patientName,
    super.bloodPressure,
    super.heartRate,
    super.oxygenSaturation,
    super.bodyTemperature,
    super.doctorId,
    super.doctorNotes,
  });

  /// Factory constructor to create a [MedicalReportModel] from a JSON map.
  factory MedicalReportModel.fromJson(Map<String, dynamic> json) {
    return MedicalReportModel(
      id: json['id'] as String? ?? '',
      orderId: json['orderId'] as String? ?? json['order_id'] as String? ?? '',
      nurseId: json['nurseId'] as String? ?? json['nurse_id'] as String? ?? '',
      conditionNotes:
          json['conditionNotes'] as String? ??
          json['condition_notes'] as String? ??
          '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : (json['created_at'] != null
                ? DateTime.parse(json['created_at'] as String)
                : DateTime.now()),
      patientName:
          json['patientName'] as String? ?? json['patient_name'] as String?,
      bloodPressure:
          json['bloodPressure'] as String? ?? json['blood_pressure'] as String?,
      heartRate: (json['heartRate'] ?? json['heart_rate'] as num?)?.toInt(),
      oxygenSaturation:
          (json['oxygenSaturation'] ?? json['oxygen_saturation'] as num?)
              ?.toInt(),
      bodyTemperature:
          (json['bodyTemperature'] ?? json['body_temperature'] as num?)
              ?.toDouble(),
      doctorId: json['doctorId'] as String? ?? json['doctor_id'] as String?,
      doctorNotes:
          json['doctorNotes'] as String? ?? json['doctor_notes'] as String?,
    );
  }

  /// Converts this [MedicalReportModel] instance into a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'nurseId': nurseId,
      'conditionNotes': conditionNotes,
      'createdAt': createdAt.toIso8601String(),
      'patientName': patientName,
      'bloodPressure': bloodPressure,
      'heartRate': heartRate,
      'oxygenSaturation': oxygenSaturation,
      'bodyTemperature': bodyTemperature,
      'doctorId': doctorId,
      'doctorNotes': doctorNotes,
    };
  }

  /// Creates a copy of this [MedicalReportModel] with updated fields.
  MedicalReportModel copyWith({
    String? id,
    String? orderId,
    String? nurseId,
    String? conditionNotes,
    DateTime? createdAt,
    String? patientName,
    String? bloodPressure,
    int? heartRate,
    int? oxygenSaturation,
    double? bodyTemperature,
    String? doctorId,
    String? doctorNotes,
  }) {
    return MedicalReportModel(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      nurseId: nurseId ?? this.nurseId,
      conditionNotes: conditionNotes ?? this.conditionNotes,
      createdAt: createdAt ?? this.createdAt,
      patientName: patientName ?? this.patientName,
      bloodPressure: bloodPressure ?? this.bloodPressure,
      heartRate: heartRate ?? this.heartRate,
      oxygenSaturation: oxygenSaturation ?? this.oxygenSaturation,
      bodyTemperature: bodyTemperature ?? this.bodyTemperature,
      doctorId: doctorId ?? this.doctorId,
      doctorNotes: doctorNotes ?? this.doctorNotes,
    );
  }

  @override
  String toString() {
    return 'MedicalReportModel(id: $id, orderId: $orderId, nurseId: $nurseId, createdAt: $createdAt)';
  }
}
