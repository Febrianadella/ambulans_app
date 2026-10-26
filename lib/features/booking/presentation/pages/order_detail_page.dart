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
import '../../../tracking/presentation/widgets/driver_info_card.dart';
import '../../../tracking/presentation/widgets/live_tracking_map_view.dart';
import '../../../tracking/presentation/widgets/route_location_card.dart';
import '../../../tracking/presentation/widgets/trip_info_card.dart';
import '../../../tracking/presentation/widgets/trip_progress_stepper.dart';

class OrderDetailPage extends StatefulWidget {
  final String orderId;
  final BookingRepository? repository;

  const OrderDetailPage({super.key, required this.orderId, this.repository});

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
    _repository =
        widget.repository ??
        BookingRepositoryImpl(remoteDataSource: BookingRemoteDataSourceImpl());

    BookingRemoteDataSourceImpl.ordersChangeNotifier.addListener(
      _onOrderUpdate,
    );
    _loadOrderData();
  }

  @override
  void dispose() {
    BookingRemoteDataSourceImpl.ordersChangeNotifier.removeListener(
      _onOrderUpdate,
    );
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
    final paymentStatus = OrderStatusHelper.getPaymentStatusText(
      _order!,
      _payment,
    );
    if (paymentStatus == 'Menunggu Pembayaran' ||
        paymentStatus == 'Menunggu Validasi') {
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
                      horizontal: isDesktop ? 32 : 14,
                      vertical: isDesktop ? 18 : 10,
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
    final order = _order!;
    final paymentText = OrderStatusHelper.getPaymentStatusText(order, _payment);
    final isPaymentValid = paymentText == 'Pembayaran Valid';
    final currentStep = _getTripStepIndex(order.status, isPaymentValid);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Kolom Kiri: Tracking Ambulans, Info Perjalanan, & Stepper
        Expanded(
          flex: 6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTrackingCard(isDesktop: true),
              const SizedBox(height: 16),
              TripInfoCard(
                status: order.status,
                isPaymentValid: isPaymentValid,
              ),
              const SizedBox(height: 16),
              TripProgressStepper(currentStep: currentStep),
            ],
          ),
        ),
        const SizedBox(width: 20),
        // Kolom Kanan: Header Detail, Kartu Sopir, Kartu Rute, & Rincian Pesanan
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeaderDetailCard(),
              if (_isDriverAssigned) ...[
                const SizedBox(height: 16),
                _buildDriverCard(),
              ],
              const SizedBox(height: 16),
              RouteLocationCard(
                pickupAddress:
                    order.pickupAddress ??
                    'Lokasi penjemputan belum ditentukan',
                destinationAddress:
                    order.destinationAddress ??
                    'Rumah sakit rujukan belum ditentukan',
              ),
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
    final order = _order!;
    final paymentText = OrderStatusHelper.getPaymentStatusText(order, _payment);
    final isPaymentValid = paymentText == 'Pembayaran Valid';
    final currentStep = _getTripStepIndex(order.status, isPaymentValid);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Header Detail (Nomor Pesanan & Badge Status)
        _buildHeaderDetailCard(),
        const SizedBox(height: 10),

        // 2. Kartu Utama Live Tracking Ambulans dengan Area Peta
        _buildTrackingCard(),
        const SizedBox(height: 10),

        // 3. Kartu Informasi Sopir dan Armada (Hanya tampil jika sopir ditugaskan)
        if (_isDriverAssigned) ...[
          _buildDriverCard(),
          const SizedBox(height: 10),
        ],

        // 4. Kartu Informasi Perjalanan (Estimasi Kedatangan, Jarak, Status, Catatan Simulasi)
        TripInfoCard(status: order.status, isPaymentValid: isPaymentValid),
        const SizedBox(height: 10),

        // 5. Kartu Rute Perjalanan (Lokasi Penjemputan -> RS Tujuan)
        RouteLocationCard(
          pickupAddress:
              order.pickupAddress ?? 'Lokasi penjemputan belum ditentukan',
          destinationAddress:
              order.destinationAddress ??
              'Rumah sakit rujukan belum ditentukan',
        ),
        const SizedBox(height: 10),

        // 6. Tahapan Perjalanan Ambulans (Stepper 5 Tahap)
        TripProgressStepper(currentStep: currentStep),
        const SizedBox(height: 10),

        // 7. Informasi Pesanan Lengkap & Total Biaya
        _buildOrderInfoCard(),
        const SizedBox(height: 14),
      ],
    );
  }

  // A. Header Detail (Nomor pesanan, Status layanan, Status pembayaran)
  Widget _buildHeaderDetailCard() {
    final order = _order!;
    final serviceBadge = OrderStatusHelper.getServiceBadge(order, _payment);
    final paymentBadge = OrderStatusHelper.getPaymentBadge(order, _payment);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
          const Divider(height: 14, color: AppColors.border),
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
            children: [serviceBadge, paymentBadge],
          ),
        ],
      ),
    );
  }

  // B. Card Informasi Pesanan (Nomor, Tanggal/Waktu, Total, Status, Lokasi Jemput, Lokasi Tujuan RS)
  Widget _buildOrderInfoCard() {
    final order = _order!;
    final serviceStatusText = OrderStatusHelper.getServiceStatusText(
      order,
      _payment,
    );
    final paymentStatusText = OrderStatusHelper.getPaymentStatusText(
      order,
      _payment,
    );

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
                Icons.info_outline_rounded,
                size: 18,
                color: AppColors.primary,
              ),
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
            pickup:
                order.pickupAddress ?? 'Lokasi penjemputan belum ditentukan',
            destination:
                order.destinationAddress ??
                'Rumah sakit rujukan belum ditentukan',
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
                DateFormatter.formatCurrency(
                  (order.totalPrice ?? 250000).toDouble(),
                ),
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

  // C. Bagian Live Tracking Ambulans
  Widget _buildTrackingCard({bool isDesktop = false}) {
    final order = _order!;
    final serviceText = OrderStatusHelper.getServiceStatusText(order, _payment);
    final paymentText = OrderStatusHelper.getPaymentStatusText(order, _payment);
    final isPaymentValid = paymentText == 'Pembayaran Valid';

    // Status badge teks
    String statusBadge;
    if (!isPaymentValid) {
      statusBadge = 'Menunggu Validasi';
    } else {
      switch (order.status) {
        case OrderStatus.menujuLokasi:
          statusBadge = 'Ambulans Menuju Lokasi';
          break;
        case OrderStatus.tibaDiLokasi:
          statusBadge = 'Tiba di Penjemputan';
          break;
        case OrderStatus.dalamPerjalanan:
          statusBadge = 'Menuju Rumah Sakit';
          break;
        case OrderStatus.layananSelesai:
          statusBadge = 'Layanan Selesai';
          break;
        default:
          statusBadge = serviceText;
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Kartu Tracking
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.airport_shuttle_rounded,
                        color: AppColors.primary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Flexible(
                                child: Text(
                                  'Live Tracking Ambulans',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 5),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 1.5,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 5,
                                      height: 5,
                                      decoration: const BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 3),
                                    const Text(
                                      'LIVE',
                                      style: TextStyle(
                                        fontSize: 8.5,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.primary,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Tracking Ambulans',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3.5,
                        ),
                        decoration: BoxDecoration(
                          color: isPaymentValid
                              ? AppColors.primaryLight
                              : AppColors.warningLight,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isPaymentValid
                                ? AppColors.primary.withValues(alpha: 0.3)
                                : AppColors.warning.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isPaymentValid
                                  ? Icons.navigation_rounded
                                  : Icons.access_time_filled_rounded,
                              size: 11,
                              color: isPaymentValid
                                  ? AppColors.primary
                                  : AppColors.warning,
                            ),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                statusBadge,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isPaymentValid
                                      ? AppColors.primaryDark
                                      : AppColors.warning,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Pantau perjalanan ambulans menuju lokasi penjemputan Anda.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),

          // Area Peta Visual Interaktif
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            child: LiveTrackingMapView(
              status: order.status,
              isPaymentValid: isPaymentValid,
              height: isDesktop ? 320 : 150,
              pickupAddress: order.pickupAddress ?? 'Lokasi Penjemputan',
              destinationAddress:
                  order.destinationAddress ?? 'Rumah Sakit Tujuan',
            ),
          ),
        ],
      ),
    );
  }

  int _getTripStepIndex(OrderStatus status, bool isPaymentValid) {
    if (!isPaymentValid ||
        status == OrderStatus.menungguPembayaran ||
        status == OrderStatus.menungguValidasi) {
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

  // 4. Card Ambulans dan Sopir (Hanya tampil jika sopir ditugaskan)
  Widget _buildDriverCard() {
    return DriverInfoCard(
      isDriverAssigned: _isDriverAssigned,
      onChatPressed: _openChatWithDriver,
    );
  }
}
