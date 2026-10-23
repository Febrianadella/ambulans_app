import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/llm_summary_card.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../../core/widgets/status_badge.dart';
import 'llm_analysis_detail_page.dart';

class KepalaDashboardPage extends StatefulWidget {
  const KepalaDashboardPage({super.key});

  @override
  State<KepalaDashboardPage> createState() => _KepalaDashboardPageState();
}

class _KepalaDashboardPageState extends State<KepalaDashboardPage> {
  String _selectedSidebarMenu = 'Beranda';

  final List<Map<String, dynamic>> _sidebarItems = [
    {'title': 'Beranda', 'icon': Icons.dashboard_outlined},
    {'title': 'Pemantauan Operasional', 'icon': Icons.track_changes_outlined},
    {'title': 'Riwayat Layanan', 'icon': Icons.history_edu_outlined},
    {'title': 'Rating', 'icon': Icons.star_outline_rounded},
    {'title': 'Kritik dan Saran', 'icon': Icons.chat_outlined},
    {'title': 'Analisis LLM', 'icon': Icons.auto_awesome_outlined},
    {'title': 'Laporan', 'icon': Icons.summarize_outlined},
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
              if (isDesktop) _buildDesktopSidebar(),
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

  // 1. Header
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
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dashboard Kepala Ambulans',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Periode Laporan: Oktober 2026 • Monitoring Mutu Layanan',
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
                      content: Text('Laporan bulanan telah siap diekspor'),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              const CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.secondaryLight,
                child: Icon(
                  Icons.supervisor_account_rounded,
                  color: AppColors.secondary,
                  size: 20,
                ),
              ),
              if (isDesktop) ...[
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'dr. Hendra Kusuma, Sp.EM',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Kepala Unit Ambulans',
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

  // Home Dashboard
  Widget _buildDashboardHome(BuildContext context, bool isDesktop) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 2. Empat Kartu Statistik
          _buildFourStatCards(isDesktop),
          const SizedBox(height: 20),

          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 6,
                  child: Column(
                    children: [
                      // 3. Grafik Tren Jumlah Layanan
                      _buildServiceTrendChartCard(),
                      const SizedBox(height: 20),
                      // 6. Sorotan Kritik dan Saran (Analisis LLM)
                      _buildLlmHighlightCard(context),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  flex: 4,
                  child: Column(
                    children: [
                      // 4. Distribusi Status Layanan
                      _buildServiceDistributionCard(),
                      const SizedBox(height: 20),
                      // 5. Rating Rata-rata & Masukan
                      _buildRatingSummaryCard(),
                      const SizedBox(height: 20),
                      // 7. Aktivitas Operasional Terbaru
                      _buildRecentOperationalActivityCard(),
                    ],
                  ),
                ),
              ],
            )
          else ...[
            _buildServiceTrendChartCard(),
            const SizedBox(height: 18),
            _buildServiceDistributionCard(),
            const SizedBox(height: 18),
            _buildRatingSummaryCard(),
            const SizedBox(height: 18),
            _buildLlmHighlightCard(context),
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
          title: 'Total Layanan',
          value: '142',
          icon: Icons.airport_shuttle_rounded,
          color: AppColors.primary,
          subtitle: 'Bulan berjalan',
        ),
        StatCard(
          title: 'Layanan Aktif',
          value: '4',
          icon: Icons.radar_rounded,
          color: AppColors.warning,
          subtitle: 'Armada di jalan',
        ),
        StatCard(
          title: 'Layanan Selesai',
          value: '136',
          icon: Icons.task_alt_rounded,
          color: AppColors.success,
          subtitle: 'Tuntas ditangani',
        ),
        StatCard(
          title: 'Ambulans Tersedia',
          value: '8',
          icon: Icons.health_and_safety_rounded,
          color: AppColors.secondary,
          subtitle: 'Siap response',
        ),
      ],
    );
  }

  // 3. Grafik Tren Jumlah Layanan Berdasarkan Waktu
  Widget _buildServiceTrendChartCard() {
    final weeklyData = [
      {'day': 'Sen', 'count': 18, 'height': 0.65},
      {'day': 'Sel', 'count': 24, 'height': 0.85},
      {'day': 'Rab', 'count': 15, 'height': 0.50},
      {'day': 'Kam', 'count': 22, 'height': 0.78},
      {'day': 'Jum', 'count': 28, 'height': 1.00},
      {'day': 'Sab', 'count': 20, 'height': 0.70},
      {'day': 'Min', 'count': 15, 'height': 0.52},
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tren Jumlah Layanan Mingguan',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Distribusi panggilan ambulans 7 hari terakhir (Puncak: Jumat)',
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
              const SizedBox(width: 8),
              StatusBadge.info('Rata-rata: 20/hari'),
            ],
          ),
          const SizedBox(height: 24),

          // Visual Bar Chart
          SizedBox(
            height: 140,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: weeklyData.map((d) {
                final height = (d['height'] as double) * 95;
                final isPeak = d['day'] == 'Jum';
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${d['count']}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isPeak
                            ? AppColors.primary
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 28,
                      height: height,
                      decoration: BoxDecoration(
                        color: isPeak
                            ? AppColors.primary
                            : AppColors.secondaryLight,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isPeak
                              ? AppColors.primaryDark
                              : AppColors.secondary.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      d['day'] as String,
                      style: TextStyle(
                        fontSize: 11,
                        color: isPeak
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight: isPeak
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // 4. Ringkasan Distribusi Status Layanan
  Widget _buildServiceDistributionCard() {
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
            'Kategori Panggilan Layanan',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          _buildCategoryBar(
            'Gawat Darurat Medis / Trauma',
            0.65,
            '65% (92 kasus)',
            AppColors.primary,
          ),
          const SizedBox(height: 10),
          _buildCategoryBar(
            'Rujukan Antar Rumah Sakit',
            0.25,
            '25% (35 kasus)',
            AppColors.secondary,
          ),
          const SizedBox(height: 10),
          _buildCategoryBar(
            'Transportasi Pasien Kronis',
            0.10,
            '10% (15 kasus)',
            AppColors.success,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBar(
    String title,
    double fraction,
    String label,
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
                title,
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
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: fraction,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  // 5. Card Rating Rata-rata dan Jumlah Kritik/Saran
  Widget _buildRatingSummaryCard() {
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
                  'Indeks Kepuasan Pasien',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              StatusBadge.success('Sangat Baik'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text(
                '4.7',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: List.generate(5, (index) {
                        return const Icon(
                          Icons.star_rounded,
                          color: AppColors.warning,
                          size: 18,
                        );
                      }),
                    ),
                    const Text(
                      'Berdasarkan 64 kritik & saran masuk',
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

  // 6. Card Sorotan Kritik dan Saran (Analisis LLM)
  Widget _buildLlmHighlightCard(BuildContext context) {
    return LlmSummaryCard(
      isHeadView: true,
      totalFeedbackAnalyzed: 64,
      topComplaintTopics: const [
        'Waktu Respon Panggilan',
        'Stabilitas Armada saat Evakuasi',
        'Kemudahan Akses Aplikasi',
      ],
      feedbackSummary: 'Evaluasi eksekutif menunjukkan 76% pasien merasa tertolong secara krusial oleh kecepatan respon petugas. Rekomendasi LLM berfokus pada penambahan armada di zona Bantul barat dan Sleman utara saat jam sibuk.',
      improvementSuggestions: '1. Rekomendasi penempatan pos siaga tambahan di ring road utara.\n2. Jadwalkan evaluasi SOP berkendara sopir untuk kenyamanan pasien pasca trauma.\n3. Pertahankan standar respon perawat IGD yang memperoleh rating 4.9.',
      lastAnalyzedTime: '23 Okt 2026, 08:30 WIB',
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
        'time': '09:20',
        'desc': 'Laporan triwulan kesiapan IGD selesai divalidasi.',
      },
      {
        'time': '08:45',
        'desc': 'Response time rata-rata pagi ini tercatat 7.4 menit.',
      },
      {
        'time': '07:30',
        'desc':
            'Semua 12 armada telah melalui inspeksi harian kelayakan medis.',
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
            'Catatan Evaluasi Operasional',
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
                      color: AppColors.secondary,
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
                    Icons.shield_outlined,
                    color: AppColors.secondary,
                    size: 22,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Kepala Ambulans',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
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
                          ? AppColors.secondaryLight.withValues(alpha: 0.5)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      child: ListTile(
                        dense: true,
                        leading: Icon(
                          item['icon'] as IconData,
                          size: 18,
                          color: isSelected
                              ? AppColors.secondary
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
                                ? AppColors.secondary
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

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppColors.secondary),
            child: const Row(
              children: [
                Icon(Icons.shield_rounded, color: Colors.white, size: 36),
                SizedBox(width: 12),
                Text(
                  'Menu Pimpinan',
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
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Monitoring: $_selectedSidebarMenu',
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
                  'Laporan & Analisis Mutu "$_selectedSidebarMenu"',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Data monitoring kepemimpinan ambulans terhubung dengan sistem pelaporan terpadu.',
                  style: TextStyle(
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
                  child: const Text('Kembali ke Dashboard Beranda'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
