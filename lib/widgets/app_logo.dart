import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showWordmark;
  final Color? wordmarkColor;

  const AppLogo({
    super.key,
    this.size = 34,
    this.showWordmark = true,
    this.wordmarkColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.navy],
            ),
            borderRadius: BorderRadius.circular(size * 0.28),
          ),
          child: Icon(
            Icons.shield_outlined,
            color: Colors.white,
            size: size * 0.6,
          ),
        ),
        if (showWordmark) ...[
          const SizedBox(width: 10),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'BuildGuard',
                  style: TextStyle(
                    fontSize: size * 0.42,
                    fontWeight: FontWeight.w800,
                    color: wordmarkColor ?? AppColors.navy,
                  ),
                ),
                TextSpan(
                  text: ' AI',
                  style: TextStyle(
                    fontSize: size * 0.42,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
