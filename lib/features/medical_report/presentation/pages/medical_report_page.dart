import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class MedicalReportPage extends StatelessWidget {
  final String orderId;

  const MedicalReportPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Laporan Medis Pasien #$orderId')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.secondaryLight.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.secondary.withValues(alpha: 0.3),
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.medical_services, color: AppColors.secondary),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Input data tanda-tanda vital oleh Perawat & validasi Dokter',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Nama Pasien',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Tekanan Darah (mmHg)',
                      hintText: '120/80',
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Detak Jantung (bpm)',
                      hintText: '80',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Saturasi Oksigen (%)',
                      hintText: '98',
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Suhu Tubuh (°C)',
                      hintText: '36.5',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const TextField(
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Catatan Kondisi Pasien (Perawat)',
                hintText: 'Deskripsikan kondisi klinis, respon kesadaran, dan penanganan awal...',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.save),
              label: const Text('Simpan Laporan Medis'),
            ),
          ],
        ),
      ),
    );
  }
}
