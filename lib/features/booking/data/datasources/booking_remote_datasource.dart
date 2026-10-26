import 'package:flutter/foundation.dart';

import '../models/order_model.dart';
import '../models/payment_model.dart';
import '../../domain/entities/order_entity.dart';

abstract class BookingRemoteDataSource {
  Future<OrderModel> createBooking(OrderModel order);
  Future<OrderModel> getOrderById(String orderId);
  Future<List<OrderModel>> getUserOrders(String userId);
  Future<OrderModel> updateOrderStatus(String orderId, OrderStatus newStatus);
  Future<PaymentModel> submitPaymentProof(
    String orderId,
    String proofUrl, {
    String? paymentMethod,
    double? amount,
  });
  Future<PaymentModel?> getPaymentByOrderId(String orderId);
  Future<OrderModel> validatePayment(
    String orderId,
    bool isValid, {
    String? rejectionReason,
  });
  Future<List<OrderModel>> getAllOrders();
}

class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  // Notifier perubahan status pesanan untuk sinkronisasi antar halaman
  static final ValueNotifier<int> ordersChangeNotifier = ValueNotifier<int>(0);

  static void notifyOrdersChanged() {
    ordersChangeNotifier.value++;
  }

  // Penyimpanan memori bersama agar alur pesanan, sopir, dan validasi admin terhubung nyata
  static final List<OrderModel> _inMemoryOrders = [
    // 1. Pesanan Aktif Berjalan (Sopir Menuju Lokasi)
    OrderModel(
      id: 'ORD-20261023-01',
      userId: 'USR-20261023-01',
      ambulanceId: 'AMB-101',
      driverId: 'DVR-202',
      status: OrderStatus.menujuLokasi,
      pickupAddress: 'Jl. Malioboro No. 42, Danurejan, Yogyakarta',
      destinationAddress: 'RSUP Dr. Sardjito, Sleman',
      pickupLatitude: -7.7956,
      pickupLongitude: 110.3695,
      destinationLatitude: -7.7686,
      destinationLongitude: 110.3734,
      totalPrice: 250000.0,
      basePrice: 200000.0,
      additionalFee: 50000.0,
      serviceType: 'Ambulans Gawat Darurat (Emergency)',
      patientName: 'Bpk. Hendrawan',
      patientGender: 'Laki-laki',
      patientAge: 48,
      patientPhoneNumber: '081234567890',
      notes: 'Pasien sesak napas berat membutuhkan oksigen darurat',
      paymentMethod: 'Transfer Bank BCA',
      paymentProofUrl: 'assets/images/proof_mandiri.jpg',
      createdAt: DateTime(2026, 10, 23, 8, 30),
    ),
    // 2. Pesanan Berlangsung Menunggu Validasi Pembayaran
    OrderModel(
      id: 'ORD-20261023-04',
      userId: 'USR-20261023-01',
      ambulanceId: 'AMB-101',
      driverId: 'DVR-202',
      status: OrderStatus.menungguValidasi,
      pickupAddress: 'Jl. Gejayan No. 15, Sleman',
      destinationAddress: 'RS Panti Rapih, Yogyakarta',
      pickupLatitude: -7.7712,
      pickupLongitude: 110.3891,
      destinationLatitude: -7.7781,
      destinationLongitude: 110.3775,
      totalPrice: 200000.0,
      basePrice: 150000.0,
      additionalFee: 50000.0,
      serviceType: 'Ambulans Gawat Darurat (Emergency)',
      patientName: 'Bpk. Budi Pratama',
      patientGender: 'Laki-laki',
      patientAge: 38,
      patientPhoneNumber: '081234567891',
      notes: 'Cedera ringan pada pergelangan kaki',
      paymentMethod: 'Transfer Bank Mandiri',
      paymentProofUrl: 'assets/images/proof_mandiri.jpg',
      createdAt: DateTime(2026, 10, 23, 10, 15),
    ),
    // 3. Riwayat Pesanan Selesai 1
    OrderModel(
      id: 'AMB-2026-0087',
      userId: 'USR-20261023-01',
      ambulanceId: 'AMB-102',
      driverId: 'DVR-202',
      status: OrderStatus.layananSelesai,
      pickupAddress: 'Jl. Kaliurang KM 5, Caturtunggal, Sleman',
      destinationAddress: 'RSUP Dr. Sardjito, Sleman',
      pickupLatitude: -7.7601,
      pickupLongitude: 110.3835,
      destinationLatitude: -7.7686,
      destinationLongitude: 110.3734,
      totalPrice: 180000.0,
      basePrice: 150000.0,
      additionalFee: 30000.0,
      serviceType: 'Ambulans Standar Medis',
      patientName: 'Ibu Ratna Dewi',
      patientGender: 'Perempuan',
      patientAge: 42,
      patientPhoneNumber: '081298765432',
      notes: 'Pasien evakuasi pasca rawat inap',
      paymentMethod: 'Transfer Bank BCA',
      paymentProofUrl: 'assets/images/proof_bca.jpg',
      createdAt: DateTime(2026, 10, 22, 14, 20),
    ),
    // 4. Riwayat Pesanan Selesai 2
    OrderModel(
      id: 'ORD-20261021-02',
      userId: 'USR-20261023-01',
      ambulanceId: 'AMB-103',
      driverId: 'DVR-204',
      status: OrderStatus.layananSelesai,
      pickupAddress: 'Jl. Wonosari KM 7, Banguntapan, Bantul',
      destinationAddress: 'RSUD Kota Yogyakarta, Wirosaban',
      pickupLatitude: -7.8281,
      pickupLongitude: 110.4124,
      destinationLatitude: -7.8242,
      destinationLongitude: 110.3792,
      totalPrice: 220000.0,
      basePrice: 170000.0,
      additionalFee: 50000.0,
      serviceType: 'Ambulans Gawat Darurat (Emergency)',
      patientName: 'Bpk. Agus Santoso',
      patientGender: 'Laki-laki',
      patientAge: 55,
      patientPhoneNumber: '081324567800',
      notes: 'Demam tinggi dan lemas',
      paymentMethod: 'QRIS',
      paymentProofUrl: 'assets/images/proof_mandiri.jpg',
      createdAt: DateTime(2026, 10, 21, 16, 45),
    ),
  ];

  static final Map<String, PaymentModel> _inMemoryPayments = {
    'ORD-20261023-01': PaymentModel(
      id: 'PAY-1000',
      orderId: 'ORD-20261023-01',
      paymentStatus: 'valid',
      paymentMethod: 'Transfer Bank BCA',
      amount: 250000.0,
      paymentProofUrl: 'assets/images/proof_mandiri.jpg',
      paymentDate: DateTime(2026, 10, 23, 8, 32),
    ),
    'ORD-20261023-04': PaymentModel(
      id: 'PAY-1001',
      orderId: 'ORD-20261023-04',
      paymentStatus: 'menungguValidasi',
      paymentMethod: 'Transfer Bank Mandiri',
      amount: 200000.0,
      paymentProofUrl: 'assets/images/proof_mandiri.jpg',
      paymentDate: DateTime(2026, 10, 23, 10, 16),
    ),
    'AMB-2026-0087': PaymentModel(
      id: 'PAY-0987',
      orderId: 'AMB-2026-0087',
      paymentStatus: 'valid',
      paymentMethod: 'Transfer Bank BCA',
      amount: 180000.0,
      paymentProofUrl: 'assets/images/proof_bca.jpg',
      paymentDate: DateTime(2026, 10, 22, 14, 22),
    ),
    'ORD-20261021-02': PaymentModel(
      id: 'PAY-0965',
      orderId: 'ORD-20261021-02',
      paymentStatus: 'valid',
      paymentMethod: 'QRIS',
      amount: 220000.0,
      paymentProofUrl: 'assets/images/proof_mandiri.jpg',
      paymentDate: DateTime(2026, 10, 21, 16, 47),
    ),
  };

  @override
  Future<OrderModel> createBooking(OrderModel order) async {
    final existingIndex = _inMemoryOrders.indexWhere((o) => o.id == order.id);
    if (existingIndex >= 0) {
      _inMemoryOrders[existingIndex] = order;
    } else {
      _inMemoryOrders.insert(0, order);
    }
    notifyOrdersChanged();
    return order;
  }

  @override
  Future<OrderModel> getOrderById(String orderId) async {
    final cleanId = orderId.replaceAll('#', '').trim();
    try {
      return _inMemoryOrders.firstWhere(
        (o) => o.id.replaceAll('#', '').trim() == cleanId,
      );
    } catch (_) {
      return OrderModel(
        id: orderId,
        userId: 'USR-20261023-01',
        ambulanceId: 'AMB-101',
        driverId: 'DVR-202',
        status: OrderStatus.menujuLokasi,
        pickupAddress: 'Jl. Malioboro No. 42, Yogyakarta',
        destinationAddress: 'RSUP Dr. Sardjito, Sleman',
        serviceType: 'Ambulans Gawat Darurat (Emergency)',
        totalPrice: 250000.0,
        createdAt: DateTime.now(),
      );
    }
  }

  @override
  Future<List<OrderModel>> getUserOrders(String userId) async {
    if (userId.isEmpty || userId == 'ALL' || userId.startsWith('USR')) {
      return List.unmodifiable(_inMemoryOrders);
    }
    return _inMemoryOrders.where((o) => o.userId == userId).toList();
  }

  @override
  Future<OrderModel> updateOrderStatus(
    String orderId,
    OrderStatus newStatus,
  ) async {
    final cleanId = orderId.replaceAll('#', '').trim();
    final index = _inMemoryOrders.indexWhere(
      (o) => o.id.replaceAll('#', '').trim() == cleanId,
    );
    if (index >= 0) {
      final updated = _inMemoryOrders[index].copyWith(status: newStatus);
      _inMemoryOrders[index] = updated;
      notifyOrdersChanged();
      return updated;
    }
    final fallback = OrderModel(
      id: orderId,
      userId: 'USR-20261023-01',
      ambulanceId: 'AMB-101',
      driverId: 'DVR-202',
      status: newStatus,
      createdAt: DateTime.now(),
    );
    _inMemoryOrders.add(fallback);
    notifyOrdersChanged();
    return fallback;
  }

  @override
  Future<PaymentModel> submitPaymentProof(
    String orderId,
    String proofUrl, {
    String? paymentMethod,
    double? amount,
  }) async {
    final cleanId = orderId.replaceAll('#', '').trim();
    final payment = PaymentModel(
      id: 'PAY-${DateTime.now().millisecondsSinceEpoch}',
      orderId: orderId,
      paymentProofUrl: proofUrl,
      paymentStatus: 'menungguValidasi',
      paymentMethod: paymentMethod ?? 'Transfer Bank',
      amount: amount ?? 200000.0,
      paymentDate: DateTime.now(),
    );
    _inMemoryPayments[cleanId] = payment;
    _inMemoryPayments[orderId] = payment;

    // Perbarui status pesanan menjadi menungguValidasi
    final orderIndex = _inMemoryOrders.indexWhere(
      (o) => o.id.replaceAll('#', '').trim() == cleanId,
    );
    if (orderIndex >= 0) {
      _inMemoryOrders[orderIndex] = _inMemoryOrders[orderIndex].copyWith(
        status: OrderStatus.menungguValidasi,
        paymentMethod: paymentMethod,
        paymentProofUrl: proofUrl,
      );
    }

    notifyOrdersChanged();
    return payment;
  }

  @override
  Future<PaymentModel?> getPaymentByOrderId(String orderId) async {
    final cleanId = orderId.replaceAll('#', '').trim();
    return _inMemoryPayments[cleanId] ?? _inMemoryPayments[orderId];
  }

  @override
  Future<OrderModel> validatePayment(
    String orderId,
    bool isValid, {
    String? rejectionReason,
  }) async {
    final cleanId = orderId.replaceAll('#', '').trim();
    final orderIndex = _inMemoryOrders.indexWhere(
      (o) => o.id.replaceAll('#', '').trim() == cleanId,
    );

    final payment = _inMemoryPayments[cleanId];
    if (payment != null) {
      _inMemoryPayments[cleanId] = payment.copyWith(
        paymentStatus: isValid ? 'valid' : 'ditolak',
        rejectionReason: isValid ? null : rejectionReason,
      );
    }

    if (orderIndex >= 0) {
      final updated = _inMemoryOrders[orderIndex].copyWith(
        status: isValid
            ? OrderStatus.menujuLokasi
            : OrderStatus.menungguPembayaran,
        rejectionReason: isValid ? null : rejectionReason,
      );
      _inMemoryOrders[orderIndex] = updated;
      notifyOrdersChanged();
      return updated;
    }

    final fallback = OrderModel(
      id: orderId,
      userId: 'USR-20261023-01',
      ambulanceId: 'AMB-101',
      driverId: 'DVR-202',
      status: isValid
          ? OrderStatus.menujuLokasi
          : OrderStatus.menungguPembayaran,
      rejectionReason: isValid ? null : rejectionReason,
      createdAt: DateTime.now(),
    );
    _inMemoryOrders.add(fallback);
    notifyOrdersChanged();
    return fallback;
  }

  @override
  Future<List<OrderModel>> getAllOrders() async {
    return List.unmodifiable(_inMemoryOrders);
  }
}
