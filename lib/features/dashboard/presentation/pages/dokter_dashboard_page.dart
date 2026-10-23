import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/empty_state_card.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../medical_report/presentation/pages/medical_report_page.dart';

class DokterDashboardPage extends StatefulWidget {
  const DokterDashboardPage({super.key});

  @override
  State<DokterDashboardPage> createState() => _DokterDashboardPageState();
}

class _DokterDashboardPageState extends State<DokterDashboardPage> {
  int _currentNavIndex = 0;
  int _unreadReportsCount = 2;

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
            icon: Icon(Icons.medical_services_rounded),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_turned_in_outlined),
            label: 'Laporan Pasien',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_active_outlined),
            label: 'Notifikasi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_edu_outlined),
            label: 'Riwayat',
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
          // 1. Header: Sapaan, Nama Dokter, Notifikasi
          _buildHeader(),
          const SizedBox(height: 16),

          // 2 & 3. Kartu Statistik Laporan Belum Dibaca & Total Diterima
          _buildTwoReportStatCards(),
          const SizedBox(height: 16),

          // 6. Tombol Aksi "Lihat Laporan Baru"
          _buildActionButton(context),
          const SizedBox(height: 18),

          // 4. Card "Laporan Pasien Terbaru"
          _buildLatestPatientReportCard(context),
          const SizedBox(height: 18),

          // 5. Card "Status Notifikasi" (WhatsApp & Email Alert)
          _buildNotificationStatusCard(),
          const SizedBox(height: 18),

          // 7. Ringkasan Laporan Terbaru
          _buildRecentReportsSummarySection(context),
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
              child: Icon(
                Icons.local_hospital_rounded,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Dokter Penanggung Jawab IGD,',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  'dr. Farhan Malik, Sp.An',
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
                setState(() => _currentNavIndex = 2);
              },
            ),
            if (_unreadReportsCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$_unreadReportsCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  // 2 & 3. Kartu Statistik Laporan Belum Dibaca & Diterima
  Widget _buildTwoReportStatCards() {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            title: 'Laporan Baru Belum Dibaca',
            value: '$_unreadReportsCount Laporan',
            icon: Icons.mark_email_unread_rounded,
            color: AppColors.warning,
            subtitle: 'Menunggu review dokter',
            badge: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.warningLight,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Urgent',
                style: TextStyle(
                  fontSize: 10,
                  color: Color(0xFFB45309),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: StatCard(
            title: 'Laporan Diterima Hari Ini',
            value: '5 Laporan',
            icon: Icons.assignment_turned_in_rounded,
            color: AppColors.secondary,
            subtitle: 'Triase & Rujukan IGD',
          ),
        ),
      ],
    );
  }

  // 6. Tombol "Lihat Laporan Baru"
  Widget _buildActionButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const MedicalReportPage(orderId: 'ORD-20261023-01'),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.remove_red_eye_rounded, size: 18),
        label: const Text(
          'Lihat Laporan Pasien Baru (Menuju IGD)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ),
    );
  }

  // 4. Card "Laporan Pasien Terbaru"
  Widget _buildLatestPatientReportCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
              const Text(
                'Laporan Pasien Terbaru',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              StatusBadge.warning(
                'Belum Dibaca',
                icon: Icons.fiber_new_rounded,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '#MED-20261023-01',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      '15 mnt lalu • Perawat Sarah',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Pasien: Bpk. Budi Pratama (48 th) • Dugaan ACS/STEMI',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Catatan Perawat: Mengeluh nyeri dada kiri menjalar, dispnea ringan, riwayat rokok aktif. Infus RL 20 tpm terpasang, O2 nasal kanul 3 lpm.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _buildVitalBadge('TD: 140/90 mmHg'),
                    _buildVitalBadge('HR: 88 bpm'),
                    _buildVitalBadge('SpO2: 97%'),
                    _buildVitalBadge('Suhu: 36.7°C'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    if (_unreadReportsCount > 0) _unreadReportsCount--;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Laporan ditandai telah ditinjau.'),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.success,
                  side: const BorderSide(color: AppColors.success),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
                icon: const Icon(Icons.check_rounded, size: 16),
                label: const Text(
                  'Tandai Sudah Ditinjau',
                  style: TextStyle(fontSize: 12),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const MedicalReportPage(orderId: 'ORD-20261023-01'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
                icon: const Icon(Icons.edit_note_rounded, size: 16),
                label: const Text(
                  'Beri Catatan Dokter',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVitalBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  // 5. Card Status Notifikasi (WhatsApp & Email)
  Widget _buildNotificationStatusCard() {
    return Container(
      padding: const EdgeInsets.all(16),
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
              const Row(
                children: [
                  Icon(
                    Icons.send_and_archive_outlined,
                    color: AppColors.secondary,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Status Notifikasi Otomatis Dokter',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              StatusBadge.success('Gateway Aktif'),
            ],
          ),
          const SizedBox(height: 12),
          _buildNotificationChannelRow(
            icon: Icons.chat_bubble_rounded,
            channel: 'WhatsApp Alert Tim IGD',
            status: 'Terkirim (09:15 WIB)',
            recipient: '+62 812-xxxx-7890 (Grup Triase IGD)',
            color: const Color(0xFF25D366),
          ),
          const Divider(height: 18, color: AppColors.border),
          _buildNotificationChannelRow(
            icon: Icons.email_rounded,
            channel: 'Email Ringkasan Pasien',
            status: 'Terkirim (09:15 WIB)',
            recipient: 'dr.farhan@hospital.id',
            color: AppColors.secondary,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationChannelRow({
    required IconData icon,
    required String channel,
    required String status,
    required String recipient,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                channel,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              Text(
                recipient,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Text(
          status,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.success,
          ),
        ),
      ],
    );
  }

  // 7. Ringkasan Laporan Terbaru
  Widget _buildRecentReportsSummarySection(BuildContext context) {
    final previousReports = [
      {
        'id': '#MED-20261023-00',
        'patient': 'Ny. Aminah (62 th)',
        'case': 'Fraktur femur dextra',
        'time': '07:30 WIB',
        'status': 'Selesai Ditinjau',
      },
      {
        'id': '#MED-20261022-04',
        'patient': 'An. Rizky (8 th)',
        'case': 'Febris konvulsi',
        'time': 'Kemarin 21:10',
        'status': 'Selesai Ditinjau',
      },
      {
        'id': '#MED-20261022-02',
        'patient': 'Bpk. Herman (55 th)',
        'case': 'Ketidaksadaran / stroke',
        'time': 'Kemarin 14:00',
        'status': 'Selesai Ditinjau',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Riwayat Laporan yang Telah Ditinjau',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        ...previousReports.map((r) {
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
                      '${r['id']} • ${r['patient']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${r['case']} • ${r['time']}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                StatusBadge.success(r['status']!),
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
      'Daftar Laporan Pasien',
      'Pusat Notifikasi',
      'Riwayat Triase Medis',
      'Profil Dokter',
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
            icon: Icons.medical_services_outlined,
            title: 'Menu ${titles[_currentNavIndex]}',
            message: 'Akses medis terproteksi untuk dokter penanggung jawab.',
            buttonText: 'Kembali ke Dashboard Beranda',
            onButtonPressed: () {
              setState(() => _currentNavIndex = 0);
            },
          ),
        ],
      ),
    );
  }
}
