import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/status_badge.dart';

class LlmAnalysisDetailPage extends StatelessWidget {
  const LlmAnalysisDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analisis Kritik & Saran (LLM)'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bolt, color: Color(0xFF4F46E5), size: 14),
                SizedBox(width: 4),
                Text(
                  'LLM Module Ready',
                  style: TextStyle(
                    color: Color(0xFF4F46E5),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thesis Title Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFC7D2FE)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.school_outlined,
                    color: Color(0xFF4F46E5),
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fokus Skripsi: Analisis Sentimen & Ekstraksi Masukan dengan LLM',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF3730A3),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Sistem secara otomatis mengekstraksi topik keluhan, sentimen pengguna, dan merumuskan rekomendasi perbaikan kualitas operasional layanan ambulans.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF4338CA),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Metrics Row
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    'Total Masukan',
                    '47',
                    'Bulan Oktober 2026',
                    Icons.rate_review_outlined,
                    AppColors.secondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricTile(
                    'Sentimen Positif',
                    '74%',
                    '35 dari 47 ulasan',
                    Icons.sentiment_satisfied_alt_outlined,
                    AppColors.success,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricTile(
                    'Perlu Perbaikan',
                    '12',
                    'Topik keluhan aktif',
                    Icons.warning_amber_rounded,
                    AppColors.warning,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Topik Utama Ekstraksi LLM
            const Text(
              'Distribusi Topik Keluhan Berdasarkan Ekstraksi LLM',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _buildTopicProgressBar(
              'Waktu Tunggu Penjemputan (Traffic/Rute)',
              0.45,
              '45% (18 keluhan)',
            ),
            _buildTopicProgressBar(
              'Kenyamanan & Suspensi Armada',
              0.25,
              '25% (10 keluhan)',
            ),
            _buildTopicProgressBar(
              'Kemudahan Pembayaran & Validasi',
              0.18,
              '18% (7 keluhan)',
            ),
            _buildTopicProgressBar(
              'Komunikasi Penjemputan di Titik Temu',
              0.12,
              '12% (5 keluhan)',
            ),

            const SizedBox(height: 24),

            // Rekomendasi LLM Actionable
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.psychology_outlined,
                        color: Color(0xFF4F46E5),
                        size: 22,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Rekomendasi Strategis dari Analisis LLM',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildRecommendationItem(
                    1,
                    'Optimalisasi Radius Disposisi Driver',
                    'LLM mendeteksi 45% keluhan waktu tunggu disebabkan penugasan armada dari pangkalan yang lebih jauh saat jam sibuk. Disarankan algoritma matching memprioritaskan unit terdekat berbasis live traffic GPS.',
                  ),
                  _buildRecommendationItem(
                    2,
                    'Pengecekan Rutin Suspensi Armada B-119-MED',
                    'Ulasan pengguna spesifik menyebutkan guncangan pada rute jalan lingkar selatan pada ambulans unit 03 dan 07.',
                  ),
                  _buildRecommendationItem(
                    3,
                    'Integrasi Notifikasi Status Validasi Otomatis',
                    'Mengurangi pertanyaan manual dengan mengaktifkan push notification instan saat bukti transfer terverifikasi oleh admin.',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Contoh Data Kritik & Saran Masuk (Sample Data Demo)
            const Text(
              'Sampel Kritik & Saran yang Dianalisis (Data Demo Teruji):',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _buildFeedbackSample(
              user: 'Keluarga Pasien Ny. Siti',
              date: '22 Okt 2026, 14:10 WIB',
              rating: 4.0,
              text: 'Sopir dan perawat sangat cekatan saat menangani pasien. Hanya saja tadi waktu tunggu penjemputan agak lama sekitar 15 menit karena macet di lampu merah.',
              llmTopic: 'Waktu Tunggu Penjemputan',
              sentiment: 'Netral-Positif',
            ),
            _buildFeedbackSample(
              user: 'Bpk. Hendro',
              date: '21 Okt 2026, 09:30 WIB',
              rating: 5.0,
              text: 'Aplikasi sangat membantu di situasi genting! Ambulans datang cepat dan peralatan medis di dalamnya lengkap.',
              llmTopic: 'Kualitas Pelayanan',
              sentiment: 'Positif',
            ),
            _buildFeedbackSample(
              user: 'Ibu Ratna',
              date: '20 Okt 2026, 19:45 WIB',
              rating: 3.0,
              text: 'Pemberitahuan bahwa ambulans sudah tiba agak terlambat muncul di HP, jadi kami sempat bingung menunggu di luar pagar.',
              llmTopic: 'Komunikasi & Notifikasi',
              sentiment: 'Keluhan',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile(
    String title,
    String value,
    String sub,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            sub,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicProgressBar(
    String title,
    double fraction,
    String percentText,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                percentText,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: fraction,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
              minHeight: 7,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationItem(int number, String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 11,
            backgroundColor: const Color(0xFF6366F1).withValues(alpha: 0.15),
            child: Text(
              '$number',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4F46E5),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  body,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackSample({
    required String user,
    required String date,
    required double rating,
    required String text,
    required String llmTopic,
    required String sentiment,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                user,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.star, size: 14, color: AppColors.warning),
                  const SizedBox(width: 2),
                  Text(
                    '$rating',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            date,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '"$text"',
            style: const TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              StatusBadge.info(llmTopic, icon: Icons.sell_outlined),
              const SizedBox(width: 8),
              sentiment.contains('Positif')
                  ? StatusBadge.success(sentiment)
                  : (sentiment.contains('Keluhan')
                        ? StatusBadge.error(sentiment)
                        : StatusBadge.warning(sentiment)),
            ],
          ),
        ],
      ),
    );
  }
}
