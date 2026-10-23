enum OrderStatus {
  menungguPembayaran('menungguPembayaran', 'Menunggu Pembayaran'),
  menungguValidasi('menungguValidasi', 'Menunggu Validasi'),
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
  });
}
