import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../booking/domain/entities/order_entity.dart';

/// Kartu informasi metrik perjalanan ambulans (Estimasi kedatangan, jarak, status ambulans, dan status pembaruan simulasi).
class TripInfoCard extends StatelessWidget {
  final OrderStatus status;
  final bool isPaymentValid;

  const TripInfoCard({
    super.key,
    required this.status,
    required this.isPaymentValid,
  });

  String _getEtaText() {
    if (!isPaymentValid ||
        status == OrderStatus.menungguPembayaran ||
        status == OrderStatus.menungguValidasi) {
      return 'Menunggu konfirmasi';
    }
    switch (status) {
      case OrderStatus.menujuLokasi:
        return '8 menit lagi';
      case OrderStatus.tibaDiLokasi:
        return 'Tiba di lokasi penjemputan';
      case OrderStatus.dalamPerjalanan:
        return '15 menit menuju RS';
      case OrderStatus.layananSelesai:
        return 'Layanan selesai';
      default:
        return '8 menit lagi';
    }
  }

  String _getDistanceText() {
    if (!isPaymentValid ||
        status == OrderStatus.menungguPembayaran ||
        status == OrderStatus.menungguValidasi) {
      return '3,2 km (Estimasi rute)';
    }
    switch (status) {
      case OrderStatus.menujuLokasi:
        return '2,4 km ke lokasi Anda';
      case OrderStatus.tibaDiLokasi:
        return '0 m (Di titik jemput)';
      case OrderStatus.dalamPerjalanan:
        return '4,1 km ke RS tujuan';
      case OrderStatus.layananSelesai:
        return '0 m (Tiba di RS)';
      default:
        return '2,4 km';
    }
  }

  String _getStatusText() {
    if (!isPaymentValid ||
        status == OrderStatus.menungguPembayaran ||
        status == OrderStatus.menungguValidasi) {
      return 'Menunggu verifikasi pembayaran';
    }
    switch (status) {
      case OrderStatus.menujuLokasi:
        return 'Menuju lokasi penjemputan';
      case OrderStatus.tibaDiLokasi:
        return 'Tiba di lokasi penjemputan';
      case OrderStatus.dalamPerjalanan:
        return 'Dalam perjalanan ke RS rujukan';
      case OrderStatus.layananSelesai:
        return 'Tiba di IGD RS tujuan';
      default:
        return 'Ambulans siaga bertugas';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Informasi Perjalanan
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.near_me_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informasi Perjalanan Ambulans',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 1),
                    Text(
                      'Perkiraan waktu dan status armada menuju tujuan',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 2 Kolom Grid Metrik: Estimasi Kedatangan & Jarak ke Lokasi
          Row(
            children: [
              // Metrik 1: Estimasi Kedatangan
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 11,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.access_time_filled_rounded,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              'Estimasi Kedatangan',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _getEtaText(),
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Metrik 2: Jarak ke Lokasi
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 11,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.straighten_rounded,
                            size: 14,
                            color: AppColors.secondary,
                          ),
                          SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              'Jarak ke Lokasi',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _getDistanceText(),
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Status Ambulans
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.airport_shuttle_rounded,
                  size: 17,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Status Ambulans: ',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Expanded(
                  child: Text(
                    _getStatusText(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Keterangan Pembaruan Lokasi (Simulasi untuk pratinjau UI)
          const Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 14,
                color: AppColors.textSecondary,
              ),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Pembaruan Lokasi: Simulasi lokasi untuk pratinjau UI',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
