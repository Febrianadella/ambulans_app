import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/payment_entity.dart';
import '../../domain/repositories/booking_repository.dart';
import 'payment_page.dart';

class PaymentStatusPage extends StatefulWidget {
  final OrderEntity order;
  final PaymentEntity payment;
  final BookingRepository repository;

  const PaymentStatusPage({
    super.key,
    required this.order,
    required this.payment,
    required this.repository,
  });

  @override
  State<PaymentStatusPage> createState() => _PaymentStatusPageState();
}

class _PaymentStatusPageState extends State<PaymentStatusPage> {
  late OrderEntity _currentOrder;
  late PaymentEntity _currentPayment;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _currentOrder = widget.order;
    _currentPayment = widget.payment;
  }

  Future<void> _refreshStatus() async {
    setState(() {
      _isRefreshing = true;
    });

    try {
      final updatedOrder = await widget.repository.getOrderById(_currentOrder.id);
      final updatedPayment = await widget.repository.getPaymentByOrderId(_currentOrder.id);

      if (!mounted) return;
      setState(() {
        _currentOrder = updatedOrder;
        if (updatedPayment != null) {
          _currentPayment = updatedPayment;
        }
        _isRefreshing = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRejected =
        _currentPayment.paymentStatus == 'ditolak' ||
        _currentOrder.rejectionReason != null;
    final isValid =
        _currentPayment.paymentStatus == 'valid' ||
        _currentOrder.status == OrderStatus.menujuLokasi;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Status Pembayaran'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0.5,
        actions: [
          IconButton(
            tooltip: 'Perbarui Status',
            icon: _isRefreshing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh_rounded),
            onPressed: _isRefreshing ? null : _refreshStatus,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Icon & Title
            Center(child: _buildStatusHeader(isRejected: isRejected, isValid: isValid)),
            const SizedBox(height: 20),

            // Keterangan Alur Verifikasi
            _buildExplanationBanner(isRejected: isRejected, isValid: isValid),
            const SizedBox(height: 18),

            // Card Rincian Status Pesanan & Pembayaran
            _buildStatusDetailsCard(isRejected: isRejected, isValid: isValid),
            const SizedBox(height: 18),

            // Card Bukti Pembayaran yang Diunggah
            _buildUploadedProofCard(),
            const SizedBox(height: 24),

            // Tombol Aksi
            if (isRejected) ...[
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PaymentPage(
                        order: _currentOrder,
                        repository: widget.repository,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.replay_rounded),
                label: const Text(
                  'Unggah Ulang Bukti Pembayaran',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],

            OutlinedButton(
              onPressed: () {
                // Kembali ke halaman beranda utama aplikasi
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: AppColors.border),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Kembali ke Beranda',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader({required bool isRejected, required bool isValid}) {
    IconData iconData;
    Color iconColor;
    Color bgColor;
    String titleText;
    String badgeLabel;

    if (isValid) {
      iconData = Icons.verified_rounded;
      iconColor = AppColors.success;
      bgColor = AppColors.successLight;
      titleText = 'Pembayaran Berhasil Divalidasi';
      badgeLabel = 'Pembayaran Valid';
    } else if (isRejected) {
      iconData = Icons.cancel_rounded;
      iconColor = AppColors.error;
      bgColor = AppColors.errorLight;
      titleText = 'Pembayaran Ditolak';
      badgeLabel = 'Pembayaran Ditolak';
    } else {
      iconData = Icons.hourglass_top_rounded;
      iconColor = AppColors.warning;
      bgColor = AppColors.warningLight;
      titleText = 'Menunggu Validasi Pembayaran';
      badgeLabel = 'Menunggu Validasi';
    }

    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
            border: Border.all(color: iconColor.withValues(alpha: 0.3), width: 2),
          ),
          child: Icon(iconData, color: iconColor, size: 40),
        ),
        const SizedBox(height: 14),
        Text(
          titleText,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        if (isValid)
          StatusBadge.success(badgeLabel)
        else if (isRejected)
          StatusBadge.error(badgeLabel)
        else
          StatusBadge.warning(badgeLabel),
      ],
    );
  }

  Widget _buildExplanationBanner({required bool isRejected, required bool isValid}) {
    String message;
    Color bannerColor;
    Color borderColor;
    Color textColor;
    IconData iconData;

    if (isValid) {
      message =
          'Pembayaran Anda telah diverifikasi oleh administrator. Unit ambulans sedang dipersiapkan dan segera menuju ke lokasi penjemputan.';
      bannerColor = AppColors.successLight;
      borderColor = AppColors.success.withValues(alpha: 0.3);
      textColor = const Color(0xFF065F46);
      iconData = Icons.check_circle_outline_rounded;
    } else if (isRejected) {
      final reason = _currentOrder.rejectionReason ??
          _currentPayment.rejectionReason ??
          'Nominal transfer tidak sesuai atau bukti struk buram/tidak terbaca.';
      message = 'Alasan penolakan: $reason\nSilakan unggah ulang bukti pembayaran yang benar.';
      bannerColor = AppColors.errorLight;
      borderColor = AppColors.error.withValues(alpha: 0.3);
      textColor = AppColors.primaryDark;
      iconData = Icons.error_outline_rounded;
    } else {
      message =
          'Bukti pembayaran Anda telah diterima dan sedang diperiksa oleh administrator. Status pembayaran akan diperbarui setelah proses verifikasi selesai.';
      bannerColor = AppColors.warningLight;
      borderColor = AppColors.warning.withValues(alpha: 0.3);
      textColor = const Color(0xFF92400E);
      iconData = Icons.schedule_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bannerColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(iconData, color: textColor, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: textColor,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDetailsCard({required bool isRejected, required bool isValid}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detail Tagihan & Pembayaran',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 12),
          _buildDetailRow('Nomor Pesanan', '#${_currentOrder.id}'),
          const SizedBox(height: 8),
          _buildDetailRow(
            'Metode Pembayaran',
            _currentPayment.paymentMethod ?? _currentOrder.paymentMethod ?? 'Transfer Bank BCA',
          ),
          const SizedBox(height: 8),
          _buildDetailRow(
            'Total Tagihan',
            DateFormatter.formatCurrency(_currentOrder.totalPrice ?? 200000.0),
            isBoldValue: true,
            valueColor: AppColors.primary,
          ),
          const SizedBox(height: 8),
          _buildDetailRow('Nama Pasien', _currentOrder.patientName ?? '-'),
          const SizedBox(height: 8),
          _buildDetailRow('Lokasi Jemput', _currentOrder.pickupAddress ?? '-'),
          const SizedBox(height: 8),
          _buildDetailRow('RS Tujuan', _currentOrder.destinationAddress ?? '-'),
        ],
      ),
    );
  }

  Widget _buildUploadedProofCard() {
    final proofName = _currentPayment.paymentProofUrl ?? _currentOrder.paymentProofUrl ?? 'bukti_transfer.jpg';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bukti Pembayaran yang Telah Diunggah',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.receipt_long_rounded,
                      color: AppColors.primary,
                      size: 26,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        proofName.split('/').last,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Format JPG/PNG • Telah Diterima Sistem',
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                  size: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isBoldValue = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: isBoldValue ? FontWeight.bold : FontWeight.w600,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
