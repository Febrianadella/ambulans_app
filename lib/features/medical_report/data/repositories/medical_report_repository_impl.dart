import '../../domain/entities/medical_report_entity.dart';
import '../../domain/repositories/medical_report_repository.dart';
import '../datasources/medical_report_remote_datasource.dart';
import '../models/medical_report_model.dart';

class MedicalReportRepositoryImpl implements MedicalReportRepository {
  final MedicalReportRemoteDataSource remoteDataSource;

  MedicalReportRepositoryImpl({required this.remoteDataSource});

  @override
  Future<MedicalReportEntity> createReport(MedicalReportEntity report) async {
    final model = MedicalReportModel(
      id: report.id,
      orderId: report.orderId,
      nurseId: report.nurseId,
      conditionNotes: report.conditionNotes,
      createdAt: report.createdAt,
      patientName: report.patientName,
      bloodPressure: report.bloodPressure,
      heartRate: report.heartRate,
      oxygenSaturation: report.oxygenSaturation,
      bodyTemperature: report.bodyTemperature,
      doctorId: report.doctorId,
      doctorNotes: report.doctorNotes,
    );
    return await remoteDataSource.createReport(model);
  }

  @override
  Future<MedicalReportEntity?> getReportByOrderId(String orderId) async {
    return await remoteDataSource.getReportByOrderId(orderId);
  }

  @override
  Future<MedicalReportEntity> addDoctorReview({
    required String reportId,
    required String doctorId,
    required String doctorNotes,
  }) async {
    return await remoteDataSource.addDoctorReview(
      reportId: reportId,
      doctorId: doctorId,
      doctorNotes: doctorNotes,
    );
  }
}
