import 'package:flutter/material.dart';

import '../../domain/entities/order_entity.dart';
import '../../../../core/constants/app_colors.dart';

class BookingPage extends StatelessWidget {
  const BookingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pemesanan Ambulans Darurat')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: AppColors.primaryLight.withValues(alpha: 0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.primary,
                      size: 32,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Panggilan darurat ambulans akan segera diteruskan ke unit terdekat!',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Lokasi Penjemputan',
                prefixIcon: Icon(Icons.my_location, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Rumah Sakit Tujuan',
                prefixIcon: Icon(
                  Icons.local_hospital,
                  color: AppColors.secondary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const TextField(
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Kondisi Pasien / Catatan Tambahan',
                prefixIcon: Icon(Icons.notes),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Tahapan Status Pemesanan:',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 12),
            ...OrderStatus.values.map(
              (status) => ListTile(
                dense: true,
                leading: const Icon(
                  Icons.check_circle_outline,
                  color: AppColors.secondary,
                ),
                title: Text(status.label),
                subtitle: Text('Kode status: ${status.value}'),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.emergency),
              label: const Text('Pesan Ambulans Sekarang'),
            ),
          ],
        ),
      ),
    );
  }
}
