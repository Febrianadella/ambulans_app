import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class RatingPage extends StatefulWidget {
  final String orderId;

  const RatingPage({super.key, required this.orderId});

  @override
  State<RatingPage> createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  int _selectedRating = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Beri Ulasan Layanan #${widget.orderId}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.star_rounded, size: 64, color: AppColors.warning),
            const SizedBox(height: 12),
            Text(
              'Bagaimana Pelayanan Ambulans Kami?',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Masukan Anda sangat berharga untuk meningkatkan mutu respon darurat kami.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starIndex = index + 1;
                return IconButton(
                  icon: Icon(
                    starIndex <= _selectedRating
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: AppColors.warning,
                    size: 36,
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedRating = starIndex;
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 24),
            const TextField(
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Ulasan / Catatan untuk Pengemudi & Tim Medis',
                hintText: 'Tuliskan pengalaman Anda...',
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Terima kasih atas penilaian Anda!'),
                    ),
                  );
                },
                child: const Text('Kirim Ulasan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
