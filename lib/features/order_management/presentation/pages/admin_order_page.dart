import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  // Menyimpan data pesanan yang sedang dipilih untuk dilihat detailnya (null jika sedang di halaman utama list)
  Map<String, dynamic>? _selectedOrderForDetail;

  @override
  Widget build(BuildContext context) {
    // Jika ada pesanan yang dipilih, tampilkan Halaman Detail Placeholder
    if (_selectedOrderForDetail != null) {
      return _buildOrderDetailView(context, _selectedOrderForDetail!);
    }

    // Jika tidak, tampilkan halaman utama list pesanan (Split Scroll)
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWideScreen = constraints.maxWidth >= 900;
        final double availableHeight = constraints.maxHeight - 40; 

        return Padding(
          padding: const EdgeInsets.all(20),
          child: isWideScreen
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: availableHeight > 0 ? availableHeight : 500,
                        child: _buildActiveOrdersSection(context),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: SizedBox(
                        height: availableHeight > 0 ? availableHeight : 500,
                        child: _buildOrderHistorySection(context),
                      ),
                    ),
                  ],
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildActiveOrdersSectionMobile(context),
                      const SizedBox(height: 28),
                      _buildOrderHistorySectionMobile(context),
                    ],
                  ),
                ),
        );
      },
    );
  }

  // ==========================================
  // HALAMAN DETAIL PESANAN (PENGGANTI LAYAR UTAMA)
  // ==========================================
  Widget _buildOrderDetailView(BuildContext context, Map<String, dynamic> order) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tombol Kembali & Judul
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
                onPressed: () {
                  setState(() {
                    _selectedOrderForDetail = null; // Kembali ke list utama
                  });
                },
              ),
              const SizedBox(width: 8),
              Text(
                'Detail Informasi Pesanan ${order['id']}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Konten Kotak Detail Sederhana
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('ID Pesanan', order['id']),
                    const Divider(height: 24, color: AppColors.border),
                    _buildDetailRow('Nama Pasien', order['patient']),
                    const SizedBox(height: 12),
                    _buildDetailRow('No. Telepon', order['phone']),
                    const SizedBox(height: 12),
                    _buildDetailRow('Rute Perjalanan', order['route']),
                    const SizedBox(height: 12),
                    _buildDetailRow('Unit Ambulans', order['ambulance']),
                    const SizedBox(height: 12),
                    _buildDetailRow('Status Saat Ini', order['status']),
                    const SizedBox(height: 20),
                    
                    const Text(
                      'Catatan / Keterangan Medis:',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        order['notes'] ?? '-',
                        style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // --- TAMBAHAN: KOLOM BUKTI PEMBAYARAN (TEMPLATE PLACEHOLDER) ---
                    const Text(
                      'Bukti Pembayaran / Lampiran:',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      height: 160,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.receipt_long_rounded,
                            size: 40,
                            color: AppColors.primary,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '[ Mockup Foto Bukti Transfer / Kwitansi ]',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                            Text(
                            'Format Gambar: PNG / JPG (Simulasi Template)',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // -------------------------------------------------------------

                    const SizedBox(height: 30),
                    // Tombol Aksi Placeholder
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Aksi kelola pesanan ${order['id']} diproses')),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                          label: const Text('Proses Tindakan', style: TextStyle(color: Colors.white)),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: () {
                            // Dialog konfirmasi pembatalan sederhana
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Konfirmasi Pembatalan'),
                                content: Text('Apakah Anda yakin ingin membatalkan pesanan ${order['id']}?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('Tidak'),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
                                    onPressed: () {
                                      Navigator.pop(ctx); // Tutup dialog konfirmasi
                                      setState(() {
                                        _selectedOrderForDetail = null; // Kembali ke halaman utama
                                      });
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Pesanan ${order['id']} berhasil dibatalkan')),
                                      );
                                    },
                                    child: const Text('Ya, Batalkan', style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.warning,
                            side: const BorderSide(color: AppColors.warning),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: const Icon(Icons.cancel_outlined, size: 18),
                          label: const Text('Batalkan Pesanan'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
          ),
        ),
        const Text(': ', style: TextStyle(color: AppColors.textSecondary)),
        Expanded(
          child: Text(
            value ?? '-',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // 1. BAGIAN PESANAN AKTIF (UNTUK DESKTOP - SPLIT SCROLL)
  // ==========================================
  Widget _buildActiveOrdersSection(BuildContext context) {
    final activeOrders = [
      {
        'id': '#ORD-20261023-08',
        'patient': 'Bpk. Hartono',
        'route': 'Condongcatur -> RS JIH',
        'status': 'Menunggu Konfirmasi',
        'time': '2 mnt lalu',
        'phone': '081234567890',
        'notes': 'Pasien sesak napas, butuh tabung oksigen portabel.',
        'ambulance': 'Ambulans Darurat Unit 02',
      },
      {
        'id': '#ORD-20261023-07',
        'patient': 'Ny. Siti Aminah',
        'route': 'Godean -> RSUP Dr. Sardjito',
        'status': 'Sedang Berjalan',
        'time': '10 mnt lalu',
        'phone': '081987654321',
        'notes': 'Kontrol rutin pasca operasi jantung.',
        'ambulance': 'Ambulans Transport Unit 05',
      },
      {
        'id': '#ORD-20261023-05',
        'patient': 'An. Rian Pratama',
        'route': 'Mlati -> RS Panti Rapih',
        'status': 'Unit Menuju Lokasi',
        'time': '18 mnt lalu',
        'phone': '081122334455',
        'notes': 'Kecelakaan ringan, evakuasi darurat.',
        'ambulance': 'Ambulans Darurat Unit 01',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Pesanan Aktif'),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            itemCount: activeOrders.length,
            shrinkWrap: false,
            physics: const AlwaysScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final order = activeOrders[index];
              return _buildOrderCard(
                id: order['id']!,
                patient: order['patient']!,
                route: order['route']!,
                status: order['status']!,
                time: order['time']!,
                statusColor: AppColors.secondary,
                statusBg: AppColors.primaryLight.withValues(alpha: 0.2),
                onTap: () {
                  setState(() {
                    _selectedOrderForDetail = order; // Beralih ke halaman detail
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // ==========================================
  // 2. BAGIAN RIWAYAT PESANAN (UNTUK DESKTOP - SPLIT SCROLL)
  // ==========================================
  Widget _buildOrderHistorySection(BuildContext context) {
    final historyOrders = [
      {
        'id': '#ORD-20261023-04',
        'patient': 'Bpk. Budi Santoso',
        'route': 'Malioboro -> RS PKU Muhammadiyah',
        'status': 'Selesai',
        'time': '1 jam lalu',
        'phone': '081333444555',
        'notes': 'Pengantaran pasien selesai dengan aman.',
        'ambulance': 'Ambulans Transport Unit 03',
      },
      {
        'id': '#ORD-20261023-03',
        'patient': 'Ny. Endang',
        'route': 'Seturan -> RS Bethesda',
        'status': 'Selesai',
        'time': '2 jam lalu',
        'phone': '081555666777',
        'notes': 'Pasien diantar tepat waktu.',
        'ambulance': 'Ambulans Transport Unit 04',
      },
      {
        'id': '#ORD-20261023-02',
        'patient': 'Bpk. Sujarwo',
        'route': 'Maguwoharjo -> RS Akademik UGM',
        'status': 'Dibatalkan',
        'time': '3 jam lalu',
        'phone': '081888999000',
        'notes': 'Dibatalkan oleh keluarga karena kondisi membaik.',
        'ambulance': '-',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Riwayat Pesanan'),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            itemCount: historyOrders.length,
            shrinkWrap: false,
            physics: const AlwaysScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final order = historyOrders[index];
              final bool isCancelled = order['status'] == 'Dibatalkan';
              return _buildOrderCard(
                id: order['id']!,
                patient: order['patient']!,
                route: order['route']!,
                status: order['status']!,
                time: order['time']!,
                statusColor: isCancelled ? AppColors.warning : AppColors.success,
                statusBg: isCancelled 
                    ? AppColors.warning.withValues(alpha: 0.15) 
                    : AppColors.success.withValues(alpha: 0.15),
                onTap: () {
                  setState(() {
                    _selectedOrderForDetail = order; // Beralih ke halaman detail
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // ==========================================
  // HELPER: HEADER SECTION
  // ==========================================
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  // ==========================================
  // VERSI MOBILE (UNTUK LAYAR KECIL / HP)
  // ==========================================
  Widget _buildActiveOrdersSectionMobile(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Pesanan Aktif'),
        const SizedBox(height: 12),
        _buildOrderCard(
          id: '#ORD-20261023-08',
          patient: 'Bpk. Hartono',
          route: 'Condongcatur -> RS JIH',
          status: 'Menunggu Konfirmasi',
          time: '2 mnt lalu',
          statusColor: AppColors.secondary,
          statusBg: AppColors.primaryLight.withValues(alpha: 0.2),
          onTap: () {
            setState(() {
              _selectedOrderForDetail = {
                'id': '#ORD-20261023-08',
                'patient': 'Bpk. Hartono',
                'route': 'Condongcatur -> RS JIH',
                'status': 'Menunggu Konfirmasi',
                'time': '2 mnt lalu',
                'phone': '081234567890',
                'notes': 'Pasien sesak napas, butuh tabung oksigen portabel.',
                'ambulance': 'Ambulans Darurat Unit 02',
              };
            });
          },
        ),
      ],
    );
  }

  Widget _buildOrderHistorySectionMobile(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Riwayat Pesanan'),
        const SizedBox(height: 12),
        _buildOrderCard(
          id: '#ORD-20261023-04',
          patient: 'Bpk. Budi Santoso',
          route: 'Malioboro -> RS PKU Muhammadiyah',
          status: 'Selesai',
          time: '1 jam lalu',
          statusColor: AppColors.success,
          statusBg: AppColors.success.withValues(alpha: 0.15),
          onTap: () {
            setState(() {
              _selectedOrderForDetail = {
                'id': '#ORD-20261023-04',
                'patient': 'Bpk. Budi Santoso',
                'route': 'Malioboro -> RS PKU Muhammadiyah',
                'status': 'Selesai',
                'time': '1 jam lalu',
                'phone': '081333444555',
                'notes': 'Pengantaran pasien selesai dengan aman.',
                'ambulance': 'Ambulans Transport Unit 03',
              };
            });
          },
        ),
      ],
    );
  }

  // ==========================================
  // KOMPONEN KARTU PESANAN REUSABLE
  // ==========================================
  Widget _buildOrderCard({
    required String id,
    required String patient,
    required String route,
    required String status,
    required String time,
    required Color statusColor,
    required Color statusBg,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            id,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '• $time',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        patient,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        route,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}