import 'package:flutter/material.dart';
import '../models/project.dart';
import '../theme/app_theme.dart';

class RiskBadge extends StatelessWidget {
  final RiskLevel level;
  const RiskBadge({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    late Color color;
    late String label;
    switch (level) {
      case RiskLevel.high:
        color = AppColors.danger;
        label = 'High Risk';
        break;
      case RiskLevel.medium:
        color = AppColors.amber;
        label = 'Medium Risk';
        break;
      case RiskLevel.low:
        color = AppColors.success;
        label = 'Low Risk';
        break;
      case RiskLevel.pending:
        color = AppColors.textMuted;
        label = 'Pending';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
