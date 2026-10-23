import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/empty_state_card.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../medical_report/presentation/pages/medical_report_page.dart';

class PerawatDashboardPage extends StatefulWidget {
  const PerawatDashboardPage({super.key});

  @override
  State<PerawatDashboardPage> createState() => _PerawatDashboardPageState();
}

class _PerawatDashboardPageState extends State<PerawatDashboardPage> {
  int _currentNavIndex = 0;

  // Status Kesiapan IGD
  String _bedStatus = '2 Bed Siap';
  final String _oxygenStatus = 'Tabung Penuh (100%)';
  final String _triageTeamStatus = 'Siap Siaga di Zona Merah';

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
            icon: Icon(Icons.medical_information_rounded),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            label: 'Laporan Pasien',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.meeting_room_outlined),
            label: 'Kesiapan IGD',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_rounded),
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
          // 1. Header: Sapaan, Nama Perawat, Notifikasi
          _buildHeader(),
          const SizedBox(height: 16),

          // 2. Tiga Kartu Ringkasan (Dibuat, Terkirim, Perlu Ditindaklanjuti)
          _buildThreeSummaryCards(),
          const SizedBox(height: 16),

          // 5 & 6. Tombol Aksi Utama: "Buat Laporan Pasien" & "Perbarui Kesiapan IGD"
          _buildActionButtons(context),
          const SizedBox(height: 18),

          // 3. Card "Laporan Pasien Terbaru"
          _buildLatestReportCard(context),
          const SizedBox(height: 18),

          // 4. Card "Kesiapan IGD"
          _buildIgdReadinessCard(context),
          const SizedBox(height: 18),

          // 7. Pengingat & Notifikasi Laporan Terbaru
          _buildRemindersSection(),
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
              backgroundColor: Color(0xFFEFF6FF),
              child: Icon(
                Icons.health_and_safety_rounded,
                color: AppColors.secondary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Perawat Pendamping Ambulans,',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  'Ns. Sarah Amelia, S.Kep',
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
                content: Text('Laporan terakhir telah diterima dokter jaga'),
              ),
            );
          },
        ),
      ],
    );
  }

  // 2. Kartu Ringkasan
  Widget _buildThreeSummaryCards() {
    return Row(
      children: const [
        Expanded(
          child: StatCard(
            title: 'Laporan Dibuat',
            value: '3',
            icon: Icons.note_add_rounded,
            color: AppColors.secondary,
            subtitle: 'Hari ini',
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: StatCard(
            title: 'Laporan Terkirim',
            value: '3',
            icon: Icons.send_rounded,
            color: AppColors.success,
            subtitle: 'Ke dokter IGD',
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: StatCard(
            title: 'Tindak Lanjut',
            value: '0',
            icon: Icons.pending_actions_rounded,
            color: AppColors.warning,
            subtitle: 'Semua tervalidasi',
          ),
        ),
      ],
    );
  }

  // 5 & 6. Tombol Utama
  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
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
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.post_add_rounded, size: 18),
            label: const Text(
              'Buat Laporan Pasien',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _showUpdateIgdDialog(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.secondary,
              side: const BorderSide(color: AppColors.secondary),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.sync_rounded, size: 18),
            label: const Text(
              'Perbarui Kesiapan IGD',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }

  // 3. Card Laporan Pasien Terbaru
  Widget _buildLatestReportCard(BuildContext context) {
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
              StatusBadge.success('Terkirim ke Dokter IGD'),
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
                      '#MED-20261023-01 (Bpk. Budi Pratama, 48 th)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      '15 mnt lalu',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Kondisi: Sadar, nyeri dada kiri menjalar ke bahu, riwayat hipertensi.',
                  style: TextStyle(fontSize: 12, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildVitalBadge('TD: 140/90'),
                    const SizedBox(width: 8),
                    _buildVitalBadge('HR: 88 bpm'),
                    const SizedBox(width: 8),
                    _buildVitalBadge('SpO2: 97%'),
                    const SizedBox(width: 8),
                    _buildVitalBadge('Suhu: 36.7°C'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const MedicalReportPage(orderId: 'ORD-20261023-01'),
                  ),
                );
              },
              icon: const Icon(Icons.remove_red_eye_outlined, size: 16),
              label: const Text(
                'Buka Detail & Edit Laporan',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVitalBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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

  // 4. Card Kesiapan IGD
  Widget _buildIgdReadinessCard(BuildContext context) {
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
                    Icons.local_hospital_outlined,
                    color: AppColors.secondary,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Status Kesiapan IGD RS Rujukan',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              StatusBadge.info('Update Terakhir: 09:00 WIB'),
            ],
          ),
          const SizedBox(height: 14),
          _buildReadinessRow(
            Icons.single_bed_rounded,
            'Bed Resusitasi Tersedia',
            _bedStatus,
            AppColors.success,
          ),
          const Divider(height: 18, color: AppColors.border),
          _buildReadinessRow(
            Icons.air_rounded,
            'Oksigen Transport Ambulans',
            _oxygenStatus,
            AppColors.success,
          ),
          const Divider(height: 18, color: AppColors.border),
          _buildReadinessRow(
            Icons.group_outlined,
            'Tim Triase Trauma IGD',
            _triageTeamStatus,
            AppColors.secondary,
          ),
        ],
      ),
    );
  }

  Widget _buildReadinessRow(
    IconData icon,
    String title,
    String value,
    Color color,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  // 7. Pengingat / Notifikasi Laporan Terbaru
  Widget _buildRemindersSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pengingat Laporan & Notifikasi',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.check_circle_outline,
                color: AppColors.success,
                size: 16,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Laporan #MED-20261023-01 telah diverifikasi oleh dr. Farhan Malik (Dokter Jaga). Tim IGD telah menyiapkan ruang resusitasi.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Dialog Perbarui Kesiapan IGD
  void _showUpdateIgdDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text(
            'Perbarui Status Kesiapan IGD',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                dense: true,
                title: const Text('Bed Resusitasi Tersedia: 2 Bed'),
                trailing: const Icon(Icons.check, color: AppColors.success),
                onTap: () {
                  setState(() => _bedStatus = '2 Bed Siap');
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                dense: true,
                title: const Text('Bed Penuh (Alihkan Rujukan)'),
                trailing: const Icon(
                  Icons.warning_amber,
                  color: AppColors.warning,
                ),
                onTap: () {
                  setState(() => _bedStatus = 'Penuh (Hanya Triase Darurat)');
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOtherTab(BuildContext context) {
    final titles = [
      'Beranda',
      'Semua Laporan Pasien',
      'Kesiapan Ruang IGD',
      'Riwayat Asuhan Medis',
      'Profil Perawat',
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
            icon: Icons.health_and_safety_outlined,
            title: 'Halaman ${titles[_currentNavIndex]}',
            message:
                'Menu ${titles[_currentNavIndex]} aktif dan siap digunakan.',
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
