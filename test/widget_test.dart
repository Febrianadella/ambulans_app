import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:ambulans_app/core/utils/date_formatter.dart';
import 'package:ambulans_app/features/chat/presentation/pages/chat_room_page.dart';
import 'package:ambulans_app/main.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  testWidgets('AmbulanceBookingApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AmbulanceBookingApp());
    expect(find.text('Ambulance System'), findsOneWidget);
  });

  testWidgets('ChatRoomPage widget and message sending interaction test', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ChatRoomPage(orderId: 'ORD-1001'),
      ),
    );
    await tester.pumpAndSettle();

    // Pastikan judul chat room dan pesan default tim ambulans tampil
    expect(find.text('Chat Tim Ambulans #ORD-1001'), findsOneWidget);
    expect(
      find.text('Halo, kami sedang menuju lokasi Anda dengan sirene aktif.'),
      findsOneWidget,
    );
    expect(
      find.text('Baik pak, kami menunggu di depan gerbang utama rumah.'),
      findsOneWidget,
    );

    // Temukan field input chat dan tombol kirim
    final inputFinder = find.byType(TextField);
    final sendButtonFinder = find.byTooltip('Kirim pesan');
    expect(inputFinder, findsOneWidget);
    expect(sendButtonFinder, findsOneWidget);

    // Ketik pesan baru lalu kirim
    const testMessage = 'Ambulans sudah dekat gerbang utama ya';
    await tester.enterText(inputFinder, testMessage);
    await tester.tap(sendButtonFinder);
    await tester.pumpAndSettle();

    // Verifikasi pesan baru berhasil terkirim dan muncul di tampilan chat
    expect(find.text(testMessage), findsOneWidget);
  });

  test('DateFormatter formatting tests with and without locale', () {
    final testDate = DateTime(2026, 10, 25, 14, 30);

    // formatTime murni angka HH:mm tanpa ketergantungan locale
    expect(DateFormatter.formatTime(testDate), '14:30');

    // formatFull & formatDate menggunakan locale id_ID
    expect(DateFormatter.formatDate(testDate), contains('2026'));
    expect(DateFormatter.formatFull(testDate), contains('14:30'));

    // formatCurrency format rupiah
    expect(DateFormatter.formatCurrency(150000), contains('Rp'));
  });
}
