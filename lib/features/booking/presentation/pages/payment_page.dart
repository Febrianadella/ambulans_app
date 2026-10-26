// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/booking_repository.dart';
import 'payment_status_page.dart';

class PaymentPage extends StatefulWidget {
  final OrderEntity order;
  final BookingRepository repository;

  const PaymentPage({
    super.key,
    required this.order,
    required this.repository,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String? _selectedMethod; // 'Transfer Bank BCA', 'Transfer Bank Mandiri', 'QRIS'
  String? _proofFileName;
  String? _proofFilePath;
  int? _proofFileSizeBytes; // max 4MB = 4 * 1024 * 1024 bytes
  bool _isSubmitting = false;

  final double _maxFileSizeBytes = 4 * 1024 * 1024; // 4MB

  @override
  void initState() {
    super.initState();
    _selectedMethod = 'Transfer Bank BCA';
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label berhasil disalin ke clipboard!'),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _selectProofFile() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Pilih File Bukti Pembayaran',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Format file: JPG, JPEG, atau PNG (Ukuran maks: 4 MB)',
              style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 18),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.receipt_rounded, color: AppColors.primary),
              ),
              title: const Text('Bukti Struk Transfer Bank (Valid)'),
              subtitle: const Text('File: bukti_transfer_bank.jpg (1.4 MB)'),
              onTap: () {
                Navigator.pop(sheetContext);
                _applyProofFile(
                  name: 'bukti_transfer_bank.jpg',
                  path: 'assets/images/proof_mandiri.jpg',
                  sizeBytes: (1.4 * 1024 * 1024).toInt(),
                );
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.infoLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.qr_code_rounded, color: AppColors.info),
              ),
              title: const Text('Tangkapan Layar Struk QRIS (Valid)'),
              subtitle: const Text('File: receipt_qris_sukses.png (820 KB)'),
              onTap: () {
                Navigator.pop(sheetContext);
                _applyProofFile(
                  name: 'receipt_qris_sukses.png',
                  path: 'assets/images/proof_bca.jpg',
                  sizeBytes: 820 * 1024,
                );
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _applyProofFile({
    required String name,
    required String path,
    required int sizeBytes,
  }) {
    // Validasi Ekstensi File
    final lower = name.toLowerCase();
    final isValidExtension =
        lower.endsWith('.jpg') || lower.endsWith('.jpeg') || lower.endsWith('.png');

    if (!isValidExtension) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Format file tidak didukung. Harap pilih file JPG, JPEG, atau PNG.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Validasi Ukuran File (Maksimal 4 MB)
    if (sizeBytes > _maxFileSizeBytes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ukuran file melebihi batas maksimal 4 MB.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _proofFileName = name;
      _proofFilePath = path;
      _proofFileSizeBytes = sizeBytes;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('File "$name" berhasil dipilih.'),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _removeProofFile() {
    setState(() {
      _proofFileName = null;
      _proofFilePath = null;
      _proofFileSizeBytes = null;
    });
  }

  Future<void> _submitPaymentProof() async {
    if (_selectedMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih salah satu metode pembayaran terlebih dahulu.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_proofFileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan unggah bukti pembayaran yang valid sebelum mengirim.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final payment = await widget.repository.submitPaymentProof(
        widget.order.id,
        _proofFilePath ?? _proofFileName!,
        paymentMethod: _selectedMethod,
        amount: widget.order.totalPrice ?? 200000.0,
      );

      // Perbarui juga status pesanan menjadi menungguValidasi
      final updatedOrder = widget.order.copyWith(
        status: OrderStatus.menungguValidasi,
        paymentMethod: _selectedMethod,
        paymentProofUrl: _proofFilePath ?? _proofFileName,
      );

      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });

      // Arahkan ke Halaman Status Pembayaran
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentStatusPage(
            order: updatedOrder,
            payment: payment,
            repository: widget.repository,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengirim bukti pembayaran: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalPrice = widget.order.totalPrice ?? 200000.0;
    final basePrice = widget.order.basePrice ?? 150000.0;
    final additionalFee = widget.order.additionalFee ?? 50000.0;

    final canSubmit = _selectedMethod != null && _proofFileName != null && !_isSubmitting;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pembayaran Ambulans'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // A. Ringkasan Tagihan
            _buildBillingSummaryCard(
              orderId: widget.order.id,
              basePrice: basePrice,
              additionalFee: additionalFee,
              totalPrice: totalPrice,
            ),
            const SizedBox(height: 18),

            // B. Metode Pembayaran
            _buildPaymentMethodsSection(totalPrice),
            const SizedBox(height: 18),

            // C. Unggah Bukti Pembayaran
            _buildUploadProofSection(),
            const SizedBox(height: 24),

            // Tombol Kirim Bukti Pembayaran
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: canSubmit ? _submitPaymentProof : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  disabledForegroundColor: Colors.grey.shade600,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: canSubmit ? 1 : 0,
                ),
                child: _isSubmitting
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Mengirim Bukti...',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ],
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send_rounded, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Kirim Bukti Pembayaran',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // A. Card Ringkasan Tagihan
  Widget _buildBillingSummaryCard({
    required String orderId,
    required double basePrice,
    required double additionalFee,
    required double totalPrice,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
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
              const Row(
                children: [
                  Icon(
                    Icons.receipt_long_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Ringkasan Tagihan',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              StatusBadge.warning('Belum Dibayar'),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Nomor Pesanan: #$orderId',
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 14),
          _buildBillRow('Tarif Dasar Ambulans', DateFormatter.formatCurrency(basePrice)),
          const SizedBox(height: 6),
          _buildBillRow('Peralatan Medis & O2', DateFormatter.formatCurrency(additionalFee)),
          const Divider(height: 20, color: AppColors.border),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Akhir Tagihan',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                DateFormatter.formatCurrency(totalPrice),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBillRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  // B. Pilihan Metode Pembayaran
  Widget _buildPaymentMethodsSection(double amount) {
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
          const Row(
            children: [
              Icon(Icons.payment_rounded, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'Metode Pembayaran',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Pilih salah satu metode pembayaran yang Anda inginkan:',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),

          // 1. Transfer Bank BCA
          _buildMethodOptionCard(
            title: 'Transfer Bank BCA',
            subtitle: 'No. Rek: 8271-0023-4567\na.n. PT AmbulanceCare Siaga',
            value: 'Transfer Bank BCA',
            accountNumber: '827100234567',
          ),
          const SizedBox(height: 10),

          // 2. Transfer Bank Mandiri
          _buildMethodOptionCard(
            title: 'Transfer Bank Mandiri',
            subtitle: 'No. Rek: 137-00-9876543-2\na.n. PT AmbulanceCare Siaga',
            value: 'Transfer Bank Mandiri',
            accountNumber: '1370098765432',
          ),
          const SizedBox(height: 10),

          // 3. QRIS
          _buildQrisOptionCard(amount),
        ],
      ),
    );
  }

  Widget _buildMethodOptionCard({
    required String title,
    required String subtitle,
    required String value,
    required String accountNumber,
  }) {
    final isSelected = _selectedMethod == value;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedMethod = value;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight.withValues(alpha: 0.35) : AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Radio<String>(
              value: value,
              groupValue: _selectedMethod,
              activeColor: AppColors.primary,
              onChanged: (val) {
                setState(() {
                  _selectedMethod = val;
                });
              },
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppColors.primaryDark : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => _copyToClipboard(accountNumber, title),
              icon: const Icon(Icons.copy_rounded, size: 14),
              label: const Text('Salin', style: TextStyle(fontSize: 11)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.border),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                visualDensity: VisualDensity.compact,
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQrisOptionCard(double amount) {
    final isSelected = _selectedMethod == 'QRIS';

    return InkWell(
      onTap: () {
        setState(() {
          _selectedMethod = 'QRIS';
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight.withValues(alpha: 0.35) : AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Radio<String>(
                  value: 'QRIS',
                  groupValue: _selectedMethod,
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    setState(() {
                      _selectedMethod = val;
                    });
                  },
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'QRIS (Seluruh Bank & E-Wallet)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? AppColors.primaryDark : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'BCA, Mandiri, BRI, BNI, GoPay, OVO, ShopeePay, DANA',
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (isSelected) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.qr_code_2_rounded, color: AppColors.primary, size: 28),
                        SizedBox(width: 8),
                        Text(
                          'QRIS Standar Pembayaran Nasional',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        border: Border.all(color: AppColors.border, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.qr_code_scanner_rounded,
                          size: 96,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'NMID: ID1020304050607 • AmbulanceCare',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Total: ${DateFormatter.formatCurrency(amount)}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // C. Bagian Unggah Bukti Pembayaran
  Widget _buildUploadProofSection() {
    final hasProof = _proofFileName != null;

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
          const Row(
            children: [
              Icon(Icons.cloud_upload_outlined, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'Unggah Bukti Pembayaran',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Unggah struk atau bukti transfer (JPG, JPEG, PNG • Maks 4 MB)',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),

          if (!hasProof)
            InkWell(
              onTap: _selectProofFile,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.border,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 28,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Pilih atau Unggah Bukti Transfer',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Ketuk untuk memilih file struk pembayaran',
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            )
          else
            // Pratinjau File yang Dipilih
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.success.withValues(alpha: 0.5)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Thumbnail preview
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.receipt_long_rounded,
                            color: AppColors.primary,
                            size: 30,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _proofFileName!,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Ukuran: ${((_proofFileSizeBytes ?? 1024 * 1024) / (1024 * 1024)).toStringAsFixed(1)} MB • Valid',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.success,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: AppColors.border),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: _selectProofFile,
                        icon: const Icon(Icons.refresh_rounded, size: 16),
                        label: const Text('Ganti File'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.secondary,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: _removeProofFile,
                        icon: const Icon(Icons.delete_outline_rounded, size: 16),
                        label: const Text('Hapus'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.error,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
