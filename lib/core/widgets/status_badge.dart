import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.icon,
  });

  factory StatusBadge.success(String label, {IconData? icon}) {
    return StatusBadge(
      label: label,
      backgroundColor: AppColors.successLight,
      textColor: const Color(0xFF047857),
      icon: icon ?? Icons.check_circle_rounded,
    );
  }

  factory StatusBadge.warning(String label, {IconData? icon}) {
    return StatusBadge(
      label: label,
      backgroundColor: AppColors.warningLight,
      textColor: const Color(0xFFB45309),
      icon: icon ?? Icons.access_time_filled_rounded,
    );
  }

  factory StatusBadge.info(String label, {IconData? icon}) {
    return StatusBadge(
      label: label,
      backgroundColor: AppColors.infoLight,
      textColor: const Color(0xFF1D4ED8),
      icon: icon ?? Icons.info_rounded,
    );
  }

  factory StatusBadge.error(String label, {IconData? icon}) {
    return StatusBadge(
      label: label,
      backgroundColor: AppColors.errorLight,
      textColor: const Color(0xFFB91C1C),
      icon: icon ?? Icons.cancel_rounded,
    );
  }

  factory StatusBadge.neutral(String label, {IconData? icon}) {
    return StatusBadge(
      label: label,
      backgroundColor: const Color(0xFFF3F4F6),
      textColor: AppColors.textSecondary,
      icon: icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withValues(alpha: 0.2), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: textColor),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
