import 'package:flutter/material.dart';

/// Central visual identity for Aden Digital.
/// Restrained government green, institutional gold, and service blue.
class AppColors {
  AppColors._();

  // Brand core
  static const Color primary = Color(0xFF0E7C52);
  static const Color primaryDark = Color(0xFF075C3D);
  static const Color primaryLight = Color(0xFF35A074);
  static const Color primarySoft = Color(0xFFE8F4EF);
  static const Color primarySurface = Color(0xFFF3F8F6);

  // Institutional accent — use sparingly for emphasis.
  static const Color accent = Color(0xFFCBA14B);
  static const Color accentDark = Color(0xFF9C7628);
  static const Color accentSoft = Color(0xFFF7F0DF);

  // Service / navigation blue
  static const Color info = Color(0xFF2563EB);
  static const Color infoSoft = Color(0xFFEAF0FF);

  // Semantic status colors
  static const Color success = Color(0xFF16803C);
  static const Color warning = Color(0xFFB76E00);
  static const Color danger = Color(0xFFC62828);
  static const Color pending = Color(0xFF5B5BD6);

  // Light surfaces
  static const Color lightBg = Color(0xFFF6F8F7);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFDCE5E1);
  static const Color lightTextPrimary = Color(0xFF13201B);
  static const Color lightTextSecondary = Color(0xFF5B6B64);
  static const Color lightTextTertiary = Color(0xFF7A8982);

  // Dark surfaces
  static const Color darkBg = Color(0xFF0C1411);
  static const Color darkSurface = Color(0xFF121D18);
  static const Color darkCard = Color(0xFF18251F);
  static const Color darkBorder = Color(0xFF2A3932);
  static const Color darkTextPrimary = Color(0xFFECF3EF);
  static const Color darkTextSecondary = Color(0xFFA5B5AD);

  // Signature surfaces — reserved for hero/CTA moments.
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [Color(0xFF15956B), primaryDark],
  );
}
