import 'package:flutter/material.dart';

/// Central color palette for Aden Digital.
/// Government green primary with elegant supporting tones.
class AppColors {
  AppColors._();

  // Brand — deep government green
  static const Color primary = Color(0xFF0E7C52);
  static const Color primaryDark = Color(0xFF0A5C3D);
  static const Color primaryLight = Color(0xFF35A074);
  static const Color primarySoft = Color(0xFFE6F4EE);

  // Accent — warm gold (official seal feel)
  static const Color accent = Color(0xFFCBA14B);
  static const Color accentSoft = Color(0xFFF6EFDD);

  // Secondary — trust blue (used for info / map)
  static const Color info = Color(0xFF2563EB);
  static const Color infoSoft = Color(0xFFE6EEFF);

  // Status colors
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFDC2626);
  static const Color pending = Color(0xFF6366F1);

  // Neutrals — light
  static const Color lightBg = Color(0xFFF5F7F6);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE6EAE8);
  static const Color lightTextPrimary = Color(0xFF13201B);
  static const Color lightTextSecondary = Color(0xFF5C6B64);

  // Neutrals — dark
  static const Color darkBg = Color(0xFF0E1512);
  static const Color darkSurface = Color(0xFF16201C);
  static const Color darkCard = Color(0xFF1B2723);
  static const Color darkBorder = Color(0xFF2A3631);
  static const Color darkTextPrimary = Color(0xFFEAF1ED);
  static const Color darkTextSecondary = Color(0xFF9DAEA6);

  // Gradients
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0E7C52), Color(0xFF0A5C3D)],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [Color(0xFF13936A), Color(0xFF0A5C3D)],
  );
}
