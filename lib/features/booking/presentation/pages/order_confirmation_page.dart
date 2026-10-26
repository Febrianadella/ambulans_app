import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/repositories/booking_repository.dart';
import 'payment_page.dart';

class OrderConfirmationPage extends StatefulWidget {
  final String userId;
  final String pickupAddress;
  final String destinationAddress;
  final double pickupLatitude;
  final double pickupLongitude;
  final String patientName;
  final String patientGender;
  final int patientAge;
  final String patientPhoneNumber;
  final String? notes;
  final String serviceType;
  final double basePrice;
  final double additionalFee;
  final BookingRepository repository;

  const OrderConfirmationPage({
    super.key,
    required this.userId,
    required this.pickupAddress,
    required this.destinationAddress,
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.patientName,
    required this.patientGender,
    required this.patientAge,
    required this.patientPhoneNumber,
    this.notes,
    this.serviceType = 'Ambulans Gawat Darurat (Emergency)',
    this.basePrice = 150000.0,
    this.additionalFee = 50000.0,
    required this.repository,
  });

  @override
  State<OrderConfirmationPage> createState() => _OrderConfirmationPageState();
}

class _OrderConfirmationPageState extends State<OrderConfirmationPage> {
  bool _agreedToTerms = false;
  bool _isSubmitting = false;

  double get _totalPrice => widget.basePrice + widget.additionalFee;

  Future<void> _confirmAndProceed() async {
    if (!_agreedToTerms) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final createdOrder = await widget.repository.createBooking(
        userId: widget.userId,
        pickupAddress: widget.pickupAddress,
        destinationAddress: widget.destinationAddress,
        pickupLatitude: widget.pickupLatitude,
        pickupLongitude: widget.pickupLongitude,
        patientName: widget.patientName,
        patientGender: widget.patientGender,
        patientAge: widget.patientAge,
        patientPhoneNumber: widget.patientPhoneNumber,
        notes: widget.notes,
        serviceType: widget.serviceType,
        basePrice: widget.basePrice,
        additionalFee: widget.additionalFee,
        totalPrice: _totalPrice,
      );

      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });

      // Arahkan pengguna ke halaman Pembayaran
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              PaymentPage(order: createdOrder, repository: widget.repository),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membuat pesanan: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Konfirmasi Pesanan'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Peringatan Panggilan Darurat
            _buildNoticeBanner(),
            const SizedBox(height: 16),

            // 1. Informasi Pasien
            _buildPatientInfoCard(),
            const SizedBox(height: 14),

            // 3. Lokasi Penjemputan
            _buildPickupCard(),
            const SizedBox(height: 14),

            // 4. Lokasi Rumah Sakit Tujuan
            _buildDestinationCard(),
            const SizedBox(height: 14),

            // 5. Rincian Biaya
            _buildPriceBreakdownCard(),
            const SizedBox(height: 20),

            // Pernyataan Persetujuan Syarat Layanan
            _buildAgreementCheckbox(),
            const SizedBox(height: 22),

            // Tombol Aksi: Kembali & Konfirmasi Pesanan
            _buildActionButtons(),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildNoticeBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Periksa kembali seluruh detail informasi sebelum mengonfirmasi pesanan ambulans.',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 2. Card Informasi Pasien
  Widget _buildPatientInfoCard() {
    return _buildSectionCard(
      title: 'Informasi Pasien',
      icon: Icons.person_pin_rounded,
      onEdit: () => Navigator.pop(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
            icon: Icons.person_outline_rounded,
            label: 'Nama Lengkap Pasien',
            value: widget.patientName,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            icon: Icons.wc_rounded,
            label: 'Jenis Kelamin & Umur',
            value: '${widget.patientGender} • ${widget.patientAge} tahun',
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            icon: Icons.phone_outlined,
            label: 'Nomor Telepon',
            value: widget.patientPhoneNumber,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            icon: Icons.edit_note_rounded,
            label: 'Kondisi / Catatan',
            value: (widget.notes != null && widget.notes!.trim().isNotEmpty)
                ? widget.notes!
                : 'Tidak ada catatan tambahan',
            isMuted: widget.notes == null || widget.notes!.trim().isEmpty,
          ),
        ],
      ),
    );
  }

  // 3. Card Lokasi Penjemputan
  Widget _buildPickupCard() {
    return _buildSectionCard(
      title: 'Lokasi Penjemputan',
      icon: Icons.my_location_rounded,
      onEdit: () => Navigator.pop(context),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.location_on_rounded,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.pickupAddress,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 4. Card Lokasi Rumah Sakit Tujuan
  Widget _buildDestinationCard() {
    return _buildSectionCard(
      title: 'Lokasi Tujuan',
      icon: Icons.local_hospital_rounded,
      onEdit: () => Navigator.pop(context),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.local_hospital_rounded,
            color: AppColors.secondary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.destinationAddress,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 5. Card Rincian Biaya
  Widget _buildPriceBreakdownCard() {
    return _buildSectionCard(
      title: 'Rincian Biaya',
      icon: Icons.receipt_long_rounded,
      child: Column(
        children: [
          _buildPriceRow(
            label: 'Tarif Dasar Ambulans',
            amount: widget.basePrice,
          ),
          const SizedBox(height: 8),
          _buildPriceRow(
            label: 'Peralatan Medis & Oksigen Darurat',
            amount: widget.additionalFee,
          ),
          const Divider(height: 20, color: AppColors.border),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Biaya',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  DateFormatter.formatCurrency(_totalPrice),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow({required String label, required double amount}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          DateFormatter.formatCurrency(amount),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  // Pernyataan Persetujuan Syarat Layanan
  Widget _buildAgreementCheckbox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _agreedToTerms ? AppColors.primary : AppColors.border,
          width: _agreedToTerms ? 1.5 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Checkbox(
            value: _agreedToTerms,
            activeColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            onChanged: (val) {
              setState(() {
                _agreedToTerms = val ?? false;
              });
            },
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Saya menyatakan bahwa informasi pemesanan di atas sudah benar dan menyetujui syarat layanan AmbulanceCare.',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Tombol Aksi: Kembali & Konfirmasi Pesanan
  Widget _buildActionButtons() {
    return Row(
      children: [
        // Tombol Kembali
        Expanded(
          flex: 1,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              side: const BorderSide(color: AppColors.border),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Kembali',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Tombol Konfirmasi Pesanan
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: (_agreedToTerms && !_isSubmitting)
                ? _confirmAndProceed
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade300,
              disabledForegroundColor: Colors.grey.shade600,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: _agreedToTerms ? 1 : 0,
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Colors.white,
                    ),
                  )
                : const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline_rounded, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Konfirmasi Pesanan',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    VoidCallback? onEdit,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(icon, size: 18, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (onEdit != null)
                InkWell(
                  onTap: onEdit,
                  borderRadius: BorderRadius.circular(6),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.edit_outlined,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Ubah',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    bool isMuted = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 12.5,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12.5,
              color: isMuted ? AppColors.textSecondary : AppColors.textPrimary,
              fontWeight: isMuted ? FontWeight.normal : FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
