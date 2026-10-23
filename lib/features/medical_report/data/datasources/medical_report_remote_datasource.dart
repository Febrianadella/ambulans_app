import '../models/medical_report_model.dart';

abstract class MedicalReportRemoteDataSource {
  Future<MedicalReportModel> createReport(MedicalReportModel report);
  Future<MedicalReportModel?> getReportByOrderId(String orderId);
  Future<MedicalReportModel> addDoctorReview({
    required String reportId,
    required String doctorId,
    required String doctorNotes,
  });
}

class MedicalReportRemoteDataSourceImpl
    implements MedicalReportRemoteDataSource {
  @override
  Future<MedicalReportModel> createReport(MedicalReportModel report) async {
    return report;
  }

  @override
  Future<MedicalReportModel?> getReportByOrderId(String orderId) async {
    return MedicalReportModel(
      id: 'REP-001',
      orderId: orderId,
      nurseId: 'NURSE-01',
      conditionNotes:
          'Pasien sadar, mengalami sesak napas ringan pasca trauma.',
      createdAt: DateTime.now(),
      patientName: 'Ahmad Fauzi',
      bloodPressure: '120/80',
      heartRate: 85,
      oxygenSaturation: 98,
      bodyTemperature: 36.8,
    );
  }

  @override
  Future<MedicalReportModel> addDoctorReview({
    required String reportId,
    required String doctorId,
    required String doctorNotes,
  }) async {
    return MedicalReportModel(
      id: reportId,
      orderId: 'ORD-001',
      nurseId: 'NURSE-01',
      conditionNotes: 'Pasien stabil.',
      createdAt: DateTime.now(),
      doctorId: doctorId,
      doctorNotes: doctorNotes,
    );
  }
}
