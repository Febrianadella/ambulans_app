import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class LiveTrackingPage extends StatelessWidget {
  final String orderId;

  const LiveTrackingPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pelacakan Ambulans #$orderId')),
      body: Stack(
        children: [
          // Placeholder container untuk Map (Google Maps / OpenStreetMap)
          Container(
            color: Colors.blueGrey.shade100,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map_outlined, size: 72, color: Colors.blueGrey),
                  SizedBox(height: 8),
                  Text(
                    'Peta Pelacakan Posisi GPS Ambulans Real-Time',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.blueGrey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: AppColors.primaryLight,
                          child: Icon(
                            Icons.airport_shuttle,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ambulans Darurat #B-119-MED',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Estimasi Tiba: 8 Menit (3.2 km)',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.phone,
                            color: AppColors.success,
                          ),
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
}
