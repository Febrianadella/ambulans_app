import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../../core/widgets/status_badge.dart';
import 'llm_analysis_detail_page.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
String _selectedSidebarMenu = 'Beranda';

  final List<Map<String, dynamic>> _sidebarItems = [
    {'title': 'Beranda', 'icon': Icons.dashboard_outlined},
    {'title': 'Pesanan', 'icon': Icons.shopping_bag_outlined},
    {'title': 'Data Ambulans', 'icon': Icons.airport_shuttle_outlined},
    {'title': 'Data Sopir', 'icon': Icons.badge_outlined},
    {'title': 'Kritik dan Saran', 'icon': Icons.feedback_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 850;

        return Scaffold(
          backgroundColor: AppColors.background,
          drawer: isDesktop ? null : _buildDrawer(),
          body: Row(
            children: [
              // Sidebar for Desktop
              if (isDesktop) _buildDesktopSidebar(),

              // Main Content Area
              Expanded(
                child: SafeArea(
                  child: Column(
                    children: [
                      _buildHeader(isDesktop),
                      Expanded(
                        child: _selectedSidebarMenu == 'Beranda'
                            ? _buildDashboardHome(context, isDesktop)
                            : _buildMenuPlaceholder(context),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Header
  Widget _buildHeader(bool isDesktop) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (!isDesktop)
                Builder(
                  builder: (ctx) => IconButton(
                    icon: const Icon(
                      Icons.menu_rounded,
                      color: AppColors.textPrimary,
                    ),
                    onPressed: () => Scaffold.of(ctx).openDrawer(),
                  ),
                ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Dashboard Administrator',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Jumat, 23 Oktober 2026 • Wilayah Operasional DIY',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: AppColors.textPrimary,
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        '3 pesanan memerlukan tindakan validasi admin',
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              const CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primaryLight,
                child: Icon(
                  Icons.admin_panel_settings_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              if (isDesktop) ...[
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Admin Rina',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Pusat Komando',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // Dashboard Home
  Widget _buildDashboardHome(BuildContext context, bool isDesktop) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFourStatCards(isDesktop),
          const SizedBox(height: 24), // Jarak antara statistik dan bagian pesanan
          _buildRecentOrdersSection(context),
        ],
      ),
    );
  }

  // 4 Kartu Statistik
  // 4 Kartu Statistik dengan Layout Fleksibel (Wrap)
  Widget _buildFourStatCards(bool isDesktop) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Menghitung lebar card secara dinamis berdasarkan lebar layar saat ini
        // Jika layar lebar, bagi 2 (dikurangi jarak spasi). Jika layar sempit, ambil lebar penuh (100%).
        final double cardWidth = constraints.maxWidth > 600 
            ? (constraints.maxWidth - 16) / 2 
            : constraints.maxWidth;

        return Wrap(
          spacing: 16, // Jarak ke samping antar card
          runSpacing: 16, // Jarak ke bawah antar baris saat card turun
          children: [
            SizedBox(
              width: cardWidth,
              child: const StatCard(
                title: 'Total Pesanan Hari Ini',
                value: '28',
                icon: Icons.assignment_outlined,
                color: AppColors.primary,
                subtitle: '+12% dari kemarin',
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: const StatCard(
                title: 'Menunggu Validasi',
                value: '3',
                icon: Icons.hourglass_top_rounded,
                color: AppColors.warning,
                subtitle: 'Perlu verifikasi pembayaran',
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: const StatCard(
                title: 'Pesanan Aktif',
                value: '5',
                icon: Icons.moving_rounded,
                color: AppColors.secondary,
                subtitle: 'Unit dalam pengerahan',
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: const StatCard(
                title: 'Ambulans Tersedia',
                value: '8 / 12',
                icon: Icons.local_hospital_outlined,
                color: AppColors.success,
                subtitle: 'Siap ditugaskan',
              ),
            ),
          ],
        );
      },
    );
  }

  // Bagian Utama Pesanan Terbaru
  Widget _buildRecentOrdersSection(BuildContext context) {
    // Data dummy placeholder untuk 3 pesanan terbaru
    final recentOrders = [
      {
        'id': '#ORD-20261023-08',
        'patient': 'Bpk. Hartono',
        'route': 'Condongcatur -> RS JIH',
        'status': 'Menunggu Konfirmasi',
        'time': '2 mnt lalu',
      },
      {
        'id': '#ORD-20261023-07',
        'patient': 'Ny. Siti Aminah',
        'route': 'Godean -> RSUP Dr. Sardjito',
        'status': 'Sedang Berjalan',
        'time': '10 mnt lalu',
      },
      {
        'id': '#ORD-20261023-06',
        'patient': 'Bpk. Budi Santoso',
        'route': 'Malioboro -> RS PKU Muhammadiyah',
        'status': 'Selesai',
        'time': '25 mnt lalu',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header: Kiri (Judul), Kanan (Tombol Lihat Semua)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center, // <-- BENAR
          children: [
            const Text(
              'Pesanan Terbaru',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Navigasi ke Semua Pesanan (Placeholder)')),
                );
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Lihat Semua',
                style: TextStyle(
                  fontSize: 13, // Ukuran proporsional lebih kecil dari header
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Daftar Card Pesanan (Vertikal & Scrollable)
        ListView.builder(
          itemCount: recentOrders.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(), // Karena sudah dibungkus SingleChildScrollView di induknya
          itemBuilder: (context, index) {
            final order = recentOrders[index];
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
                  // Informasi Pesanan di Kiri
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              order['id']!,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '• ${order['time']}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          order['patient']!,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          order['route']!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Status di Kanan Card
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      order['status']!,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // Desktop Sidebar
  Widget _buildDesktopSidebar() {
    return Material(
      color: Colors.white,
      child: Container(
        width: 230,
        decoration: const BoxDecoration(
          border: Border(right: BorderSide(color: AppColors.border)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              alignment: Alignment.centerLeft,
              child: const Row(
                children: [
                  Icon(
                    Icons.local_hospital_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Ambulans Admin',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: _sidebarItems.map((item) {
                  final isSelected = _selectedSidebarMenu == item['title'];
                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    child: Material(
                      color: isSelected
                          ? AppColors.primaryLight.withValues(alpha: 0.3)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      child: ListTile(
                        dense: true,
                        leading: Icon(
                          item['icon'] as IconData,
                          size: 18,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                        title: Text(
                          item['title'] as String,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textPrimary,
                          ),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 2,
                        ),
                        onTap: () {
                          setState(() {
                            _selectedSidebarMenu = item['title'] as String;
                          });
                        },
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Mobile Drawer
  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppColors.primary),
            child: const Row(
              children: [
                Icon(
                  Icons.admin_panel_settings_rounded,
                  color: Colors.white,
                  size: 36,
                ),
                SizedBox(width: 12),
                Text(
                  'Navigasi Admin',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: _sidebarItems.map((item) {
                return ListTile(
                  leading: Icon(item['icon'] as IconData, size: 20),
                  title: Text(item['title'] as String),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _selectedSidebarMenu = item['title'] as String;
                    });
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuPlaceholder(BuildContext context) {
    String detailInfo =
        'Menu ini telah siap dihubungkan dengan API endpoint backend dan manajemen database.';
    
    if (_selectedSidebarMenu == 'Kritik dan Saran') {
      detailInfo =
          'Daftar masukan serta ulasan dari pengguna untuk evaluasi peningkatan mutu layanan ambulans.';
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kelola: $_selectedSidebarMenu',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Data & Pengaturan Modul "$_selectedSidebarMenu"',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  detailInfo,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedSidebarMenu = 'Beranda';
                    });
                  },
                  child: const Text('Kembali ke Ringkasan Beranda'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
