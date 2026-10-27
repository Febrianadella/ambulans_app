import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/empty_state_card.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../booking/data/datasources/booking_remote_datasource.dart';
import '../../../booking/data/repositories/booking_repository_impl.dart';
import '../../../booking/domain/entities/order_entity.dart';
import '../../../booking/domain/repositories/booking_repository.dart';
import '../../../chat/presentation/pages/chat_room_page.dart';
import '../../../tracking/presentation/pages/live_tracking_page.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/order_status_helper.dart';
import '../../../booking/domain/entities/payment_entity.dart';
import '../../../booking/presentation/pages/driver_detail_order_page.dart';

class SopirDashboardPage extends StatefulWidget {
  final BookingRepository? bookingRepository;

  const SopirDashboardPage({super.key, this.bookingRepository});

  @override
  State<SopirDashboardPage> createState() => _SopirDashboardPageState();
}

class _SopirDashboardPageState extends State<SopirDashboardPage> {
  late BookingRepository _repository;
  int _currentNavIndex = 0;
  bool _isAvailable = true;
  bool _hasActiveTask = true;

  // Status perjalanan: 0: Menuju Lokasi, 1: Tiba di Lokasi, 2: Menuju Tujuan, 3: Layanan Selesai
  int _currentTripStep = 0;

  final List<String> _tripSteps = [
    'Menuju lokasi penjemputan',
    'Tiba di lokasi penjemputan',
    'Menuju tujuan (RS/Faskes)',
    'Layanan selesai',
  ];

  // Tambahan State untuk Tab Riwayat
  int _selectedHistoryFilterIndex = 0; // 0: Semua, 1: Berlangsung, 2: Selesai
  List<OrderEntity> _orders = [];
  Map<String, PaymentEntity> _payments = {};
  bool _isLoading = true;

  // Getter untuk memfilter riwayat pesanan/tugas sopir
  List<OrderEntity> get _filteredOrders {
    switch (_selectedHistoryFilterIndex) {
      case 1: // Berlangsung
        return _orders.where((o) => o.status != OrderStatus.layananSelesai).toList();
      case 2: // Selesai
        return _orders.where((o) => o.status == OrderStatus.layananSelesai).toList();
      case 0: // Semua
      default:
        return _orders;
    }
  }

  @override
  void initState() {
    super.initState();
    _repository =
        widget.bookingRepository ??
        BookingRepositoryImpl(remoteDataSource: BookingRemoteDataSourceImpl());

    BookingRemoteDataSourceImpl.ordersChangeNotifier.addListener(
      _syncActiveTask,
    );
    _syncActiveTask();
  }

  @override
  void dispose() {
    BookingRemoteDataSourceImpl.ordersChangeNotifier.removeListener(
      _syncActiveTask,
    );
    super.dispose();
  }

