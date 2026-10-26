import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ambulans_app/features/booking/domain/entities/order_entity.dart';
import 'package:ambulans_app/features/booking/domain/entities/payment_entity.dart';
import 'package:ambulans_app/features/booking/domain/repositories/booking_repository.dart';
import 'package:ambulans_app/features/booking/presentation/pages/booking_page.dart';
import 'package:ambulans_app/features/dashboard/presentation/pages/admin_dashboard_page.dart';

class MockBookingRepository implements BookingRepository {
  final List<OrderEntity> orders = [];
  final Map<String, PaymentEntity> payments = {};
  OrderEntity? lastCreatedOrder;

  @override
  Future<OrderEntity> createBooking({
    required String userId,
    required String pickupAddress,
    required String destinationAddress,
    required double pickupLatitude,
    required double pickupLongitude,
    String? patientName,
    String? patientGender,
    int? patientAge,
    String? patientPhoneNumber,
    String? notes,
    String? serviceType,
    double? basePrice,
    double? additionalFee,
    double? totalPrice,
  }) async {
    lastCreatedOrder = OrderEntity(
      id: 'ORD-TEST-${orders.length + 1}',
      userId: userId,
      ambulanceId: 'AMB-101',
      driverId: 'DVR-202',
      status: OrderStatus.menungguPembayaran,
      pickupAddress: pickupAddress,
      destinationAddress: destinationAddress,
      pickupLatitude: pickupLatitude,
      pickupLongitude: pickupLongitude,
      patientName: patientName,
      patientGender: patientGender,
      patientAge: patientAge,
      patientPhoneNumber: patientPhoneNumber,
      notes: notes,
      serviceType: serviceType,
      basePrice: basePrice,
      additionalFee: additionalFee,
      totalPrice: totalPrice,
      createdAt: DateTime.now(),
    );
    orders.add(lastCreatedOrder!);
    return lastCreatedOrder!;
  }

  @override
  Future<OrderEntity> getOrderById(String orderId) async {
    final cleanId = orderId.replaceAll('#', '');
    return orders.firstWhere(
      (o) => o.id.replaceAll('#', '') == cleanId,
      orElse: () => lastCreatedOrder!,
    );
  }

  @override
  Future<List<OrderEntity>> getUserOrders(String userId) async {
    return orders.where((o) => o.userId == userId).toList();
  }

  @override
  Future<OrderEntity> updateOrderStatus(
    String orderId,
    OrderStatus newStatus,
  ) async {
    final index = orders.indexWhere((o) => o.id == orderId);
    if (index >= 0) {
      final updated = orders[index].copyWith(status: newStatus);
      orders[index] = updated;
      return updated;
    }
    return lastCreatedOrder!;
  }

  @override
  Future<PaymentEntity> submitPaymentProof(
    String orderId,
    String proofUrl, {
    String? paymentMethod,
    double? amount,
  }) async {
    final cleanId = orderId.replaceAll('#', '');
    final payment = PaymentEntity(
      id: 'PAY-TEST-${payments.length + 1}',
      orderId: orderId,
      paymentProofUrl: proofUrl,
      paymentStatus: 'menungguValidasi',
      paymentMethod: paymentMethod,
      amount: amount,
      paymentDate: DateTime.now(),
    );
    payments[cleanId] = payment;
    payments[orderId] = payment;

    final index = orders.indexWhere((o) => o.id.replaceAll('#', '') == cleanId);
    if (index >= 0) {
      orders[index] = orders[index].copyWith(
        status: OrderStatus.menungguValidasi,
        paymentMethod: paymentMethod,
        paymentProofUrl: proofUrl,
      );
    }
    return payment;
  }

  @override
  Future<PaymentEntity?> getPaymentByOrderId(String orderId) async {
    final cleanId = orderId.replaceAll('#', '');
    return payments[cleanId] ?? payments[orderId];
  }

  @override
  Future<OrderEntity> validatePayment(
    String orderId,
    bool isValid, {
    String? rejectionReason,
  }) async {
    final cleanId = orderId.replaceAll('#', '');
    final payment = payments[cleanId];
    if (payment != null) {
      payments[cleanId] = PaymentEntity(
        id: payment.id,
        orderId: payment.orderId,
        paymentStatus: isValid ? 'valid' : 'ditolak',
        amount: payment.amount,
        paymentMethod: payment.paymentMethod,
        paymentProofUrl: payment.paymentProofUrl,
        paymentDate: payment.paymentDate,
        rejectionReason: isValid ? null : rejectionReason,
      );
    }

    final index = orders.indexWhere((o) => o.id.replaceAll('#', '') == cleanId);
    if (index >= 0) {
      final updated = orders[index].copyWith(
        status: isValid ? OrderStatus.menujuLokasi : OrderStatus.menungguPembayaran,
        rejectionReason: isValid ? null : rejectionReason,
      );
      orders[index] = updated;
      return updated;
    }
    return lastCreatedOrder!;
  }

