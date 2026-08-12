import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../widgets/brand_logo.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.heroGradient),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const BrandLogo(size: 110)
                    .animate()
                    .scale(duration: 600.ms, curve: Curves.easeOutBack)
                    .fadeIn(),
                const SizedBox(height: 28),
                Text(
                  l.appName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                  ),
                ).animate().fadeIn(delay: 250.ms).moveY(begin: 12, end: 0),
                const SizedBox(height: 10),
                Text(
                  l.appTagline,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 15,
                  ),
                ).animate().fadeIn(delay: 450.ms),
                const SizedBox(height: 48),
                const SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                ).animate().fadeIn(delay: 700.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
