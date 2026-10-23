import '../entities/medical_report_entity.dart';

abstract class MedicalReportRepository {
  Future<MedicalReportEntity> createReport(MedicalReportEntity report);
  Future<MedicalReportEntity?> getReportByOrderId(String orderId);
  Future<MedicalReportEntity> addDoctorReview({
    required String reportId,
    required String doctorId,
    required String doctorNotes,
  });
}