  Future<void> _syncActiveTask() async {
    try {
      // 1. Ambil seluruh data order untuk riwayat
      final orders = await _repository.getAllOrders();
      final Map<String, PaymentEntity> paymentsMap = {};
      for (final order in orders) {
        final payment = await _repository.getPaymentByOrderId(order.id);
        if (payment != null) {
          paymentsMap[order.id] = payment;
        }
      }

      // 2. Ambil task aktif untuk step perjalanan (seperti kode asli Anda)
      final order = await _repository.getOrderById('ORD-20261023-01');
      if (!mounted) return;
      
      setState(() {
        _orders = orders;
        _payments = paymentsMap;
        _isLoading = false;
        
        switch (order.status) {
          case OrderStatus.menujuLokasi:
            _currentTripStep = 0;
            break;
          case OrderStatus.tibaDiLokasi:
            _currentTripStep = 1;
            break;
          case OrderStatus.dalamPerjalanan:
            _currentTripStep = 2;
            break;
          case OrderStatus.layananSelesai:
            _currentTripStep = 3;
            break;
          default:
            _currentTripStep = 0;
        }
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
      // Siklus ulang untuk simulasi pengujian
      nextStatus = OrderStatus.menujuLokasi;
      nextStep = 0;
    }

    setState(() {
      _currentTripStep = nextStep;
    });

    await _repository.updateOrderStatus('ORD-20261023-01', nextStatus);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          nextStep == 3
              ? 'Layanan pesanan #ORD-20261023-01 selesai! Tercatat di riwayat.'
              : 'Status diperbarui: ${_tripSteps[nextStep]}',
        ),
        backgroundColor: nextStep == 3 ? AppColors.success : AppColors.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: switch (_currentNavIndex) {
          0 => _buildHomeTab(context),
          1 => _buildRiwayatTab(context),
          2 => _buildChatTab(context),
          3 => _buildProfilTab(context),
          _ => _buildHomeTab(context),
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentNavIndex,
        onTap: (index) => setState(() => _currentNavIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        backgroundColor: Colors.white,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_rounded),
            label: 'Riwayat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

Widget _buildRouteLine({required String pickup, required String destination}) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.radio_button_checked, color: AppColors.primary, size: 16),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Titik Jemput', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  Text(pickup, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
        Container(margin: const EdgeInsets.only(left: 7), height: 14, width: 2, color: AppColors.border),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.location_on, color: AppColors.secondary, size: 16),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Rumah Sakit / Faskes Tujuan', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  Text(destination, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // A. Main Widget Tab Riwayat
  Widget _buildRiwayatTab(BuildContext context) {
    final filtered = _filteredOrders;
    final totalCount = _orders.length;
    final activeCount = _orders.where((o) => o.status != OrderStatus.layananSelesai).length;
    final completedCount = _orders.where((o) => o.status == OrderStatus.layananSelesai).length;

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _syncActiveTask,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Riwayat
            Container(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.history_rounded, color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Riwayat Penugasan',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Daftar lengkap seluruh tugas dan riwayat perjalanan Anda',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Filter Tab (Semua, Berlangsung, Selesai)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: Row(
                children: [
                  _buildFilterTabItem(title: 'Semua', count: totalCount, index: 0),
                  const SizedBox(width: 8),
                  _buildFilterTabItem(title: 'Berlangsung', count: activeCount, index: 1),
                  const SizedBox(width: 8),
                  _buildFilterTabItem(title: 'Selesai', count: completedCount, index: 2),
                ],
              ),
            ),

            // Daftar Kartu Riwayat
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : filtered.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: EmptyStateCard(
                            icon: Icons.history_rounded,
                            title: 'Belum Ada Penugasan',
                            message: 'Belum ada riwayat tugas ambulans untuk kategori ini.',
                            buttonText: 'Muat Ulang',
                            onButtonPressed: _syncActiveTask,
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filtered.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final order = filtered[index];
                            final payment = _payments[order.id];
                            final serviceBadge = OrderStatusHelper.getServiceBadge(order, payment);
                            final paymentBadge = OrderStatusHelper.getPaymentBadge(order, payment);

                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SopirOrderDetailPage(
                                      orderId: order.id,
                                      repository: _repository,
                                    ),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          DateFormatter.formatFull(order.createdAt ?? DateTime.now()),
                                          style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                                        ),
                                        Text('#${order.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Wrap(spacing: 6, runSpacing: 6, children: [serviceBadge, paymentBadge]),
                                    const SizedBox(height: 12),
                                    _buildRouteLine(
                                      pickup: order.pickupAddress ?? 'Titik Penjemputan',
                                      destination: order.destinationAddress ?? 'Rumah Sakit Tujuan',
                                    ),
                                    const Divider(height: 20),
                                    const Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text('Kelola Tugas', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                        SizedBox(width: 4),
                                        Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.primary),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  // B. Helper Filter Tab Item
  Widget _buildFilterTabItem({required String title, required int count, required int index}) {
    final isSelected = _selectedHistoryFilterIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedHistoryFilterIndex = index),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.w600, color: isSelected ? Colors.white : AppColors.textSecondary),
              ),
              const SizedBox(width: 4),
              Text('($count)', style: TextStyle(fontSize: 10, color: isSelected ? Colors.white : AppColors.textPrimary)),
            ],
          ),
        ),
      ),
    );
  }

  // C. Placeholder Tab Chat & Profil (jika belum ada)
  Widget _buildChatTab(BuildContext context) => const Center(child: Text('Halaman Chat Sopir'));
  Widget _buildProfilTab(BuildContext context) => const Center(child: Text('Halaman Profil Sopir'));

  Widget _buildHomeTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header: Sapaan, Nama Sopir, Notifikasi
          _buildHeader(),
          const SizedBox(height: 14),

          // 2. Badge Status Sopir (Tersedia / Sedang Bertugas) dengan Toggle
          _buildDriverStatusBadgeCard(),
          const SizedBox(height: 16),

          // 3. Tiga Kartu Ringkasan
          _buildThreeSummaryCards(),
          const SizedBox(height: 18),

          // 4, 5 & 6. Card "Tugas Aktif", Peta Navigasi, dan Tombol Pembaruan Status
          _buildActiveTaskSection(context),
          const SizedBox(height: 20),

          // 7. Daftar Tugas Terbaru
          _buildRecentTasksSection(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // 1. Header
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const CircleAvatar(
              radius: 22,
              backgroundColor: Color(0xFFFFEBEE),
              child: Icon(
                Icons.drive_eta_rounded,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Siap Siaga Bertugas,',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  'Joko Susilo',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
        IconButton(
          icon: const Icon(
            Icons.notifications_none_rounded,
            color: AppColors.textPrimary,
          ),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tidak ada notifikasi darurat baru'),
              ),
            );
          },
        ),
      ],
    );
  }

  // 2. Badge Status Sopir
  Widget _buildDriverStatusBadgeCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: _isAvailable ? AppColors.success : AppColors.warning,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Status Kesiapan Sopir',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    _isAvailable
                        ? 'Tersedia untuk Penugasan'
                        : 'Sedang Bertugas di Lapangan',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: _isAvailable
                          ? AppColors.success
                          : AppColors.warning,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Switch.adaptive(
            value: _isAvailable,
            activeTrackColor: AppColors.success.withValues(alpha: 0.5),
            activeThumbColor: AppColors.success,
            onChanged: (val) {
              setState(() {
                _isAvailable = val;
              });
            },
          ),
        ],
      ),
    );
  }

  // 3. Tiga Kartu Ringkasan
  Widget _buildThreeSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            title: 'Tugas Aktif',
            value: _hasActiveTask ? '1' : '0',
            icon: Icons.emergency_rounded,
            color: AppColors.primary,
            subtitle: _hasActiveTask ? 'Prioritas Tinggi' : 'Siap terima',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: StatCard(
            title: 'Tugas Selesai',
            value: '4',
            icon: Icons.check_circle_outline_rounded,
            color: AppColors.success,
            subtitle: 'Hari ini',
          ),
        ),
      ],
    );
  }

  // 4, 5 & 6. Card Tugas Aktif, Peta Navigasi, dan Tombol Tindakan Status
  Widget _buildActiveTaskSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Tugas Aktif Saat Ini',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() => _hasActiveTask = !_hasActiveTask);
              },
              child: Text(
                _hasActiveTask ? 'Tugas Selesai' : 'Tugas Aktif',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        if (!_hasActiveTask)
          EmptyStateCard(
            icon: Icons.event_available_rounded,
            title: 'Belum ada tugas aktif',
            message: 'Tetap stanby di pangkalan ambulans. Penugasan baru dari call center akan muncul di sini.',
            buttonText: 'Cek Kesiapan Armada',
            onButtonPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Armada AB 1199 MED dalam kondisi prima & siap jalan.',
                  ),
                ),
              );
            },
          )
        else
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 4. Nomor Pesanan & Status Perjalanan
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '#ORD-20261023-01',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    StatusBadge.warning(
                      _tripSteps[_currentTripStep],
                      icon: Icons.navigation_rounded,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Lokasi Penjemputan & Tujuan
                _buildRouteRow(
                  pickup: 'Jl. Malioboro No. 42 (Bpk. Budi Pratama)',
                  destination: 'IGD RSUP Dr. Sardjito, Yogyakarta',
                ),
                const SizedBox(height: 14),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SopirOrderDetailPage(
                            orderId: 'ORD-20261023-01',
                            repository: _repository,
                          ),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.visibility_rounded, size: 16),
                    label: const Text(
                      'Lihat Detail Lengkap Tugas',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ),
                
                const SizedBox(height: 14),
              ],
            ),
          ),
      ],
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

  Widget _buildRouteRow({required String pickup, required String destination}) {
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.trip_origin, size: 14, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Jemput: $pickup',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(Icons.location_on, size: 14, color: AppColors.secondary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Tujuan: $destination',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 7. Daftar Tugas Terbaru
  Widget _buildRecentTasksSection() {
    final finishedTasks = [
      {
        'id': '#ORD-20261023-00',
        'time': '07:15 WIB',
        'route': 'Kotagede -> RSUD Wirosaban',
        'status': 'Selesai',
      },
      {
        'id': '#ORD-20261022-09',
        'time': 'Kemarin 21:40',
        'route': 'Condongcatur -> RS JIH',
        'status': 'Selesai',
      },
      {
        'id': '#ORD-20261022-06',
        'time': 'Kemarin 16:20',
        'route': 'Bantul -> RS PKU Bantul',
        'status': 'Selesai',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Daftar Tugas Terbaru Hari Ini',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        ...finishedTasks.map((t) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t['id']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      t['route']!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    StatusBadge.success(t['status']!),
                    const SizedBox(height: 2),
                    Text(
                      t['time']!,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildOtherTab(BuildContext context) {
    final titles = [
      'Beranda',
      'Riwayat Tugas',
      'Chat Komunikasi',
      'Profil Sopir',
    ];
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titles[_currentNavIndex],
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          EmptyStateCard(
            icon: Icons.assignment_outlined,
            title: 'Menu ${titles[_currentNavIndex]}',
            message:
                'Daftar data ${titles[_currentNavIndex]} tersimpan di sistem.',
            buttonText: 'Kembali ke Dashboard',
            onButtonPressed: () {
              setState(() => _currentNavIndex = 0);
            },
          ),
        ],
      ),
    );
  }
}