import 'package:flutter/material.dart';
import '../utils/constants.dart';

class DiseaseBadge extends StatelessWidget {
  final String diseaseName;
  final double confidence;

  const DiseaseBadge({super.key, required this.diseaseName, required this.confidence});

  @override
  Widget build(BuildContext context) {
    final bool isHealthy = diseaseName.toLowerCase() == 'healthy';
    final Color badgeColor = isHealthy ? AppColors.primary : AppColors.danger;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        border: Border.all(color: badgeColor, width: 2),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isHealthy ? Icons.check_circle : Icons.warning,
            color: badgeColor,
          ),
          const SizedBox(width: 8),
          Text(
            '$diseaseName (${(confidence * 100).toStringAsFixed(1)}%)',
            style: TextStyle(
              color: badgeColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
