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
      final order = await _repository.getOrderById('ORD-20261023-01');
      if (!mounted) return;
      setState(() {
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
    } catch (_) {}
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
        child: _currentNavIndex == 0
            ? _buildHomeTab(context)
            : _buildOtherTab(context),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() {
            _currentNavIndex = index;
          });
        },
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
