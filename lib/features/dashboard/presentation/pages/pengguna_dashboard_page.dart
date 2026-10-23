import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/empty_state_card.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../booking/presentation/pages/booking_page.dart';
import '../../../chat/presentation/pages/chat_room_page.dart';
import '../../../rating/presentation/pages/rating_page.dart';
import '../../../tracking/presentation/pages/live_tracking_page.dart';

class PenggunaDashboardPage extends StatefulWidget {
  const PenggunaDashboardPage({super.key});

  @override
  State<PenggunaDashboardPage> createState() => _PenggunaDashboardPageState();
}

class _PenggunaDashboardPageState extends State<PenggunaDashboardPage> {
  int _currentNavIndex = 0;
  bool _hasActiveOrder = true; // Toggleable for testing empty state

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
            icon: Icon(Icons.home_rounded),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_rounded),
            label: 'Pesanan',
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
          // 1. Header: Sapaan, Nama Pengguna, Avatar, Notifikasi
          _buildHeader(),
          const SizedBox(height: 16),

          // 2. Card Utama: "Butuh Ambulans?" dan tombol merah "Pesan Ambulans"
          _buildEmergencyCard(context),
          const SizedBox(height: 16),

          // 3. Ringkasan Lokasi Pengguna
          _buildUserLocationSummary(),
          const SizedBox(height: 16),

          // 4 & 5. Card "Pesanan Aktif" dan Informasi Sopir & Ambulans
          _buildActiveOrderSection(context),
          const SizedBox(height: 20),

          // 6. Daftar Maksimal Tiga Pesanan Terakhir
          _buildRecentOrdersSection(context),
          const SizedBox(height: 20),

          // 7. Notifikasi Terbaru
          _buildLatestNotificationsSection(),
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
              backgroundColor: AppColors.primaryLight,
              child: Icon(Icons.person, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selamat Pagi,',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  'Budi Pratama',
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
        Stack(
          children: [
            IconButton(
              icon: const Icon(
                Icons.notifications_none_rounded,
                color: AppColors.textPrimary,
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Notifikasi terbaru telah dibaca'),
                  ),
                );
              },
            ),
            Positioned(
              right: 12,
              top: 10,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 2. Card Utama
  Widget _buildEmergencyCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
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
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.emergency_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Butuh Ambulans?',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Layanan cepat darurat 24 jam ke faskes terdekat',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BookingPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.add_location_alt_rounded, size: 18),
              label: const Text(
                'Pesan Ambulans Sekarang',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 3. Ringkasan Lokasi Pengguna
  Widget _buildUserLocationSummary() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.infoLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.my_location_rounded,
              color: AppColors.info,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Lokasi Anda Saat Ini',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 6),
                    Text(
                      '• GPS Aktif',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2),
                Text(
                  'Jl. Malioboro No. 42, Danurejan, Yogyakarta',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: AppColors.textSecondary,
            size: 20,
          ),
        ],
      ),
    );
  }

  // 4 & 5. Card Pesanan Aktif + Info Sopir & Ambulans
  Widget _buildActiveOrderSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Pesanan Aktif',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            // Toggle testing button to simulate empty state
            TextButton(
              onPressed: () {
                setState(() {
                  _hasActiveOrder = !_hasActiveOrder;
                });
              },
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
              ),
              child: Text(
                _hasActiveOrder ? 'Simulasi Kosong' : 'Simulasi Aktif',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (!_hasActiveOrder)
          EmptyStateCard(
            icon: Icons.local_shipping_outlined,
            title: 'Belum ada pesanan aktif',
            message: 'Saat ini Anda tidak memiliki panggilan ambulans yang sedang berjalan.',
            buttonText: 'Pesan Ambulans',
            buttonIcon: Icons.add,
            onButtonPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BookingPage()),
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
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nomor Pesanan & Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '#ORD-20261023-01',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    StatusBadge.warning(
                      'Menuju Lokasi',
                      icon: Icons.navigation_rounded,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Detail Penjemputan & Tujuan
                _buildRouteLine(
                  pickup: 'Jl. Malioboro No. 42, Yogyakarta',
                  destination: 'RSUP Dr. Sardjito, Sleman',
                ),
                const Divider(height: 24, color: AppColors.border),

                // 5. Informasi Sopir dan Ambulans yang Ditugaskan
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.secondaryLight,
                      child: Icon(
                        Icons.airline_seat_recline_normal,
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Joko Susilo (Sopir)',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Ambulans GD • Plat: AB 1199 MED',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.chat_outlined,
                        color: AppColors.secondary,
                        size: 20,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const ChatRoomPage(orderId: 'ORD-20261023-01'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Tombol Lacak Ambulans
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LiveTrackingPage(
                            orderId: 'ORD-20261023-01',
                          ),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(
                      Icons.location_searching_rounded,
                      size: 16,
                    ),
                    label: const Text(
                      'Lacak Ambulans Real-Time',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildRouteLine({
    required String pickup,
    required String destination,
  }) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.radio_button_checked,
              color: AppColors.primary,
              size: 16,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Titik Jemput',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    pickup,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Container(
          margin: const EdgeInsets.only(left: 7),
          height: 14,
          width: 2,
          color: AppColors.border,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.location_on, color: AppColors.secondary, size: 16),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tujuan Faskes',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    destination,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
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

  // 6. Daftar Maksimal Tiga Pesanan Terakhir
  Widget _buildRecentOrdersSection(BuildContext context) {
    final recentOrders = [
      {
        'id': '#ORD-20261015-04',
        'date': '15 Okt 2026',
        'destination': 'RS PKU Muhammadiyah',
        'price': 'Rp 250.000',
        'status': 'Layanan Selesai',
        'rated': true,
      },
      {
        'id': '#ORD-20260928-02',
        'date': '28 Sep 2026',
        'destination': 'RS Siloam Yogyakarta',
        'price': 'Rp 300.000',
        'status': 'Layanan Selesai',
        'rated': false,
      },
      {
        'id': '#ORD-20260910-01',
        'date': '10 Sep 2026',
        'destination': 'RS Bethesda',
        'price': 'Rp 200.000',
        'status': 'Layanan Selesai',
        'rated': true,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Riwayat Pesanan Terakhir',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() => _currentNavIndex = 2);
              },
              child: const Text(
                'Lihat Semua',
                style: TextStyle(fontSize: 12, color: AppColors.secondary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ...recentOrders.map((order) {
          final isRated = order['rated'] as bool;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
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
                      order['id'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${order['destination']} • ${order['date']}',
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
                    StatusBadge.success(order['status'] as String),
                    const SizedBox(height: 4),
                    if (!isRated)
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  RatingPage(orderId: order['id'] as String),
                            ),
                          );
                        },
                        child: const Text(
                          'Beri Ulasan ⭐',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
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

  // 7. Notifikasi Terbaru
  Widget _buildLatestNotificationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Notifikasi Terbaru',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              _buildNotificationItem(
                icon: Icons.check_circle_outline,
                color: AppColors.success,
                title: 'Pembayaran Divalidasi Admin',
                time: '15 menit lalu',
                desc: 'Bukti transfer pesanan #ORD-20261023-01 telah diverifikasi.',
              ),
              const Divider(height: 20, color: AppColors.border),
              _buildNotificationItem(
                icon: Icons.directions_car_filled_outlined,
                color: AppColors.primary,
                title: 'Ambulans Bergerak ke Titik Jemput',
                time: '20 menit lalu',
                desc: 'Sopir Joko Susilo sedang menuju Jl. Malioboro No. 42.',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required Color color,
    required String title,
    required String time,
    required String desc,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOtherTab(BuildContext context) {
    final titles = [
      'Beranda',
      'Daftar Pesanan',
      'Riwayat Lengkap',
      'Chat Layanan',
      'Profil Pengguna',
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
            icon: _currentNavIndex == 3
                ? Icons.chat_bubble_outline
                : Icons.folder_open_outlined,
            title: 'Halaman ${titles[_currentNavIndex]}',
            message:
                'Menu navigasi ${titles[_currentNavIndex]} siap digunakan dalam alur aplikasi.',
            buttonText: 'Kembali ke Beranda',
            onButtonPressed: () {
              setState(() => _currentNavIndex = 0);
            },
          ),
        ],
      ),
    );
  }
}
