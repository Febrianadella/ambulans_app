import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ambulans_app/main.dart';
import 'package:ambulans_app/features/auth/domain/entities/user_entity.dart';

void main() {
  group('6 Actor Dashboards Navigation Smoke Test', () {
    testWidgets('Renders and switches across all 6 actor dashboards smoothly', (
      WidgetTester tester,
    ) async {
      // Set test screen size large enough for desktop & mobile components
      tester.view.physicalSize = const Size(1400, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(const AmbulanceBookingApp());
      await tester.pumpAndSettle();

      // 1. Initial should be Pengguna Dashboard
      expect(find.text('Butuh Ambulans?'), findsOneWidget);
      expect(find.text('Budi Pratama'), findsOneWidget);

      // 2. Switch to Sopir
      await tester.ensureVisible(find.text(UserRole.sopir.label));
      await tester.tap(find.text(UserRole.sopir.label));
      await tester.pumpAndSettle();
      expect(find.text('Joko Susilo'), findsOneWidget);
      expect(find.text('Status Kesiapan Sopir'), findsOneWidget);

      // 3. Switch to Admin
      await tester.ensureVisible(find.text(UserRole.admin.label));
      await tester.tap(find.text(UserRole.admin.label));
      await tester.pumpAndSettle();
      expect(find.text('Dashboard Administrator'), findsOneWidget);
      expect(find.text('Pesanan Perlu Ditindaklanjuti'), findsOneWidget);

      // 4. Switch to Kepala
      await tester.tap(find.text(UserRole.kepala.label));
      await tester.pumpAndSettle();
      expect(find.text('Dashboard Kepala Ambulans'), findsOneWidget);
      expect(find.text('Tren Jumlah Layanan Mingguan'), findsOneWidget);

      // 5. Switch to Perawat
      await tester.ensureVisible(find.text(UserRole.perawat.label));
      await tester.tap(find.text(UserRole.perawat.label));
      await tester.pumpAndSettle();
      expect(find.text('Ns. Sarah Amelia, S.Kep'), findsOneWidget);
      expect(find.text('Buat Laporan Pasien'), findsOneWidget);

      // 6. Switch to Dokter
      await tester.ensureVisible(find.text(UserRole.dokter.label));
      await tester.tap(find.text(UserRole.dokter.label));
      await tester.pumpAndSettle();
      expect(find.text('dr. Farhan Malik, Sp.An'), findsOneWidget);
      expect(find.text('Status Notifikasi Otomatis Dokter'), findsOneWidget);
    });
  });
}
