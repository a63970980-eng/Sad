import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Material 3 design system for Aden Digital.
/// Existing brand colors and navigation are preserved; this layer tightens
/// hierarchy, touch targets, focus states, surfaces, and government-grade polish.
class AppTheme {
  AppTheme._();

  static const double radius = 16;
  static const double radiusLg = 22;

  static ThemeData light(String localeCode) => _build(Brightness.light, localeCode);
  static ThemeData dark(String localeCode) => _build(Brightness.dark, localeCode);

  static TextTheme _textTheme(Brightness brightness, String localeCode) {
    final base = brightness == Brightness.light
        ? ThemeData.light().textTheme
        : ThemeData.dark().textTheme;
    final text = GoogleFonts.cairoTextTheme(base);
    return text.copyWith(
      displaySmall: text.displaySmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.7),
      headlineSmall: text.headlineSmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.4),
      titleLarge: text.titleLarge?.copyWith(fontWeight: FontWeight.w800),
      titleMedium: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      bodyLarge: text.bodyLarge?.copyWith(height: 1.55),
      bodyMedium: text.bodyMedium?.copyWith(height: 1.5),
      labelLarge: text.labelLarge?.copyWith(fontWeight: FontWeight.w700),
    );
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
      secondaryContainer: isLight ? AppColors.accentSoft : AppColors.accentDark,
      onSecondaryContainer: isLight ? AppColors.primaryDark : Colors.white,
      tertiary: AppColors.info,
      onTertiary: Colors.white,
      error: AppColors.danger,
      onError: Colors.white,
      surface: isLight ? AppColors.lightSurface : AppColors.darkSurface,
      onSurface: isLight ? AppColors.lightTextPrimary : AppColors.darkTextPrimary,
      surfaceContainerHighest: isLight ? AppColors.lightBg : AppColors.darkCard,
      onSurfaceVariant: isLight ? AppColors.lightTextSecondary : AppColors.darkTextSecondary,
      outline: isLight ? AppColors.lightBorder : AppColors.darkBorder,
      outlineVariant: isLight ? AppColors.lightBorder : AppColors.darkBorder,
      shadow: Colors.black.withValues(alpha: isLight ? 0.07 : 0.22),
      scrim: Colors.black54,
      inverseSurface: isLight ? AppColors.darkSurface : AppColors.lightSurface,
      onInverseSurface: isLight ? Colors.white : AppColors.lightTextPrimary,
      inversePrimary: AppColors.primaryLight,
      surfaceTint: Colors.transparent,
    );
    final textTheme = _textTheme(brightness, localeCode);
    final outline = BorderSide(color: scheme.outline, width: 1);
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius));

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: isLight ? AppColors.lightBg : AppColors.darkBg,
      textTheme: textTheme,
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      appBarTheme: AppBarTheme(
        backgroundColor: isLight ? AppColors.lightBg : AppColors.darkBg,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        systemOverlayStyle: isLight ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light,
        titleTextStyle: textTheme.titleLarge?.copyWith(color: scheme.onSurface),
      ),
      cardTheme: CardThemeData(
        color: isLight ? AppColors.lightCard : AppColors.darkCard,
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius), side: outline),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          elevation: 0,
          textStyle: textTheme.titleMedium,
          shape: shape,
        ).copyWith(
          overlayColor: WidgetStatePropertyAll(Colors.white.withValues(alpha: 0.10)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          elevation: 0,
          shape: shape,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          minimumSize: const Size.fromHeight(52),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          side: outline,
          shape: shape,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          textStyle: textTheme.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isLight ? Colors.white : AppColors.darkSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        hintStyle: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        labelStyle: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(radius), borderSide: outline),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(radius), borderSide: outline),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.8),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isLight ? Colors.white : AppColors.darkCard,
        side: outline,
        labelStyle: textTheme.labelLarge,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isLight ? AppColors.lightSurface : AppColors.darkSurface,
        modalBackgroundColor: isLight ? AppColors.lightSurface : AppColors.darkSurface,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radiusLg)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: isLight ? AppColors.lightSurface : AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusLg)),
        titleTextStyle: textTheme.titleLarge?.copyWith(color: scheme.onSurface),
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
      ),
      dividerTheme: DividerThemeData(color: scheme.outline, thickness: 1, space: 1),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isLight ? AppColors.lightSurface : AppColors.darkSurface,
        elevation: 0,
        height: 70,
        indicatorColor: AppColors.primarySoft,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) => textTheme.labelMedium?.copyWith(
              fontWeight: states.contains(WidgetState.selected) ? FontWeight.w800 : FontWeight.w600,
              color: states.contains(WidgetState.selected) ? AppColors.primary : scheme.onSurfaceVariant,
            )),
        iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
              size: states.contains(WidgetState.selected) ? 24 : 22,
              color: states.contains(WidgetState.selected) ? AppColors.primary : scheme.onSurfaceVariant,
            )),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isLight ? AppColors.darkSurface : AppColors.lightSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: isLight ? Colors.white : AppColors.lightTextPrimary,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: isLight ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: textTheme.bodySmall?.copyWith(color: isLight ? Colors.white : AppColors.lightTextPrimary),
      ),
    );
  }
}
