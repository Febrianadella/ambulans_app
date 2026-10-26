import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:ambulans_app/features/booking/presentation/pages/order_detail_page.dart';
import 'package:ambulans_app/features/chat/presentation/pages/chat_room_page.dart';
import 'package:ambulans_app/features/dashboard/presentation/pages/pengguna_dashboard_page.dart';
import 'package:ambulans_app/features/dashboard/presentation/pages/sopir_dashboard_page.dart';
import 'package:ambulans_app/main.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  group('Ambulance App - Riwayat Pesanan & Tracking Tests', () {
    testWidgets('1. Bottom Navigation has 4 items and removes Pesanan', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: PenggunaDashboardPage(),
        ),
      );
      await tester.pumpAndSettle();

      // Memastikan 4 menu navigasi ada
      expect(find.text('Beranda'), findsOneWidget);
      expect(find.text('Riwayat'), findsOneWidget);
      expect(find.text('Chat'), findsOneWidget);
      expect(find.text('Profil'), findsOneWidget);

      // Memastikan menu "Pesanan" TIDAK ADA di bottom navigation
      final bottomNavFinder = find.byType(BottomNavigationBar);
      expect(bottomNavFinder, findsOneWidget);
      final BottomNavigationBar bottomNav = tester.widget(bottomNavFinder);
      expect(bottomNav.items.length, 4);

      final itemLabels = bottomNav.items.map((i) => i.label).toList();
      expect(itemLabels, contains('Beranda'));
      expect(itemLabels, contains('Riwayat'));
      expect(itemLabels, contains('Chat'));
      expect(itemLabels, contains('Profil'));
      expect(itemLabels.contains('Pesanan'), isFalse);
    });

    testWidgets('2. Riwayat Pesanan page renders header, filter tabs, and order cards', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(400, 850);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: PenggunaDashboardPage(),
        ),
      );
      await tester.pumpAndSettle();

      // Beralih ke tab Riwayat (Index 1)
      await tester.tap(find.text('Riwayat'));
      await tester.pumpAndSettle();

      // Header Riwayat Pesanan
      expect(find.text('Riwayat Pesanan'), findsOneWidget);

      // Tiga tab filter
      expect(find.text('Semua'), findsOneWidget);
      expect(find.text('Berlangsung'), findsOneWidget);
      expect(find.text('Selesai'), findsOneWidget);

      // Verifikasi card riwayat tampil
      expect(find.text('#ORD-20261023-01'), findsOneWidget);
      expect(find.text('#AMB-2026-0087'), findsOneWidget);
      expect(find.text('Lihat Detail'), findsWidgets);

      // Uji filter "Berlangsung"
      await tester.tap(find.text('Berlangsung'));
      await tester.pumpAndSettle();
      expect(find.text('#ORD-20261023-01'), findsOneWidget);
      expect(find.text('#AMB-2026-0087'), findsNothing);

      // Uji filter "Selesai"
      await tester.tap(find.text('Selesai'));
      await tester.pumpAndSettle();
      expect(find.text('#AMB-2026-0087'), findsOneWidget);
      expect(find.text('#ORD-20261023-01'), findsNothing);

      // Kembali ke filter "Semua"
      await tester.tap(find.text('Semua'));
      await tester.pumpAndSettle();
      expect(find.text('#ORD-20261023-01'), findsOneWidget);
      expect(find.text('#AMB-2026-0087'), findsOneWidget);
    });

    testWidgets('3. Clicking order card navigates to OrderDetailPage with accurate info and NO placeholder', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: PenggunaDashboardPage(),
        ),
      );
      await tester.pumpAndSettle();

      // Masuk ke tab Riwayat
      await tester.tap(find.text('Riwayat'));
      await tester.pumpAndSettle();

      // Klik card pesanan ORD-20261023-01
      await tester.tap(find.text('#ORD-20261023-01'));
      await tester.pumpAndSettle();

      // Verifikasi halaman Detail Pesanan terbuka
      expect(find.widgetWithText(AppBar, 'Detail Pesanan'), findsOneWidget);
      expect(find.text('#ORD-20261023-01'), findsWidgets);

      // Verifikasi Informasi Pesanan
      expect(find.text('Informasi Pesanan'), findsOneWidget);
      expect(find.text('Lokasi Penjemputan'), findsWidgets);
      expect(find.text('Rumah Sakit Tujuan'), findsWidgets);
      expect(find.text('Rp 250.000'), findsWidgets);

      // Memastikan TIDAK ADA tulisan "Jadwal Layanan"
      expect(find.text('Jadwal Layanan'), findsNothing);

      // Verifikasi Bagian Tracking Ambulans
      expect(find.text('Tracking Ambulans'), findsOneWidget);

      // CRITICAL REQUIREMENT: Bebas kata "Placeholder"
      expect(find.textContaining('Placeholder'), findsNothing);
      expect(find.textContaining('placeholder'), findsNothing);

      // Verifikasi Bagian Ambulans dan Sopir
      expect(find.text('Ambulans dan Sopir'), findsOneWidget);
      expect(find.text('Joko Susilo'), findsOneWidget);
      expect(find.textContaining('AB 1199 MED'), findsWidgets);
      expect(find.text('Chat dengan Sopir'), findsOneWidget);
    });

    testWidgets('4. "Chat dengan Sopir" button navigates to ChatRoomPage with driver identity', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: OrderDetailPage(orderId: 'ORD-20261023-01'),
        ),
      );
      await tester.pumpAndSettle();

      // Klik tombol "Chat dengan Sopir"
      final chatBtnFinder = find.widgetWithText(ElevatedButton, 'Chat dengan Sopir');
      expect(chatBtnFinder, findsOneWidget);
      await tester.tap(chatBtnFinder);
      await tester.pumpAndSettle();

      // Verifikasi ChatRoomPage terbuka dengan header nama sopir
      expect(find.byType(ChatRoomPage), findsOneWidget);
      expect(find.text('Joko Susilo'), findsOneWidget);
      expect(find.textContaining('AB 1199 MED'), findsOneWidget);

      // Kembali ke halaman detail pesanan
      final backBtnFinder = find.byType(BackButton);
      if (backBtnFinder.evaluate().isNotEmpty) {
        await tester.tap(backBtnFinder);
      } else {
        await tester.tap(find.byIcon(Icons.arrow_back));
      }
      await tester.pumpAndSettle();

      // Memastikan kembali ke detail pesanan dengan status tetap ada
      expect(find.text('Detail Pesanan'), findsOneWidget);
      expect(find.text('#ORD-20261023-01'), findsWidgets);
    });

    testWidgets('5. Sopir dashboard status change synchronizes with Pengguna Dashboard & Riwayat', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      // Render aplikasi utama
      await tester.pumpWidget(const AmbulanceBookingApp());
      await tester.pumpAndSettle();

      // Awalnya di Pengguna Dashboard, status adalah "Menuju Lokasi Penjemputan"
      expect(find.text('Menuju Lokasi Penjemputan'), findsWidgets);

      // Beralih ke peran Sopir melalui role switcher
      await tester.tap(find.text('Sopir Ambulans'));
      await tester.pumpAndSettle();
      expect(find.byType(SopirDashboardPage), findsOneWidget);

      // Sopir mengklik tombol "Perbarui Status Perjalanan" -> Maju ke "Tiba di lokasi penjemputan"
      final advanceButton = find.widgetWithText(ElevatedButton, 'Konfirmasi: Tiba di Penjemputan');
      expect(advanceButton, findsOneWidget);
      await tester.tap(advanceButton);
      await tester.pumpAndSettle();

      // Beralih kembali ke Pengguna
      await tester.tap(find.text('Pengguna'));
      await tester.pumpAndSettle();

      // Verifikasi status pada pesanan aktif pengguna telah berubah menjadi "Pasien Dijemput"
      expect(find.text('Pasien Dijemput'), findsWidgets);

      // Buka tab Riwayat
      await tester.tap(find.text('Riwayat').last, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Verifikasi pada card Riwayat juga berstatus "Pasien Dijemput"
      expect(find.text('Pasien Dijemput'), findsWidgets);
    });

    testWidgets('6. Responsive check on desktop and mobile', (WidgetTester tester) async {
      // Mobile
      tester.view.physicalSize = const Size(360, 740);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(
        const MaterialApp(
          home: OrderDetailPage(orderId: 'ORD-20261023-01'),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Desktop
      tester.view.physicalSize = const Size(1280, 800);
      await tester.pumpWidget(
        const MaterialApp(
          home: OrderDetailPage(orderId: 'ORD-20261023-01'),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
