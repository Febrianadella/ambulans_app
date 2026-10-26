import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/order_status_helper.dart';
import '../../../../core/widgets/empty_state_card.dart';
import '../../../chat/presentation/pages/chat_room_page.dart';
import '../../data/datasources/booking_remote_datasource.dart';
import '../../data/repositories/booking_repository_impl.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/payment_entity.dart';
import '../../domain/repositories/booking_repository.dart';

class OrderDetailPage extends StatefulWidget {
  final String orderId;
  final BookingRepository? repository;

  const OrderDetailPage({
    super.key,
    required this.orderId,
    this.repository,
  });

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  late BookingRepository _repository;
  OrderEntity? _order;
  PaymentEntity? _payment;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ??
        BookingRepositoryImpl(
          remoteDataSource: BookingRemoteDataSourceImpl(),
        );

    BookingRemoteDataSourceImpl.ordersChangeNotifier.addListener(_onOrderUpdate);
    _loadOrderData();
  }

  @override
  void dispose() {
    BookingRemoteDataSourceImpl.ordersChangeNotifier.removeListener(_onOrderUpdate);
    super.dispose();
  }

  void _onOrderUpdate() {
    if (mounted) {
      _loadOrderData();
    }
  }

  Future<void> _loadOrderData() async {
    try {
      final order = await _repository.getOrderById(widget.orderId);
      final payment = await _repository.getPaymentByOrderId(widget.orderId);
      if (!mounted) return;
      setState(() {
        _order = order;
        _payment = payment;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  bool get _isDriverAssigned {
    if (_order == null) return false;
    final paymentStatus = OrderStatusHelper.getPaymentStatusText(_order!, _payment);
    if (paymentStatus == 'Menunggu Pembayaran' || paymentStatus == 'Menunggu Validasi') {
      return false;
    }
    return _order!.driverId.isNotEmpty && _order!.driverId != 'DVR-NONE';
  }

  void _openChatWithDriver() {
    if (!_isDriverAssigned) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Sopir belum ditugaskan untuk pesanan ini. Fitur chat akan aktif setelah penugasan sopir.',
          ),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatRoomPage(
          orderId: _order!.id,
          driverName: 'Joko Susilo',
          driverPlate: 'AB 1199 MED',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Detail Pesanan',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _order == null
              ? Center(
                  child: EmptyStateCard(
                    icon: Icons.error_outline_rounded,
                    title: 'Pesanan Tidak Ditemukan',
                    message:
                        'Data pesanan #${widget.orderId} tidak tersedia di sistem.',
                    buttonText: 'Kembali',
                    onButtonPressed: () => Navigator.of(context).pop(),
                  ),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final isDesktop = constraints.maxWidth >= 850;
                    return RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: _loadOrderData,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                          horizontal: isDesktop ? 32 : 16,
                          vertical: 18,
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1100),
                            child: isDesktop
                                ? _buildDesktopLayout()
                                : _buildMobileLayout(),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  // Layout Desktop 2 Kolom
  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Kolom Kiri: Tracking Ambulans & Kartu Sopir (hanya jika sopir tersedia)
        Expanded(
          flex: 6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTrackingCard(),
              if (_isDriverAssigned) ...[
                const SizedBox(height: 16),
                _buildDriverCard(),
              ],
            ],
          ),
        ),
        const SizedBox(width: 20),
        // Kolom Kanan: Header Detail & Rincian Pesanan
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeaderDetailCard(),
              const SizedBox(height: 16),
              _buildOrderInfoCard(),
            ],
          ),
        ),
      ],
    );
  }

  // Layout Mobile 1 Kolom Vertikal
  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Header Detail (Nomor Pesanan & Badge Status)
        _buildHeaderDetailCard(),
        const SizedBox(height: 14),

        // 2. Tracking Ambulans / Rute Perjalanan
        _buildTrackingCard(),
        const SizedBox(height: 14),

        // 3. Card Informasi Ambulans dan Sopir (hanya jika sopir tersedia)
        if (_isDriverAssigned) ...[
          _buildDriverCard(),
          const SizedBox(height: 14),
        ],

        // 4. Informasi Pesanan Lengkap (Tanpa Jadwal Layanan)
        _buildOrderInfoCard(),
        const SizedBox(height: 16),
      ],
    );
  }

  // A. Header Detail (Nomor pesanan, Status layanan, Status pembayaran)
  Widget _buildHeaderDetailCard() {
    final order = _order!;
    final serviceBadge = OrderStatusHelper.getServiceBadge(order, _payment);
    final paymentBadge = OrderStatusHelper.getPaymentBadge(order, _payment);

    return Container(
      padding: const EdgeInsets.all(16),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.receipt_long_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Nomor Pesanan',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            '#${order.id}',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Refresh Status',
                icon: const Icon(
                  Icons.refresh_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
                onPressed: _loadOrderData,
              ),
            ],
          ),
          const Divider(height: 20, color: AppColors.border),
          const Text(
            'Status Terkini:',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              serviceBadge,
              paymentBadge,
            ],
          ),
        ],
      ),
    );
  }

  // B. Card Informasi Pesanan (Nomor, Tanggal/Waktu, Total, Status, Lokasi Jemput, Lokasi Tujuan RS)
  Widget _buildOrderInfoCard() {
    final order = _order!;
    final serviceStatusText = OrderStatusHelper.getServiceStatusText(order, _payment);
    final paymentStatusText = OrderStatusHelper.getPaymentStatusText(order, _payment);

    return Container(
      padding: const EdgeInsets.all(16),
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
          const Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 18, color: AppColors.primary),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Informasi Pesanan',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 20, color: AppColors.border),
          _buildInfoRow('Nomor Pesanan', '#${order.id}'),
          _buildInfoRow(
            'Tanggal & Waktu',
            DateFormatter.formatFull(order.createdAt ?? DateTime.now()),
          ),
          if (order.patientName != null && order.patientName!.isNotEmpty)
            _buildInfoRow(
              'Nama Pasien',
              '${order.patientName} (${order.patientAge ?? "-"} thn, ${order.patientGender ?? "-"})',
            ),
          _buildInfoRow('Status Layanan', serviceStatusText),
          _buildInfoRow('Status Pembayaran', paymentStatusText),
          if (order.paymentMethod != null && order.paymentMethod!.isNotEmpty)
            _buildInfoRow('Metode Pembayaran', order.paymentMethod!),
          const Divider(height: 16, color: AppColors.border),
          _buildLocationSection(
            pickup: order.pickupAddress ?? 'Lokasi penjemputan belum ditentukan',
            destination:
                order.destinationAddress ?? 'Rumah sakit rujukan belum ditentukan',
          ),
          const Divider(height: 20, color: AppColors.border),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Total Biaya Layanan',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                DateFormatter.formatCurrency((order.totalPrice ?? 250000).toDouble()),
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection({
    required String pickup,
    required String destination,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.radio_button_checked_rounded,
              color: AppColors.primary,
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Lokasi Penjemputan',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    pickup,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Container(
          margin: const EdgeInsets.only(left: 7),
          height: 18,
          width: 2,
          color: AppColors.border,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.local_hospital_rounded,
              color: AppColors.secondary,
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rumah Sakit Tujuan',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    destination,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // C. Bagian Tracking Perjalanan Ambulans (BEBAS KATA PLACEHOLDER)
  Widget _buildTrackingCard() {
    final order = _order!;
    final serviceText = OrderStatusHelper.getServiceStatusText(order, _payment);
    final paymentText = OrderStatusHelper.getPaymentStatusText(order, _payment);
    final isPaymentValid = paymentText == 'Pembayaran Valid';

    // Tahapan status perjalanan yang realistis
    final currentStep = _getTripStepIndex(order.status, isPaymentValid);

    return Container(
      padding: const EdgeInsets.all(16),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.alt_route_rounded,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tracking Ambulans',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPaymentValid
                      ? AppColors.successLight
                      : AppColors.warningLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      isPaymentValid
                          ? Icons.check_circle_rounded
                          : Icons.access_time_filled_rounded,
                      size: 12,
                      color: isPaymentValid
                          ? AppColors.success
                          : AppColors.warning,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isPaymentValid ? 'Sopir Aktif' : 'Menunggu Validasi',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isPaymentValid
                            ? AppColors.success
                            : AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Banner Status Aktual Perjalanan
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: currentStep == 4
                  ? AppColors.successLight
                  : (isPaymentValid
                      ? AppColors.primaryLight
                      : AppColors.warningLight),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: currentStep == 4
                    ? AppColors.success.withValues(alpha: 0.3)
                    : (isPaymentValid
                        ? AppColors.primary.withValues(alpha: 0.2)
                        : AppColors.warning.withValues(alpha: 0.3)),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: currentStep == 4
                      ? AppColors.success
                      : (isPaymentValid ? AppColors.primary : AppColors.warning),
                  child: Icon(
                    currentStep == 4
                        ? Icons.check_rounded
                        : (isPaymentValid
                            ? Icons.directions_car_rounded
                            : Icons.hourglass_top_rounded),
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        serviceText,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: currentStep == 4
                              ? AppColors.success
                              : (isPaymentValid
                                  ? AppColors.primaryDark
                                  : const Color(0xFFB45309)),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _getStatusExplanation(order.status, isPaymentValid),
                        style: TextStyle(
                          fontSize: 11.5,
                          color: currentStep == 4
                              ? AppColors.success
                              : (isPaymentValid
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Ilustrasi Visual Rute Tracking Ambulans
          _buildRouteIllustration(currentStep, isPaymentValid),
        ],
      ),
    );
  }

  int _getTripStepIndex(OrderStatus status, bool isPaymentValid) {
    if (!isPaymentValid || status == OrderStatus.menungguPembayaran || status == OrderStatus.menungguValidasi) {
      return 0; // Menunggu konfirmasi / validasi
    }
    switch (status) {
      case OrderStatus.menujuLokasi:
        return 1; // Sopir menuju lokasi penjemputan
      case OrderStatus.tibaDiLokasi:
        return 2; // Tiba di penjemputan / pasien dijemput
      case OrderStatus.dalamPerjalanan:
        return 3; // Menuju rumah sakit
      case OrderStatus.layananSelesai:
        return 4; // Layanan selesai di rumah sakit
      default:
        return 0;
    }
  }

  String _getStatusExplanation(OrderStatus status, bool isPaymentValid) {
    if (!isPaymentValid) {
      if (status == OrderStatus.menungguPembayaran) {
        return 'Silakan lakukan pembayaran dan unggah bukti transfer.';
      }
      return 'Bukti pembayaran sedang diverifikasi admin sebelum armada diberangkatkan.';
    }
    switch (status) {
      case OrderStatus.menujuLokasi:
        return 'Ambulans sedang menuju lokasi penjemputan pasien.';
      case OrderStatus.tibaDiLokasi:
        return 'Ambulans telah tiba di lokasi. Tim medis sedang mengevakuasi pasien.';
      case OrderStatus.dalamPerjalanan:
        return 'Ambulans sedang melaju membawa pasien menuju rumah sakit rujukan.';
      case OrderStatus.layananSelesai:
        return 'Pasien telah diserahterimakan ke IGD rumah sakit tujuan.';
      default:
        return 'Armada ambulans siaga bertugas.';
    }
  }

  // Ilustrasi Rute Garis Perjalanan dari Penjemputan ke Rumah Sakit
  Widget _buildRouteIllustration(int currentStep, bool isPaymentValid) {
    final stages = [
      {'title': 'Konfirmasi', 'subtitle': 'Validasi & Penugasan'},
      {'title': 'Menuju Jemput', 'subtitle': 'Perjalanan Sopir'},
      {'title': 'Pasien Dijemput', 'subtitle': 'Penanganan Medis'},
      {'title': 'Menuju RS', 'subtitle': 'Perjalanan ke Faskes'},
      {'title': 'Selesai', 'subtitle': 'Serah Terima Pasien'},
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Alur Tahapan Perjalanan Ambulans',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Tahap ${currentStep + 1} dari 5',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Horizontal Stepper Bar with Ambulance icon
          Row(
            children: List.generate(stages.length, (index) {
              final isPassed = index <= currentStep;
              final isCurrent = index == currentStep;

              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isPassed
                                  ? (index == 4
                                      ? AppColors.success
                                      : AppColors.primary)
                                  : Colors.white,
                              border: Border.all(
                                color: isPassed
                                    ? (index == 4
                                        ? AppColors.success
                                        : AppColors.primary)
                                    : AppColors.border,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: isCurrent && index > 0 && index < 4
                                  ? const Icon(
                                      Icons.airport_shuttle,
                                      size: 12,
                                      color: Colors.white,
                                    )
                                  : (isPassed
                                      ? const Icon(
                                          Icons.check,
                                          size: 13,
                                          color: Colors.white,
                                        )
                                      : Text(
                                          '${index + 1}',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textSecondary,
                                          ),
                                        )),
                            ),
                          ),
                          const SizedBox(height: 4),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              stages[index]['title']!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight:
                                    isCurrent ? FontWeight.bold : FontWeight.w500,
                                color: isCurrent
                                    ? AppColors.primary
                                    : (isPassed
                                        ? AppColors.textPrimary
                                        : AppColors.textSecondary),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (index < stages.length - 1)
                      Container(
                        height: 2,
                        width: 8,
                        color: index < currentStep
                            ? AppColors.primary
                            : AppColors.border,
                        margin: const EdgeInsets.only(bottom: 16),
                      ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // 4. Card Ambulans dan Sopir (Hanya tampil jika sopir ditugaskan)
  Widget _buildDriverCard() {
    if (!_isDriverAssigned) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
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
          const Row(
            children: [
              Icon(
                Icons.local_shipping_outlined,
                size: 18,
                color: AppColors.primary,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Ambulans dan Sopir',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 20, color: AppColors.border),
          Row(
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primaryLight,
                child: Text(
                  'JS',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Joko Susilo',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Sopir Ambulans Utama (Unit Darurat)',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Ambulans GD • Plat: AB 1199 MED',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.verified_user_rounded,
                  color: AppColors.success,
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Tombol Chat dengan Sopir
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _openChatWithDriver,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
              label: const Text(
                'Chat dengan Sopir',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