  @override
  Future<List<OrderEntity>> getAllOrders() async {
    return List.unmodifiable(orders);
  }
}

void main() {
  group('Ambulance Booking & Payment End-to-End Tests', () {
    testWidgets(
      'Form displays new patient fields and has removed Tahapan Status Pemesanan',
      (WidgetTester tester) async {
        final mockRepo = MockBookingRepository();

        await tester.pumpWidget(
          MaterialApp(
            home: BookingPage(bookingRepository: mockRepo),
          ),
        );
        await tester.pumpAndSettle();

        // 1. Verifikasi Header dan Peringatan
        expect(find.text('Pemesanan Ambulans Darurat'), findsOneWidget);
        expect(
          find.text(
            'Panggilan darurat ambulans akan segera diteruskan ke unit terdekat!',
          ),
          findsOneWidget,
        );

        // 2. Verifikasi Lokasi Penjemputan dan RS Tujuan
        expect(find.text('Lokasi Penjemputan'), findsOneWidget);
        expect(find.text('Rumah Sakit Tujuan'), findsOneWidget);

        // 3. Verifikasi Bagian Data Pasien dan field-nya
        expect(find.text('Data Pasien'), findsOneWidget);
        expect(find.text('Nama Lengkap Pasien'), findsOneWidget);
        expect(find.text('Jenis Kelamin'), findsOneWidget);
        expect(find.text('Umur Pasien'), findsOneWidget);
        expect(find.text('tahun'), findsOneWidget);
        expect(
          find.text('Nomor Telepon yang Bisa Dihubungi'),
          findsOneWidget,
        );

        // 4. Verifikasi Bagian Catatan Kondisi Pasien
        expect(
          find.text('Kondisi Pasien / Catatan Tambahan'),
          findsOneWidget,
        );

        // 5. Verifikasi bahwa Tahapan Status Pemesanan TELAH DIHAPUS
        expect(find.text('Tahapan Status Pemesanan:'), findsNothing);
        expect(find.text('Kode status: menungguPembayaran'), findsNothing);
        expect(find.text('Kode status: menungguValidasi'), findsNothing);
        expect(find.text('Kode status: layananSelesai'), findsNothing);

        // 6. Verifikasi Ikon Umur Pasien (bukan kue ulang tahun)
        expect(find.byIcon(Icons.cake_outlined), findsNothing);
        expect(find.byIcon(Icons.badge_outlined), findsOneWidget);

        // 7. Verifikasi Tata Letak Berdampingan (Baris 2: Jenis Kelamin & Umur Pasien)
        final genderField = find.widgetWithText(
          DropdownButtonFormField<String>,
          'Pilih jenis kelamin',
        );
        final ageField = find.widgetWithText(
          TextFormField,
          'Masukkan umur pasien',
        );
        final genderTop = tester.getTopLeft(genderField).dy;
        final ageTop = tester.getTopLeft(ageField).dy;
        expect(genderTop, equals(ageTop), reason: 'Jenis Kelamin dan Umur Pasien harus berdampingan');
      },
    );

    testWidgets(
      'Responsive layout: stacks Gender and Age vertically on narrow screens (<280px)',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(260, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final mockRepo = MockBookingRepository();

        await tester.pumpWidget(
          MaterialApp(
            home: BookingPage(bookingRepository: mockRepo),
          ),
        );
        await tester.pumpAndSettle();

        final genderField = find.widgetWithText(
          DropdownButtonFormField<String>,
          'Pilih jenis kelamin',
        );
        final ageField = find.widgetWithText(
          TextFormField,
          'Masukkan umur pasien',
        );
        final genderTop = tester.getTopLeft(genderField).dy;
        final ageTop = tester.getTopLeft(ageField).dy;
        expect(ageTop, greaterThan(genderTop), reason: 'Pada layar < 280px, Umur berada di bawah Jenis Kelamin');
      },
    );

    testWidgets(
      'Validates required fields in Indonesian before submitting',
      (WidgetTester tester) async {
        final mockRepo = MockBookingRepository();

        await tester.pumpWidget(
          MaterialApp(
            home: BookingPage(bookingRepository: mockRepo),
          ),
        );
        await tester.pumpAndSettle();

        final submitButton = find.text('Pesan Ambulans Sekarang');
        await tester.ensureVisible(submitButton);
        await tester.tap(submitButton);
        await tester.pumpAndSettle();

        expect(find.text('Nama lengkap pasien wajib diisi'), findsOneWidget);
        expect(find.text('Jenis kelamin wajib dipilih'), findsOneWidget);
        expect(find.text('Umur pasien wajib diisi'), findsOneWidget);
        expect(
          find.text('Nomor telepon yang bisa dihubungi wajib diisi'),
          findsOneWidget,
        );
        expect(mockRepo.lastCreatedOrder, isNull);
      },
    );

    testWidgets(
      'Full End-to-End Flow: Booking -> Confirmation (without Jadwal Layanan) -> Payment -> Payment Status',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(800, 1200);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final mockRepo = MockBookingRepository();

        await tester.pumpWidget(
          MaterialApp(
            home: BookingPage(bookingRepository: mockRepo),
          ),
        );
        await tester.pumpAndSettle();

        // 1. Mengisi formulir pemesanan
        final nameField = find.widgetWithText(
          TextFormField,
          'Masukkan nama lengkap pasien',
        );
        await tester.enterText(nameField, 'Budi Santoso');

        final genderDropdown = find.widgetWithText(
          DropdownButtonFormField<String>,
          'Pilih jenis kelamin',
        );
        await tester.tap(genderDropdown);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Laki-laki').last);
        await tester.pumpAndSettle();

        final ageField = find.widgetWithText(
          TextFormField,
          'Masukkan umur pasien',
        );
        await tester.enterText(ageField, '45');

        final phoneField = find.widgetWithText(
          TextFormField,
          'Masukkan nomor telepon aktif',
        );
        await tester.enterText(phoneField, '081234567890');

        final notesField = find.widgetWithText(
          TextFormField,
          'Tuliskan kondisi pasien, keluhan, atau informasi penting lainnya...',
        );
        await tester.enterText(notesField, 'Nyeri dada dan sesak napas');

        // Klik "Pesan Ambulans Sekarang"
        final submitButton = find.text('Pesan Ambulans Sekarang');
        await tester.ensureVisible(submitButton);
        await tester.tap(submitButton);
        await tester.pumpAndSettle();

        // 2. Verifikasi Halaman Konfirmasi Pesanan
        expect(find.widgetWithText(AppBar, 'Konfirmasi Pesanan'), findsOneWidget);
        expect(find.widgetWithText(ElevatedButton, 'Konfirmasi Pesanan'), findsOneWidget);
        expect(find.text('Budi Santoso'), findsOneWidget);
        expect(find.text('Laki-laki • 45 tahun'), findsOneWidget);
        expect(find.text('081234567890'), findsOneWidget);
        expect(find.text('Nyeri dada dan sesak napas'), findsOneWidget);

        // PENTING: Verifikasi tidak ada Jadwal Layanan
        expect(find.text('Jadwal Layanan'), findsNothing);
        expect(find.text('Tanggal Layanan'), findsNothing);

        // Verifikasi tombol Ubah tersedia pada bagian-bagian
        expect(find.text('Ubah'), findsAtLeastNWidgets(3));

        // Verifikasi Checkbox persetujuan
        final checkboxFinder = find.byType(Checkbox);
        expect(checkboxFinder, findsOneWidget);

        // Tombol Konfirmasi Pesanan belum aktif sebelum dicentang
        final confirmBtnFinder = find.widgetWithText(ElevatedButton, 'Konfirmasi Pesanan');
        expect(confirmBtnFinder, findsOneWidget);

        // Centang persetujuan
        await tester.ensureVisible(checkboxFinder);
        await tester.tap(checkboxFinder);
        await tester.pumpAndSettle();

        // Klik "Konfirmasi Pesanan"
        await tester.ensureVisible(confirmBtnFinder);
        await tester.tap(confirmBtnFinder);
        await tester.pumpAndSettle();

        // 3. Verifikasi Halaman Pembayaran
        expect(find.text('Pembayaran Ambulans'), findsOneWidget);
        expect(find.text('Belum Dibayar'), findsOneWidget);
        expect(find.text('Ringkasan Tagihan'), findsOneWidget);
        expect(find.text('Transfer Bank BCA'), findsOneWidget);
        expect(find.text('Transfer Bank Mandiri'), findsOneWidget);
        expect(find.textContaining('QRIS'), findsOneWidget);
        expect(find.text('Salin'), findsAtLeastNWidgets(2));

        // Pilih metode pembayaran BCA
        await tester.tap(find.text('Transfer Bank BCA'));
        await tester.pumpAndSettle();

        // Unggah bukti pembayaran (gunakan opsi pemilih file bukti transfer)
        final uploadProofButton = find.text('Pilih atau Unggah Bukti Transfer');
        await tester.ensureVisible(uploadProofButton);
        await tester.tap(uploadProofButton);
        await tester.pumpAndSettle();

        // Pilih opsi bukti struk dari sheet
        await tester.tap(find.text('Bukti Struk Transfer Bank (Valid)'));
        await tester.pumpAndSettle();

        // Verifikasi preview bukti pembayaran muncul
        expect(find.text('Ganti File'), findsOneWidget);
        expect(find.text('Hapus'), findsOneWidget);

        // Klik "Kirim Bukti Pembayaran"
        final sendProofBtn = find.widgetWithText(ElevatedButton, 'Kirim Bukti Pembayaran');
        await tester.ensureVisible(sendProofBtn);
        await tester.tap(sendProofBtn);
        await tester.pumpAndSettle();

        // 4. Verifikasi Halaman Status Pembayaran
        expect(find.text('Status Pembayaran'), findsOneWidget);
        expect(find.text('Menunggu Validasi Pembayaran'), findsOneWidget);
        expect(find.text('Menunggu Validasi'), findsOneWidget);
        expect(
          find.textContaining('Bukti pembayaran Anda telah diterima dan sedang diperiksa oleh administrator.'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Admin Dashboard can inspect, approve, and reject payment with reason',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1200, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final mockRepo = MockBookingRepository();

        // Buat order dan submit payment proof
        final order = await mockRepo.createBooking(
          userId: 'USR-001',
          pickupAddress: 'Jl. Malioboro No. 10',
          destinationAddress: 'RSUP Dr. Sardjito',
          pickupLatitude: -7.7956,
          pickupLongitude: 110.3695,
          patientName: 'Ny. Siti Aminah',
          patientGender: 'Perempuan',
          patientAge: 62,
          patientPhoneNumber: '081398765432',
          notes: 'Nyeri dada akut',
          serviceType: 'Ambulans Gawat Darurat (Emergency)',
          basePrice: 150000.0,
          additionalFee: 50000.0,
          totalPrice: 200000.0,
        );

        await mockRepo.submitPaymentProof(
          order.id,
          'assets/images/proof_test.jpg',
          paymentMethod: 'Transfer Bank BCA',
          amount: 200000.0,
        );

        // Render AdminDashboardPage
        await tester.pumpWidget(
          MaterialApp(
            home: AdminDashboardPage(bookingRepository: mockRepo),
          ),
        );
        await tester.pumpAndSettle();

        // Verifikasi order tampil di Pesanan Perlu Ditindaklanjuti
        expect(find.text('Pesanan Perlu Ditindaklanjuti'), findsOneWidget);
        expect(find.text('#${order.id}'), findsOneWidget);
        expect(find.textContaining('Ny. Siti Aminah'), findsOneWidget);

        // Klik tombol "Validasi"
        final validasiBtn = find.widgetWithText(ElevatedButton, 'Validasi').first;
        await tester.tap(validasiBtn);
        await tester.pumpAndSettle();

        // Verifikasi dialog validasi terbuka dengan data pasien lengkap
        expect(find.text('Validasi Pembayaran #${order.id}'), findsOneWidget);
        expect(find.text('Ny. Siti Aminah'), findsOneWidget);
        expect(find.text('081398765432'), findsOneWidget);
        expect(find.text('Buka Bukti'), findsOneWidget);

        // Tolak pembayaran dengan alasan
        final tolakBtn = find.widgetWithText(OutlinedButton, 'Tolak Pembayaran');
        await tester.tap(tolakBtn);
        await tester.pumpAndSettle();

        expect(find.text('Tolak Pembayaran #${order.id}'), findsOneWidget);

        // Pilih chip alasan cepat atau ketik
        final chip = find.text('Nominal kurang');
        await tester.tap(chip);
        await tester.pumpAndSettle();

        final sendRejectBtn = find.widgetWithText(ElevatedButton, 'Kirim Penolakan');
        await tester.tap(sendRejectBtn);
        await tester.pumpAndSettle();

        // Verifikasi status order ter-update di repository
        final updatedOrder = await mockRepo.getOrderById(order.id);
        expect(updatedOrder.rejectionReason, isNotNull);
        expect(updatedOrder.rejectionReason, contains('Nominal transfer'));
      },
    );
  });
}
