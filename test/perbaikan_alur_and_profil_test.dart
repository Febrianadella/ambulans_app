import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:ambulans_app/features/booking/data/datasources/booking_remote_datasource.dart';
import 'package:ambulans_app/features/booking/data/repositories/booking_repository_impl.dart';
import 'package:ambulans_app/features/booking/presentation/pages/order_confirmation_page.dart';
import 'package:ambulans_app/features/booking/presentation/pages/order_detail_page.dart';
import 'package:ambulans_app/features/chat/presentation/pages/chat_room_page.dart';
import 'package:ambulans_app/features/dashboard/presentation/pages/pengguna_dashboard_page.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  group('Perbaikan Sistem Layanan Ambulans - Verification Tests', () {
    testWidgets(
      '1. OrderDetailPage removes "Ambulans dan Sopir — Belum Ditugaskan" completely when driver is not assigned',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(500, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        // ORD-20261023-04 memiliki status menungguValidasi sehingga _isDriverAssigned == false
        await tester.pumpWidget(
          const MaterialApp(
            home: OrderDetailPage(orderId: 'ORD-20261023-04'),
          ),
        );
        await tester.pumpAndSettle();

        // 1. Verifikasi TIDAK ADA card/informasi "Sopir belum ditugaskan"
        expect(find.textContaining('Sopir belum ditugaskan'), findsNothing);
        expect(find.textContaining('Sopir akan ditugaskan'), findsNothing);
        expect(find.textContaining('oleh administrator'), findsNothing);
        expect(find.textContaining('Chat dengan Sopir (Belum Tersedia)'), findsNothing);
        expect(find.text('Ambulans dan Sopir'), findsNothing);
      },
    );

    testWidgets(
      '2. Status Pesanan dan Status Pembayaran tidak ganda "Menunggu Validasi"',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(500, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          const MaterialApp(
            home: PenggunaDashboardPage(),
          ),
        );
        await tester.pumpAndSettle();

        // Pindah ke tab Riwayat
        await tester.tap(find.text('Riwayat'));
        await tester.pumpAndSettle();

        // Verifikasi bahwa teks "Menunggu Konfirmasi" digunakan untuk tahap layanan ambulans
        expect(find.text('Menunggu Konfirmasi'), findsWidgets);
      },
    );

    testWidgets(
      '3. OrderConfirmationPage dan OrderDetailPage bebas dari Jenis Layanan Emergency Card',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(500, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final repo = BookingRepositoryImpl(remoteDataSource: BookingRemoteDataSourceImpl());

        // Halaman Konfirmasi Pesanan
        await tester.pumpWidget(
          MaterialApp(
            home: OrderConfirmationPage(
              userId: 'USR-20261023-01',
              pickupAddress: 'Jl. Malioboro No. 12',
              destinationAddress: 'RSUP Dr. Sardjito',
              pickupLatitude: -7.7928,
              pickupLongitude: 110.3658,
              patientName: 'Budi Pratama',
              patientGender: 'Laki-laki',
              patientAge: 30,
              patientPhoneNumber: '081234567890',
              repository: repo,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verifikasi TIDAK ADA card "Jenis Layanan" di Konfirmasi
        expect(find.text('Jenis Layanan'), findsNothing);
        expect(find.text('Ambulans Gawat Darurat (Emergency)'), findsNothing);

        // Halaman Detail Pesanan
        await tester.pumpWidget(
          const MaterialApp(
            home: OrderDetailPage(orderId: 'ORD-20261023-01'),
          ),
        );
        await tester.pumpAndSettle();

        // Verifikasi TIDAK ADA baris "Layanan Ambulans"
        expect(find.text('Layanan Ambulans'), findsNothing);
      },
    );

    testWidgets(
      '4. Hapus Fitur Call Center dari Tampilan Chat Pengguna',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(500, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          const MaterialApp(
            home: PenggunaDashboardPage(),
          ),
        );
        await tester.pumpAndSettle();

        // Pindah ke tab Chat
        await tester.tap(find.text('Chat'));
        await tester.pumpAndSettle();

        // Verifikasi TIDAK ADA Call Center Darurat 119
        expect(find.textContaining('Call Center'), findsNothing);
        expect(find.textContaining('Call Center Darurat'), findsNothing);

        // Tetapi card chat dengan sopir tetap ada
        expect(find.textContaining('Joko Susilo'), findsOneWidget);
        expect(find.text('Chat & Komunikasi'), findsOneWidget);
      },
    );

    testWidgets(
      '5. Chat Pengguna dan Sopir tidak berisi pesan Administrator',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(500, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          const MaterialApp(
            home: ChatRoomPage(
              orderId: 'ORD-20261023-01',
              driverName: 'Joko Susilo',
              driverPlate: 'AB 1199 MED',
              isFromDriver: false,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verifikasi pesan Administrator tidak ada sama sekali
        expect(find.text('Administrator'), findsNothing);
        expect(find.textContaining('Admin'), findsNothing);

        // Kirim pesan dari pengguna
        final textInput = find.byType(TextField);
        await tester.enterText(textInput, 'Halo Pak Joko, kami menunggu di depan.');
        await tester.tap(find.byIcon(Icons.send));
        await tester.pumpAndSettle();

        expect(find.text('Halo Pak Joko, kami menunggu di depan.'), findsOneWidget);
      },
    );

    testWidgets(
      '5B. Chat dari Sopir ke Pengguna menampilkan identitas pasien dan pesan sopir',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(500, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          const MaterialApp(
            home: ChatRoomPage(
              orderId: 'ORD-20261023-01',
              driverName: 'Joko Susilo',
              driverPlate: 'AB 1199 MED',
              isFromDriver: true,
              patientName: 'Budi Pratama',
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Header menampilkan nama pasien
        expect(find.text('Budi Pratama'), findsOneWidget);
        expect(find.text('Administrator'), findsNothing);

        // Kirim pesan dari sopir
        final textInput = find.byType(TextField);
        await tester.enterText(textInput, 'Saya sudah hampir sampai gerbang.');
        await tester.tap(find.byIcon(Icons.send));
        await tester.pumpAndSettle();

        expect(find.text('Saya sudah hampir sampai gerbang.'), findsOneWidget);
      },
    );

    testWidgets(
      '6. Tampilan Profil Pengguna sesuai referensi dan dapat disimpan secara dinamis',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(500, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          const MaterialApp(
            home: PenggunaDashboardPage(),
          ),
        );
        await tester.pumpAndSettle();

        // Pindah ke tab Profil
        await tester.tap(find.text('Profil'));
        await tester.pumpAndSettle();

        // A. Header
        expect(find.text('Edit Profil'), findsOneWidget);
        expect(find.text('Perbarui data akun Anda'), findsOneWidget);

        // B. Foto Profil & inisial
        expect(find.byIcon(Icons.camera_alt_rounded), findsOneWidget);
        expect(find.textContaining('Foto profil berupa inisial'), findsOneWidget);

        // C. Form Input
        expect(find.text('Nama Lengkap *'), findsOneWidget);
        expect(find.text('Nomor Telepon *'), findsOneWidget);
        expect(find.text('Alamat Utama'), findsOneWidget);
        expect(find.textContaining('Digunakan sebagai saran lokasi penjemputan'), findsOneWidget);

        // D. Tombol Simpan
        final saveBtn = find.widgetWithText(ElevatedButton, 'Simpan Perubahan');
        expect(saveBtn, findsOneWidget);

        // E. Informasi Prototype
        expect(find.textContaining('Perubahan hanya tersimpan pada sesi prototype'), findsOneWidget);

        // Ubah nama pengguna dan simpan
        final nameField = find.widgetWithText(TextFormField, 'Budi Pratama');
        await tester.enterText(nameField, 'Ahmad Fauzi');
        await tester.pump();

        await tester.ensureVisible(saveBtn);
        await tester.tap(saveBtn);
        await tester.pumpAndSettle();

        // Verifikasi SnackBar sukses
        expect(find.text('Perubahan profil berhasil disimpan.'), findsOneWidget);

        // Kembali ke tab Beranda untuk memastikan header tersinkronisasi
        await tester.tap(find.text('Beranda'));
        await tester.pumpAndSettle();

        // Nama di header sekarang Ahmad Fauzi dan inisial AF
        expect(find.text('Ahmad Fauzi'), findsOneWidget);
        expect(find.text('AF'), findsOneWidget);
      },
    );
  });
}
