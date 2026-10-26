import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class AdminSuggestionPage extends StatefulWidget {
  const AdminSuggestionPage({super.key});

  @override
  State<AdminSuggestionPage> createState() => _AdminSuggestionPageState();
}

class _AdminSuggestionPageState extends State<AdminSuggestionPage> {
  // Filter status aktif
  String _selectedFilter = 'Semua';
  final List<String> _filterOptions = ['Semua', 'Positif', 'Netral', 'Negatif', 'Belum Ditindak'];

  // Mockup Data Kritik & Saran dengan Hasil Analisis LLM
  final List<Map<String, dynamic>> _suggestionList = [
    {
      'id': 'SUG-001',
      'customerName': 'Siti Rahma',
      'category': 'Kecepatan Respon',
      'content': 'Waktu tunggu ambulans untuk evakuasi kemarin agak lama sekitar 45 menit padahal kondisi darurat. Mohon ditingkatkan sistem dispatch-nya.',
      'date': '26 Okt 2026',
      'sentiment': 'Negatif',
      'aiSummary': 'Keterlambatan respon unit gawat darurat (±45 menit). Pelanggan meminta peningkatan sistem otomatisasi dispatch.',
      'status': 'Belum Ditindak',
    },
    {
      'id': 'SUG-002',
      'customerName': 'Ahmad Dahlan',
      'category': 'Kebersihan & Fasilitas',
      'content': 'Fasilitas di dalam unit ICU keliling sangat bersih dan perawatnya sigap serta ramah sekali. Terima kasih banyak.',
      'date': '25 Okt 2026',
      'sentiment': 'Positif',
      'aiSummary': 'Kepuasan tinggi terhadap kebersihan unit ICU mobile dan keramahan kru medis.',
      'status': 'Selesai',
    },
    {
      'id': 'SUG-003',
      'customerName': 'Dewi Lestari',
      'category': 'Aplikasi & Pemesanan',
      'content': 'Tombol pelacakan GPS di aplikasi kadang macet atau terlambat update posisi ambulans saat jalan.',
      'date': '24 Okt 2026',
      'sentiment': 'Netral',
      'aiSummary': 'Kendala teknis pada fitur GPS live-tracking di aplikasi mobile.',
      'status': 'Diproses',
    },
    {
      'id': 'SUG-004',
      'customerName': 'Bambang Tri',
      'category': 'Kecepatan Respon',
      'content': 'Sangat terbantu dengan layanan transport non-emergency untuk jadwal kontrol rutin orang tua saya.',
      'date': '24 Okt 2026',
      'sentiment': 'Positif',
      'aiSummary': 'Apresiasi positif terhadap layanan ambulans transport untuk pasien rutin.',
      'status': 'Selesai',
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Filter data berdasarkan pilihan chip
    final filteredList = _selectedFilter == 'Semua'
        ? _suggestionList
        : _selectedFilter == 'Belum Ditindak'
            ? _suggestionList.where((item) => item['status'] == 'Belum Ditindak').toList()
            : _suggestionList.where((item) => item['sentiment'] == _selectedFilter).toList();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Judul
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Analisis Respon Pengguna Dengan AI',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Evaluasi masukan pelanggan yang diringkas dan dianalisis otomatis oleh LLM.',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Widget AI Insights Banner / Ringkasan LLM Global dengan Tombol Unduh Laporan
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.08),
                  AppColors.primaryLight.withValues(alpha: 0.15),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ringkasan Analisis Sentimen Mingguan (LLM Insights)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '• Tren Utama: Peningkatan kepuasan pada kru medis, namun terdapat catatan waktu tunggu dispatch di jam sibuk.\n'
                        '• Rekomendasi Tindakan: Periksa latensi pembaruan GPS aplikasi dan optimalkan alokasi unit darurat.',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Tombol Unduh Laporan AI
                ElevatedButton.icon(
                  onPressed: () => _showAiReportPreviewDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.picture_as_pdf_rounded, color: Colors.white, size: 16),
                  label: const Text('Unduh Laporan Analisis', style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _filterOptions.map((filter) {
                final bool isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(filter, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : AppColors.textPrimary)),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.surface,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: isSelected ? AppColors.primary : AppColors.border)),
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Daftar Kartu Kritik & Saran + AI Summary
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: ListView.separated(
                itemCount: filteredList.length,
                separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.border),
                itemBuilder: (context, index) {
                  final item = filteredList[index];
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Baris Atas: Nama Pelanggan, Kategori, Sentimen Badge
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  item['customerName'],
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.border.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(item['category'], style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                // Badge Sentimen
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getSentimentColor(item['sentiment']).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    item['sentiment'],
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _getSentimentColor(item['sentiment'])),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(item['date'], style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Isi Pesan Asli Pelanggan
                        Text(
                          '"${item['content']}"',
                          style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, fontStyle: FontStyle.italic),
                        ),
                        const SizedBox(height: 12),

                        // Kotak Hasil Analisis LLM (AI Summary Card)
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.blueGrey.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blueGrey.withValues(alpha: 0.15)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.psychology_rounded, size: 16, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Analisis LLM / Ringkasan Poin:',
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      item['aiSummary'],
                                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Tombol Aksi Status & Detail
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Text('Status Penanganan: ', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(item['status']).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    item['status'],
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _getStatusColor(item['status'])),
                                  ),
                                ),
                              ],
                            ),
                            TextButton.icon(
                              onPressed: () => _showActionDialog(context, item),
                              icon: const Icon(Icons.edit_note_rounded, size: 16),
                              label: const Text('Update Status', style: TextStyle(fontSize: 12)),
                              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getSentimentColor(String sentiment) {
    switch (sentiment) {
      case 'Positif':
        return AppColors.success;
      case 'Netral':
        return AppColors.secondary;
      case 'Negatif':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Selesai':
        return AppColors.success;
      case 'Diproses':
        return AppColors.secondary;
      case 'Belum Ditindak':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  // Dialog untuk mengubah status penanganan kritik & saran
  void _showActionDialog(BuildContext context, Map<String, dynamic> item) {
    String currentStatus = item['status'];
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Update Status Penanganan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Feedback dari: ${item['customerName']}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              const Text('Status Tindakan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              DropdownButtonFormField<String>(
                value: currentStatus,
                items: ['Belum Ditindak', 'Diproses', 'Selesai']
                    .map((status) => DropdownMenuItem(value: status, child: Text(status, style: const TextStyle(fontSize: 13))))
                    .toList(),
                onChanged: (val) => setStateDialog(() => currentStatus = val!),
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () {
                Navigator.pop(ctx);
                setState(() {
                  item['status'] = currentStatus;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Status penanganan berhasil diperbarui')),
                );
              },
              child: const Text('Simpan', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // Pop-up Preview Dokumen Laporan AI (Google Drive PDF Viewer Style)
  // Pop-up Preview Dokumen Laporan AI (Google Drive PDF Viewer Style)
  void _showAiReportPreviewDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.transparent,
        child: Container(
          width: 650,
          constraints: const BoxConstraints(maxHeight: 750), // <-- Diperbaiki menggunakan constraints
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header Viewer (Style Google Drive bar)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: const BoxDecoration(
                  color: Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0))),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.picture_as_pdf_rounded, color: Colors.redAccent, size: 24),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Laporan_Analisis_Sentimen_LLM_Oktober_2026.pdf',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text('Dibuat otomatis oleh Sistem LLM • 2.4 MB', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.download_rounded, color: AppColors.textPrimary),
                      tooltip: 'Unduh File PDF',
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Laporan PDF berhasil diunduh ke perangkat')),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
                      tooltip: 'Tutup',
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),

              // Body Dokumen Mockup (Kertas Putih Lembar PDF)
              Expanded(
                child: Container(
                  color: const Color(0xFF525659), // Background abu-abu khas PDF reader
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Container(
                        width: 520,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // KOP LAPORAN
                            Center(
                              child: Column(
                                children: [
                                  Text(
                                    'RUMAH SAKIT AMBULANS DARURAT',
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'LAPORAN EKSEKUTIF ANALISIS KRITIK & SARAN (LLM INSIGHTS)',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 8),
                                  Divider(thickness: 1.5, color: Colors.black87),
                                ],
                              ),
                            ),
                            SizedBox(height: 16),

                            // METADATA
                            Text('Periode Laporan: 01 Oktober 2026 – 26 Oktober 2026', style: TextStyle(fontSize: 11, color: Colors.black54)),
                            Text('Total Feedback Dianalisis: 48 Responden', style: TextStyle(fontSize: 11, color: Colors.black54)),
                            SizedBox(height: 20),

                            // I. RINGKASAN EKSEKUTIF
                            Text('I. RINGKASAN EKSEKUTIF', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            SizedBox(height: 6),
                            Text(
                              'Berdasarkan pemrosesan bahasa alami (LLM) terhadap seluruh masukan pelanggan bulan ini, tercatat 65% sentimen positif, 20% netral, dan 15% negatif. Kepuasan tertinggi berada pada keramahan kru ambulans dan kebersihan unit ICU mobile. Namun, perhatian khusus diperlukan terkait waktu tanggap (response time) pada jam sibuk.',
                              style: TextStyle(fontSize: 11, height: 1.5, color: Colors.black87),
                            ),
                            SizedBox(height: 16),

                            // II. POIN MASALAH UTAMA (PAIN POINTS)
                            Text('II. POIN MASALAH UTAMA (PAIN POINTS)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            SizedBox(height: 6),
                            Text(
                              '1. Keterlambatan Respon Darurat:\n'
                              '   Beberapa unit darurat dilaporkan mengalami keterlambatan ±45 menit di jam-jam rawan kemacetan.\n\n'
                              '2. Latensi GPS Live-Tracking:\n'
                              '   Pelanggan mengeluhkan jeda waktu (delay) pada peta pelacakan posisi unit ambulans di dalam aplikasi.',
                              style: TextStyle(fontSize: 11, height: 1.4, color: Colors.black87),
                            ),
                            SizedBox(height: 16),

                            // III. REKOMENDASI TINDAKAN DARI AI
                            Text('III. REKOMENDASI TINDAKAN (ACTION ITEMS)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            SizedBox(height: 6),
                            Text(
                              '• Optimalisasi Dispatch Otomatis: Tinjau ulang algoritma plotting rute terdekat agar unit penjemputan lebih efisien.\n'
                              '• Peningkatan Infrastruktur GPS: Lakukan kalibrasi ulang pada API pemetaan real-time aplikasi mobile.\n'
                              '• Tindak Lanjut Unit Tersedia: Perbanyak unit siaga shift malam pada sektor zona padat penduduk.',
                              style: TextStyle(fontSize: 11, height: 1.4, color: Colors.black87),
                            ),
                            SizedBox(height: 30),

                            // TANDA TANGAN / FOOTER DOKUMEN
                            Align(
                              alignment: Alignment.centerRight,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('Yogyakarta, 26 Oktober 2026', style: TextStyle(fontSize: 10, color: Colors.black54)),
                                  SizedBox(height: 40),
                                  Text('Tim AI & Operasional RS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Footer Modal
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: const BoxDecoration(
                  color: Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
                  border: Border(top: BorderSide(color: Color(0xFFE0E0E0))),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Tutup', style: TextStyle(color: AppColors.textSecondary)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Laporan PDF berhasil diunduh ke perangkat')),
                        );
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                      icon: const Icon(Icons.download_rounded, color: Colors.white, size: 16),
                      label: const Text('Unduh PDF', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}