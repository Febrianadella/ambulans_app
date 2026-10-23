import 'package:flutter_test/flutter_test.dart';
import 'package:ambulans_app/features/auth/domain/entities/user_entity.dart';
import 'package:ambulans_app/features/auth/data/models/user_model.dart';
import 'package:ambulans_app/features/booking/domain/entities/order_entity.dart';
import 'package:ambulans_app/features/booking/data/models/order_model.dart';
import 'package:ambulans_app/features/booking/data/models/payment_model.dart';
import 'package:ambulans_app/features/medical_report/data/models/medical_report_model.dart';

void main() {
  group('Clean Architecture Data Models Test', () {
    test('UserModel serialization and deserialization (6 Roles)', () {
      final jsonMap = {
        'id': 'USR-123',
        'name': 'Dr. Budi Santoso',
        'email': 'budi@hospital.com',
        'role': 'dokter',
        'phoneNumber': '081234567890',
        'profilePhotoUrl': 'https://example.com/budi.jpg',
      };

      final user = UserModel.fromJson(jsonMap);
      expect(user.id, 'USR-123');
      expect(user.name, 'Dr. Budi Santoso');
      expect(user.email, 'budi@hospital.com');
      expect(user.role, UserRole.dokter);
      expect(user.role.isDokter, isTrue);

      final serialized = user.toJson();
      expect(serialized['id'], 'USR-123');
      expect(serialized['role'], 'dokter');

      // Test all 6 roles
      expect(UserRole.fromString('pengguna'), UserRole.pengguna);
      expect(UserRole.fromString('sopir'), UserRole.sopir);
      expect(UserRole.fromString('admin'), UserRole.admin);
      expect(UserRole.fromString('kepala'), UserRole.kepala);
      expect(UserRole.fromString('perawat'), UserRole.perawat);
      expect(UserRole.fromString('dokter'), UserRole.dokter);
    });

    test('OrderModel serialization and deserialization (All Statuses)', () {
      final now = DateTime(2026, 10, 20, 10, 30);
      final jsonMap = {
        'id': 'ORD-999',
        'userId': 'USR-123',
        'ambulanceId': 'AMB-01',
        'driverId': 'DVR-05',
        'status': 'menujuLokasi',
        'pickupAddress': 'Jl. Sudirman No. 45',
        'destinationAddress': 'RSUP Dr. Sardjito',
        'pickupLatitude': -7.77,
        'pickupLongitude': 110.37,
        'createdAt': now.toIso8601String(),
      };

      final order = OrderModel.fromJson(jsonMap);
      expect(order.id, 'ORD-999');
      expect(order.userId, 'USR-123');
      expect(order.ambulanceId, 'AMB-01');
      expect(order.driverId, 'DVR-05');
      expect(order.status, OrderStatus.menujuLokasi);

      final serialized = order.toJson();
      expect(serialized['status'], 'menujuLokasi');
      expect(serialized['ambulanceId'], 'AMB-01');

      // Test all 6 statuses
      expect(
        OrderStatus.fromString('menungguPembayaran'),
        OrderStatus.menungguPembayaran,
      );
      expect(
        OrderStatus.fromString('menungguValidasi'),
        OrderStatus.menungguValidasi,
      );
      expect(OrderStatus.fromString('menujuLokasi'), OrderStatus.menujuLokasi);
      expect(OrderStatus.fromString('tibaDiLokasi'), OrderStatus.tibaDiLokasi);
      expect(
        OrderStatus.fromString('dalamPerjalanan'),
        OrderStatus.dalamPerjalanan,
      );
      expect(
        OrderStatus.fromString('layananSelesai'),
        OrderStatus.layananSelesai,
      );
    });

    test('PaymentModel serialization and deserialization', () {
      final jsonMap = {
        'id': 'PAY-777',
        'orderId': 'ORD-999',
        'paymentProofUrl': 'https://example.com/proof.jpg',
        'paymentStatus': 'menungguValidasi',
        'amount': 250000.0,
      };

      final payment = PaymentModel.fromJson(jsonMap);
      expect(payment.id, 'PAY-777');
      expect(payment.orderId, 'ORD-999');
      expect(payment.paymentProofUrl, 'https://example.com/proof.jpg');
      expect(payment.paymentStatus, 'menungguValidasi');
      expect(payment.amount, 250000.0);

      final serialized = payment.toJson();
      expect(serialized['id'], 'PAY-777');
      expect(serialized['paymentStatus'], 'menungguValidasi');
    });

    test('MedicalReportModel serialization and deserialization', () {
      final now = DateTime(2026, 10, 20, 10, 45);
      final jsonMap = {
        'id': 'REP-555',
        'orderId': 'ORD-999',
        'nurseId': 'NURSE-02',
        'conditionNotes': 'Tekanan darah tinggi dan pusing mendadak',
        'createdAt': now.toIso8601String(),
        'bloodPressure': '140/90',
        'heartRate': 92,
      };

      final report = MedicalReportModel.fromJson(jsonMap);
      expect(report.id, 'REP-555');
      expect(report.orderId, 'ORD-999');
      expect(report.nurseId, 'NURSE-02');
      expect(report.conditionNotes, 'Tekanan darah tinggi dan pusing mendadak');
      expect(report.bloodPressure, '140/90');
      expect(report.heartRate, 92);

      final serialized = report.toJson();
      expect(serialized['id'], 'REP-555');
      expect(serialized['nurseId'], 'NURSE-02');
    });
  });
}
