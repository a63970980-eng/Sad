import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Builds the Material 3 light & dark themes with a premium government look.
class AppTheme {
  AppTheme._();

  static const double radius = 18;
  static const double radiusLg = 24;

  static ThemeData light(String localeCode) => _build(Brightness.light, localeCode);
  static ThemeData dark(String localeCode) => _build(Brightness.dark, localeCode);

  static TextTheme _textTheme(Brightness brightness, String localeCode) {
    final base = brightness == Brightness.light
        ? ThemeData.light().textTheme
        : ThemeData.dark().textTheme;
    // Cairo reads beautifully in Arabic; falls back gracefully for English.
    return GoogleFonts.cairoTextTheme(base);
  }

  static ThemeData _build(Brightness brightness, String localeCode) {
    final isLight = brightness == Brightness.light;

    final scheme = ColorScheme(
      brightness: brightness,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: isLight ? AppColors.primarySoft : AppColors.primaryDark,
      onPrimaryContainer: isLight ? AppColors.primaryDark : AppColors.primarySoft,
      secondary: AppColors.accent,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.accentSoft,
      onSecondaryContainer: AppColors.primaryDark,
      tertiary: AppColors.info,
      onTertiary: Colors.white,
      error: AppColors.danger,
      onError: Colors.white,
      surface: isLight ? AppColors.lightSurface : AppColors.darkSurface,
      onSurface: isLight ? AppColors.lightTextPrimary : AppColors.darkTextPrimary,
      surfaceContainerHighest: isLight ? AppColors.lightBg : AppColors.darkCard,
      onSurfaceVariant:
          isLight ? AppColors.lightTextSecondary : AppColors.darkTextSecondary,
      outline: isLight ? AppColors.lightBorder : AppColors.darkBorder,
      outlineVariant: isLight ? AppColors.lightBorder : AppColors.darkBorder,
      shadow: Colors.black.withValues(alpha: 0.08),
      scrim: Colors.black54,
      inverseSurface: isLight ? AppColors.darkSurface : AppColors.lightSurface,
      onInverseSurface: isLight ? Colors.white : AppColors.lightTextPrimary,
      inversePrimary: AppColors.primaryLight,
      surfaceTint: Colors.transparent,
    );

    final textTheme = _textTheme(brightness, localeCode);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: isLight ? AppColors.lightBg : AppColors.darkBg,
      textTheme: textTheme,
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      appBarTheme: AppBarTheme(
        backgroundColor: isLight ? AppColors.lightBg : AppColors.darkBg,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: true,
        systemOverlayStyle:
            isLight ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        color: isLight ? AppColors.lightCard : AppColors.darkCard,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: BorderSide(color: scheme.outline, width: 1),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(54),
          elevation: 0,
          textStyle: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(54),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          minimumSize: const Size.fromHeight(54),
          side: BorderSide(color: scheme.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: scheme.primary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isLight ? Colors.white : AppColors.darkSurface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: scheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: scheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isLight ? Colors.white : AppColors.darkCard,
        side: BorderSide(color: scheme.outline),
        labelStyle: textTheme.labelLarge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isLight ? AppColors.lightSurface : AppColors.darkSurface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radiusLg)),
        ),
      ),
      dividerTheme: DividerThemeData(color: scheme.outline, thickness: 1),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isLight ? AppColors.lightSurface : AppColors.darkSurface,
        elevation: 0,
        height: 70,
        indicatorColor: AppColors.primarySoft,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: states.contains(WidgetState.selected)
                ? AppColors.primary
                : scheme.onSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(
            color: states.contains(WidgetState.selected)
                ? AppColors.primary
                : scheme.onSurfaceVariant,
          );
        }),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}
