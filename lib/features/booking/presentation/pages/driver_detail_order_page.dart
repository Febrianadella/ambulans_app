import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/order_status_helper.dart';
import '../../../../core/widgets/empty_state_card.dart';
import '../../../booking/data/datasources/booking_remote_datasource.dart';
import '../../../booking/data/repositories/booking_repository_impl.dart';
import '../../../booking/domain/entities/order_entity.dart';
import '../../../booking/domain/entities/payment_entity.dart';
import '../../../booking/domain/repositories/booking_repository.dart';
import '../../../chat/presentation/pages/chat_room_page.dart';
import '../../../tracking/presentation/widgets/live_tracking_map_view.dart';
import '../../../tracking/presentation/widgets/route_location_card.dart';
import '../../../tracking/presentation/widgets/trip_info_card.dart';
import '../../../tracking/presentation/widgets/trip_progress_stepper.dart';

class SopirOrderDetailPage extends StatefulWidget {
  final String orderId;
  final BookingRepository? repository;

  const SopirOrderDetailPage({
    super.key,
    required this.orderId,
    this.repository,
  });

  @override
  State<SopirOrderDetailPage> createState() => _SopirOrderDetailPageState();
}

class _SopirOrderDetailPageState extends State<SopirOrderDetailPage> {
  late BookingRepository _repository;
  OrderEntity? _order;
  PaymentEntity? _payment;
  bool _isLoading = true;

  // Status perjalanan khusus sopir: 0: Menuju Lokasi, 1: Tiba di Lokasi, 2: Menuju Tujuan, 3: Layanan Selesai
  int _currentTripStep = 0;
  final List<String> _tripSteps = [
    'Menuju lokasi penjemputan',
    'Tiba di lokasi penjemputan',
    'Menuju tujuan (RS/Faskes)',
    'Layanan selesai',
  ];

  @override
  void initState() {
    super.initState();
    _repository =
        widget.repository ??
        BookingRepositoryImpl(remoteDataSource: BookingRemoteDataSourceImpl());

    BookingRemoteDataSourceImpl.ordersChangeNotifier.addListener(_fetchOrderDetail);
    _fetchOrderDetail();
  }

  @override
  void dispose() {
    BookingRemoteDataSourceImpl.ordersChangeNotifier.removeListener(_fetchOrderDetail);
    super.dispose();
  }

