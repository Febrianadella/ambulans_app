enum OrderStatus {
  menungguPembayaran('menungguPembayaran', 'Menunggu Konfirmasi'),
  menungguValidasi('menungguValidasi', 'Menunggu Konfirmasi'),
  menujuLokasi('menujuLokasi', 'Menuju Lokasi Pasien'),
  tibaDiLokasi('tibaDiLokasi', 'Tiba di Lokasi'),
  dalamPerjalanan('dalamPerjalanan', 'Dalam Perjalanan ke RS'),
  layananSelesai('layananSelesai', 'Layanan Selesai');

  final String value;
  final String label;

  const OrderStatus(this.value, this.label);

  static OrderStatus fromString(String? status) {
    switch (status) {
      case 'menungguValidasi':
      case 'menunggu_validasi':
        return OrderStatus.menungguValidasi;
      case 'menujuLokasi':
      case 'menuju_lokasi':
        return OrderStatus.menujuLokasi;
      case 'tibaDiLokasi':
      case 'tiba_di_lokasi':
        return OrderStatus.tibaDiLokasi;
      case 'dalamPerjalanan':
      case 'dalam_perjalanan':
        return OrderStatus.dalamPerjalanan;
      case 'layananSelesai':
      case 'layanan_selesai':
        return OrderStatus.layananSelesai;
      case 'menungguPembayaran':
      case 'menunggu_pembayaran':
      default:
        return OrderStatus.menungguPembayaran;
    }
  }
}

class OrderEntity {
  final String id;
  final String userId;
  final String ambulanceId;
  final String driverId;
  final OrderStatus status;
  final String? pickupAddress;
  final String? destinationAddress;
  final double? pickupLatitude;
  final double? pickupLongitude;
  final double? destinationLatitude;
  final double? destinationLongitude;
  final double? totalPrice;
  final DateTime? createdAt;
  final String? patientName;
  final String? patientGender;
  final int? patientAge;
  final String? patientPhoneNumber;
  final String? notes;
  final String? serviceType;
  final double? basePrice;
  final double? additionalFee;
  final String? rejectionReason;
  final String? paymentMethod;
  final String? paymentProofUrl;

  const OrderEntity({
    required this.id,
    required this.userId,
    required this.ambulanceId,
    required this.driverId,
    required this.status,
    this.pickupAddress,
    this.destinationAddress,
    this.pickupLatitude,
    this.pickupLongitude,
    this.destinationLatitude,
    this.destinationLongitude,
    this.totalPrice,
    this.createdAt,
    this.patientName,
    this.patientGender,
    this.patientAge,
    this.patientPhoneNumber,
    this.notes,
    this.serviceType,
    this.basePrice,
    this.additionalFee,
    this.rejectionReason,
    this.paymentMethod,
    this.paymentProofUrl,
  });

  OrderEntity copyWith({
    String? id,
    String? userId,
    String? ambulanceId,
    String? driverId,
    OrderStatus? status,
    String? pickupAddress,
    String? destinationAddress,
    double? pickupLatitude,
    double? pickupLongitude,
    double? destinationLatitude,
    double? destinationLongitude,
    double? totalPrice,
    DateTime? createdAt,
    String? patientName,
    String? patientGender,
    int? patientAge,
    String? patientPhoneNumber,
    String? notes,
    String? serviceType,
    double? basePrice,
    double? additionalFee,
    String? rejectionReason,
    String? paymentMethod,
    String? paymentProofUrl,
  }) {
    return OrderEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      ambulanceId: ambulanceId ?? this.ambulanceId,
      driverId: driverId ?? this.driverId,
      status: status ?? this.status,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      destinationAddress: destinationAddress ?? this.destinationAddress,
      pickupLatitude: pickupLatitude ?? this.pickupLatitude,
      pickupLongitude: pickupLongitude ?? this.pickupLongitude,
      destinationLatitude: destinationLatitude ?? this.destinationLatitude,
      destinationLongitude: destinationLongitude ?? this.destinationLongitude,
      totalPrice: totalPrice ?? this.totalPrice,
      createdAt: createdAt ?? this.createdAt,
      patientName: patientName ?? this.patientName,
      patientGender: patientGender ?? this.patientGender,
      patientAge: patientAge ?? this.patientAge,
      patientPhoneNumber: patientPhoneNumber ?? this.patientPhoneNumber,
      notes: notes ?? this.notes,
      serviceType: serviceType ?? this.serviceType,
      basePrice: basePrice ?? this.basePrice,
      additionalFee: additionalFee ?? this.additionalFee,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentProofUrl: paymentProofUrl ?? this.paymentProofUrl,
    );
  }
}

