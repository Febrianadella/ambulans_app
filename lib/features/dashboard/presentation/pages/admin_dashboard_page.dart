import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/llm_summary_card.dart';
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
    {'title': 'Validasi Pembayaran', 'icon': Icons.payments_outlined},
    {'title': 'Penugasan', 'icon': Icons.assignment_ind_outlined},
    {'title': 'Data Ambulans', 'icon': Icons.airport_shuttle_outlined},
    {'title': 'Data Sopir', 'icon': Icons.badge_outlined},
    {'title': 'Tarif', 'icon': Icons.price_change_outlined},
    {'title': 'Pemantauan Operasional', 'icon': Icons.track_changes_outlined},
    {'title': 'Riwayat Layanan', 'icon': Icons.history_edu_outlined},
    {'title': 'Kritik dan Saran', 'icon': Icons.feedback_outlined},
    {'title': 'Analisis LLM', 'icon': Icons.auto_awesome_outlined},
    {'title': 'Laporan', 'icon': Icons.analytics_outlined},
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
          // 2. Empat Kartu Statistik
          _buildFourStatCards(isDesktop),
          const SizedBox(height: 20),

          // Layout 2 Kolom untuk Desktop, 1 Kolom untuk Mobile
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 6,
                  child: Column(
                    children: [
                      _buildActionRequiredOrdersCard(),
                      const SizedBox(height: 20),
                      _buildLlmSummarySection(context),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  flex: 4,
                  child: Column(
                    children: [
                      _buildFleetStatusCard(),
                      const SizedBox(height: 20),
                      _buildFeedbackRatingCard(),
                      const SizedBox(height: 20),
                      _buildRecentOperationalActivityCard(),
                    ],
                  ),
                ),
              ],
            )
          else ...[
            _buildActionRequiredOrdersCard(),
            const SizedBox(height: 18),
            _buildFleetStatusCard(),
            const SizedBox(height: 18),
            _buildFeedbackRatingCard(),
            const SizedBox(height: 18),
            _buildLlmSummarySection(context),
            const SizedBox(height: 18),
            _buildRecentOperationalActivityCard(),
          ],
        ],
      ),
    );
  }

  // 2. Empat Kartu Statistik
  Widget _buildFourStatCards(bool isDesktop) {
    return GridView.count(
      crossAxisCount: isDesktop ? 4 : 2,
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: isDesktop ? 1.7 : 1.35,
      children: const [
        StatCard(
          title: 'Total Pesanan Hari Ini',
          value: '28',
          icon: Icons.assignment_outlined,
          color: AppColors.primary,
          subtitle: '+12% dari kemarin',
        ),
        StatCard(
          title: 'Menunggu Validasi',
          value: '3',
          icon: Icons.hourglass_top_rounded,
          color: AppColors.warning,
          subtitle: 'Perlu verifikasi bank',
        ),
        StatCard(
          title: 'Pesanan Berlangsung',
          value: '5',
          icon: Icons.moving_rounded,
          color: AppColors.secondary,
          subtitle: 'Unit di lapangan',
        ),
        StatCard(
          title: 'Ambulans Tersedia',
          value: '8 / 12',
          icon: Icons.local_hospital_outlined,
          color: AppColors.success,
          subtitle: 'Standby di pangkalan',
        ),
      ],
    );
  }

  // 3. Card Pesanan Perlu Ditindaklanjuti
  Widget _buildActionRequiredOrdersCard() {
    final pendingOrders = [
      {
        'id': '#ORD-20261023-04',
        'type': 'Validasi Pembayaran',
        'patient': 'Bpk. Hendrawan',
        'route': 'Sleman -> RS Panti Rapih',
        'time': '5 mnt lalu',
        'amount': 'Rp 250.000 (Mandiri)',
        'action': 'Validasi',
      },
      {
        'id': '#ORD-20261023-05',
        'type': 'Penugasan Sopir',
        'patient': 'Ny. Wahyuni',
        'route': 'Bantul -> RS PKU Bantul',
        'time': '8 mnt lalu',
        'amount': 'Sudah Valid',
        'action': 'Tugaskan',
      },
      {
        'id': '#ORD-20261023-06',
        'type': 'Validasi Pembayaran',
        'patient': 'Bpk. Sugeng',
        'route': 'Kota -> RS Bethesda',
        'time': '14 mnt lalu',
        'amount': 'Rp 200.000 (BCA)',
        'action': 'Validasi',
      },
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
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
                      Icons.warning_amber_rounded,
                      color: AppColors.warning,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Pesanan Perlu Ditindaklanjuti',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusBadge.warning('3 Pesanan Menunggu'),
            ],
          ),
          const SizedBox(height: 14),
          ...pendingOrders.map((o) {
            final isValidation = o['type'] == 'Validasi Pembayaran';
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              o['id']!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: StatusBadge.warning(o['type']!),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${o['patient']} • ${o['route']}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '${o['amount']} • ${o['time']}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Tindakan ${o['action']} untuk ${o['id']} berhasil diproses.',
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isValidation
                          ? AppColors.success
                          : AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      visualDensity: VisualDensity.compact,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      o['action']!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // 4. Card Status Armada
  Widget _buildFleetStatusCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Status Armada Ambulans (12 Unit)',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          _buildFleetProgressRow(
            'Tersedia (Standby)',
            8,
            12,
            AppColors.success,
          ),
          const SizedBox(height: 10),
          _buildFleetProgressRow('Sedang Bertugas', 3, 12, AppColors.primary),
          const SizedBox(height: 10),
          _buildFleetProgressRow(
            'Perawatan / Servis Rutin',
            1,
            12,
            AppColors.warning,
          ),
        ],
      ),
    );
  }

  Widget _buildFleetProgressRow(
    String label,
    int count,
    int total,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$count unit',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: count / total,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  // 5. Card Kritik dan Saran Pengguna
  Widget _buildFeedbackRatingCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
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
                  'Kritik & Saran Pengguna',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              StatusBadge.info('47 Masukan'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text(
                '4.6',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < 4
                              ? Icons.star_rounded
                              : Icons.star_half_rounded,
                          color: AppColors.warning,
                          size: 16,
                        );
                      }),
                    ),
                    const Text(
                      'Rata-rata rating bulan ini',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 6. Card Ringkasan Analisis LLM
  Widget _buildLlmSummarySection(BuildContext context) {
    return LlmSummaryCard(
      totalFeedbackAnalyzed: 47,
      topComplaintTopics: const [
        'Waktu Tunggu Penjemputan',
        'Kenyamanan Suspensi Armada',
        'Validasi Pembayaran',
      ],
      feedbackSummary: 'Pengguna umumnya sangat mengapresiasi keramahan tim medis dan respons panggilan. Sekitar 45% keluhan berfokus pada waktu kedatangan ambulans saat jam padat lalu lintas.',
      improvementSuggestions: '1. Implementasikan algoritma rute dinamis berbasis GPS.\n2. Lakukan pengecekan suspensi armada unit 03 dan 07.\n3. Otomasi verifikasi transfer bank dengan QRIS/Payment Gateway.',
      lastAnalyzedTime: 'Hari ini, 08:30 WIB',
      onOpenDetail: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LlmAnalysisDetailPage()),
        );
      },
    );
  }

  // 7. Aktivitas Operasional Terbaru
  Widget _buildRecentOperationalActivityCard() {
    final activities = [
      {
        'time': '09:12',
        'desc': 'Sopir Joko Susilo mengonfirmasi tiba di RSUP Dr. Sardjito.',
      },
      {
        'time': '08:55',
        'desc': 'Validasi pembayaran pesanan #ORD-20261023-03 disetujui.',
      },
      {
        'time': '08:40',
        'desc': 'Panggilan darurat baru #ORD-20261023-04 dari Danurejan.',
      },
      {
        'time': '08:15',
        'desc': 'Ambulans unit AB 1199 MED status aktif dan siap jalan.',
      },
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Aktivitas Operasional Terbaru',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...activities.map((a) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    a['time']!,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      a['desc']!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
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
                          if (item['title'] == 'Analisis LLM') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LlmAnalysisDetailPage(),
                              ),
                            );
                          } else {
                            setState(() {
                              _selectedSidebarMenu = item['title'] as String;
                            });
                          }
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
                    if (item['title'] == 'Analisis LLM') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LlmAnalysisDetailPage(),
                        ),
                      );
                    } else {
                      setState(() {
                        _selectedSidebarMenu = item['title'] as String;
                      });
                    }
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
    if (_selectedSidebarMenu == 'Pemantauan Operasional') {
      detailInfo =
          'Pantau pergerakan armada ambulans aktif, waktu tanggap penjemputan (ETA), dan koordinasi darurat di lapangan secara real-time.';
    } else if (_selectedSidebarMenu == 'Riwayat Layanan') {
      detailInfo =
          'Arsip seluruh riwayat penjemputan, pesanan selesai, dan log perjalanan ambulans untuk kebutuhan audit.';
    } else if (_selectedSidebarMenu == 'Laporan') {
      detailInfo =
          'Rekapitulasi berkala performa operasional, utilisasi armada, dan laporan tingkat kepuasan layanan ambulans.';
    } else if (_selectedSidebarMenu == 'Kritik dan Saran') {
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
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedSidebarMenu = 'Beranda';
                        });
                      },
                      child: const Text('Kembali ke Ringkasan Beranda'),
                    ),
                    if (_selectedSidebarMenu == 'Kritik dan Saran' ||
                        _selectedSidebarMenu == 'Laporan') ...[
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LlmAnalysisDetailPage(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.auto_awesome, size: 16),
                        label: const Text('Buka Analisis LLM'),
                      ),
                    ],
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