  Future<void> _fetchOrderDetail() async {
    try {
      final order = await _repository.getOrderById(widget.orderId);
      final payment = await _repository.getPaymentByOrderId(widget.orderId);

      int step = 0;
      switch (order.status) {
        case OrderStatus.menujuLokasi:
          step = 0;
          break;
        case OrderStatus.tibaDiLokasi:
          step = 1;
          break;
        case OrderStatus.dalamPerjalanan:
          step = 2;
          break;
        case OrderStatus.layananSelesai:
          step = 3;
          break;
        default:
          step = 0;
      }

      if (!mounted) return;
      setState(() {
        _order = order;
        _payment = payment;
        _currentTripStep = step;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _advanceTripStatus() async {
    OrderStatus nextStatus;
    int nextStep;

    if (_currentTripStep == 0) {
      nextStatus = OrderStatus.tibaDiLokasi;
      nextStep = 1;
    } else if (_currentTripStep == 1) {
      nextStatus = OrderStatus.dalamPerjalanan;
      nextStep = 2;
    } else if (_currentTripStep == 2) {
      nextStatus = OrderStatus.layananSelesai;
      nextStep = 3;
    } else {
      nextStatus = OrderStatus.menujuLokasi;
      nextStep = 0;
    }

    setState(() {
      _currentTripStep = nextStep;
    });

    await _repository.updateOrderStatus(widget.orderId, nextStatus);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          nextStep == 3
              ? 'Layanan pesanan #${widget.orderId} selesai!'
              : 'Status diperbarui: ${_tripSteps[nextStep]}',
        ),
        backgroundColor: nextStep == 3 ? AppColors.success : AppColors.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  int _getTripStepIndex(OrderStatus status, bool isPaymentValid) {
    if (!isPaymentValid ||
        status == OrderStatus.menungguPembayaran ||
        status == OrderStatus.menungguValidasi) {
      return 0;
    }
    switch (status) {
      case OrderStatus.menujuLokasi:
        return 1;
      case OrderStatus.tibaDiLokasi:
        return 2;
      case OrderStatus.dalamPerjalanan:
        return 3;
      case OrderStatus.layananSelesai:
        return 4;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0.5,
        title: Text(
          'Tugas Penugasan #${widget.orderId}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh Status',
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary, size: 20),
            onPressed: _fetchOrderDetail,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _order == null
              ? Padding(
                  padding: const EdgeInsets.all(20),
                  child: EmptyStateCard(
                    icon: Icons.error_outline_rounded,
                    title: 'Tugas Tidak Ditemukan',
                    message: 'Data pesanan #${widget.orderId} tidak tersedia.',
                    buttonText: 'Kembali',
                    onButtonPressed: () => Navigator.pop(context),
                  ),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final isDesktop = constraints.maxWidth >= 850;
                    return RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: _fetchOrderDetail,
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
    final currentStepIndex = _getTripStepIndex(order.status, isPaymentValid);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Kolom Kiri: Peta Live, Info Perjalanan, & Stepper (POV Driver)
        Expanded(
          flex: 6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildDriverTrackingCard(isDesktop: true),
              const SizedBox(height: 16),
              TripInfoCard(
                status: order.status,
                isPaymentValid: isPaymentValid,
              ),
              const SizedBox(height: 16),
              TripProgressStepper(currentStep: currentStepIndex),
            ],
          ),
        ),
        const SizedBox(width: 20),
        // Kolom Kanan: Status Card, Rute, Info Pasien, & Aksi Sopir
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildStatusCard(),
              const SizedBox(height: 16),
              RouteLocationCard(
                pickupAddress: order.pickupAddress ?? 'Lokasi penjemputan belum ditentukan',
                destinationAddress: order.destinationAddress ?? 'Rumah sakit rujukan belum ditentukan',
              ),
              const SizedBox(height: 16),
              _buildPatientInfoCard(context),
              const SizedBox(height: 16),
              _buildTripActionCard(),
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
    final currentStepIndex = _getTripStepIndex(order.status, isPaymentValid);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Status Layanan & Badge
        _buildStatusCard(),
        const SizedBox(height: 10),

        // 2. Live Tracking Map Interaktif (POV Driver)
        _buildDriverTrackingCard(),
        const SizedBox(height: 10),

        // 3. Informasi Perjalanan & Estimasi
        TripInfoCard(status: order.status, isPaymentValid: isPaymentValid),
        const SizedBox(height: 10),

        // 4. Rute Perjalanan Darurat
        RouteLocationCard(
          pickupAddress: order.pickupAddress ?? 'Lokasi penjemputan belum ditentukan',
          destinationAddress: order.destinationAddress ?? 'Rumah sakit rujukan belum ditentukan',
        ),
        const SizedBox(height: 10),

        // 5. Stepper Progres Perjalanan
        TripProgressStepper(currentStep: currentStepIndex),
        const SizedBox(height: 10),

        // 6. Informasi Pemesan & Pasien
        _buildPatientInfoCard(context),
        const SizedBox(height: 10),

        // 7. Tombol Aksi Sopir (Ubah Status)
        _buildTripActionCard(),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Status Tugas Saat Ini',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 4),
              Text(
                _tripSteps[_currentTripStep],
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          OrderStatusHelper.getServiceBadge(_order!, _payment),
        ],
      ),
    );
  }

  // Widget Peta Live Tracking disesuaikan khusus POV Driver
  // (Titik Biru = Lokasi Pasien/Penjemputan, Titik Merah = Rumah Sakit Tujuan)
  Widget _buildDriverTrackingCard({bool isDesktop = false}) {
    final order = _order!;
    final paymentText = OrderStatusHelper.getPaymentStatusText(order, _payment);
    final isPaymentValid = paymentText == 'Pembayaran Valid';

    String statusBadge;
    String trackingDescription;

    switch (order.status) {
      case OrderStatus.menujuLokasi:
        statusBadge = 'Menuju Lokasi Pasien';
        trackingDescription = 'Hidupkan sirine sebagai tanda darurat untuk lebih cepat mencapai tujuan.';
        break;
      case OrderStatus.tibaDiLokasi:
        statusBadge = 'Tiba di Penjemputan';
        trackingDescription = 'Anda sudah berada di lokasi pasien. Silakan bersiap membawa pasien.';
        break;
      case OrderStatus.dalamPerjalanan:
        statusBadge = 'Menuju Rumah Sakit';
        trackingDescription = 'Titik merah adalah rumah sakit tujuan rujukan pasien.';
        break;
      case OrderStatus.layananSelesai:
        statusBadge = 'Layanan Selesai';
        trackingDescription = 'Seluruh rangkaian tugas penugasan telah selesai.';
        break;
      default:
        statusBadge = 'Penugasan Aktif';
        trackingDescription = 'Pantau rute tugas darurat secara real-time.';
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
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.navigation_rounded, color: AppColors.primary, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Navigasi Peta Tugas',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        statusBadge,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  trackingDescription,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
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
              height: isDesktop ? 320 : 180,
              pickupAddress: order.pickupAddress ?? 'Lokasi Penjemputan Pasien',
              destinationAddress: order.destinationAddress ?? 'Rumah Sakit Tujuan',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientInfoCard(BuildContext context) {
    final order = _order!;
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
            'Informasi Pemesan & Pasien',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.person_outline_rounded, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(
                'Pasien: ${order.patientName ?? "Budi Pratama"} (${order.patientAge ?? "-"} thn)',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const Divider(height: 20, color: AppColors.border),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Hubungi Pemesan via Chat', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              IconButton(
                icon: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.primary, size: 20),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatRoomPage(
                        orderId: widget.orderId,
                        patientName: order.patientName ?? 'Budi Pratama',
                        isFromDriver: true,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTripActionCard() {
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
            'Perbarui Status Perjalanan',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _advanceTripStatus,
              style: ElevatedButton.styleFrom(
                backgroundColor: _currentTripStep == 3 ? AppColors.success : AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: Icon(
                _currentTripStep == 3 ? Icons.check_circle_rounded : Icons.update_rounded,
                size: 16,
              ),
              label: Text(
                _getNextStepActionText(),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getNextStepActionText() {
    switch (_currentTripStep) {
      case 0:
        return 'Konfirmasi: Tiba di Penjemputan';
      case 1:
        return 'Konfirmasi: Menuju Faskes/RS';
      case 2:
        return 'Konfirmasi: Layanan Selesai';
      case 3:
      default:
        return 'Tutup Tugas & Siap Tugas Baru';
    }
  }
}