import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// A clean, emblem-style logo mark for Aden Digital (no external assets).
class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.size = 96, this.showGlow = true});

  final double size;
  final bool showGlow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: showGlow
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                ),
              ]
            : null,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.account_balance_rounded,
              color: Colors.white.withValues(alpha: 0.95), size: size * 0.5),
          Positioned(
            bottom: size * 0.16,
            child: Container(
              width: size * 0.34,
              height: 3,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
