import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// Komponen tahapan perjalanan ambulans (5 tahap: Konfirmasi, Menuju Jemput,
/// Pasien Dijemput, Menuju RS, Selesai) dengan desain modern, responsif, dan bebas overflow.
class TripProgressStepper extends StatelessWidget {
  final int currentStep;

  const TripProgressStepper({super.key, required this.currentStep});

  static const List<Map<String, String>> stages = [
    {'title': 'Konfirmasi', 'subtitle': 'Validasi & Penugasan'},
    {'title': 'Menuju Jemput', 'subtitle': 'Perjalanan Sopir'},
    {'title': 'Pasien Dijemput', 'subtitle': 'Penanganan Medis'},
    {'title': 'Menuju RS', 'subtitle': 'Perjalanan ke Faskes'},
    {'title': 'Selesai', 'subtitle': 'Serah Terima Pasien'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Tahapan Perjalanan
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.timeline_rounded,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Alur Tahapan Perjalanan Ambulans',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: currentStep == 4
                      ? AppColors.successLight
                      : AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Tahap ${currentStep + 1} dari 5',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: currentStep == 4
                        ? AppColors.success
                        : AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Stepper Bar Horizontal Responsif
          Row(
            children: List.generate(stages.length, (index) {
              final isPassed = index < currentStep;
              final isCurrent = index == currentStep;

              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Bulatan Indikator Tahap
                          Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isCurrent
                                  ? AppColors.primary
                                  : (isPassed
                                        ? (index == 4
                                              ? AppColors.success
                                              : AppColors.primary)
                                        : Colors.white),
                              border: Border.all(
                                color: isCurrent || isPassed
                                    ? (index == 4
                                          ? AppColors.success
                                          : AppColors.primary)
                                    : AppColors.border,
                                width: 2,
                              ),
                              boxShadow: isCurrent
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primary.withValues(
                                          alpha: 0.3,
                                        ),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Center(
                              child: isCurrent && index > 0 && index < 4
                                  ? const Icon(
                                      Icons.airport_shuttle,
                                      size: 13,
                                      color: Colors.white,
                                    )
                                  : (isPassed
                                        ? const Icon(
                                            Icons.check,
                                            size: 14,
                                            color: Colors.white,
                                          )
                                        : Text(
                                            '${index + 1}',
                                            style: const TextStyle(
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textSecondary,
                                            ),
                                          )),
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Judul Tahap
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              stages[index]['title']!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: isCurrent
                                    ? FontWeight.bold
                                    : FontWeight.w600,
                                color: isCurrent
                                    ? AppColors.primary
                                    : (isPassed
                                          ? AppColors.textPrimary
                                          : AppColors.textSecondary),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (index < stages.length - 1)
                      Container(
                        height: 2.5,
                        width: 10,
                        color: index < currentStep
                            ? AppColors.primary
                            : AppColors.border,
                        margin: const EdgeInsets.only(bottom: 18),
                      ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
