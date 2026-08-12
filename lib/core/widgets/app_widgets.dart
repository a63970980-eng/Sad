import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../theme/app_colors.dart';

/// A soft, rounded surface card used throughout the app.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.color,
    this.borderColor,
    this.elevation = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  final Color? borderColor;
  final bool elevation;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: color ?? Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor ?? scheme.outline),
            boxShadow: elevation
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// Section title with optional trailing action.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.icon,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Text(
            title,
            style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(actionLabel!),
          ),
      ],
    );
  }
}

/// Small colored status / category pill.
class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.dense = false,
  });

  final String label;
  final Color color;
  final IconData? icon;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: dense ? 8 : 12, vertical: dense ? 4 : 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: dense ? 12 : 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: dense ? 11 : 12.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Friendly empty-state placeholder.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 44, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            Text(title,
                textAlign: TextAlign.center,
                style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(subtitle!,
                  textAlign: TextAlign.center,
                  style: t.bodyMedium
                      ?.copyWith(color: scheme.onSurfaceVariant)),
            ],
            if (action != null) ...[
              const SizedBox(height: 20),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Shimmer placeholder block.
class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    super.key,
    this.height = 80,
    this.width = double.infinity,
    this.radius = 16,
  });

  final double height;
  final double width;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? AppColors.darkCard : const Color(0xFFE9EEEC),
      highlightColor: isDark ? AppColors.darkBorder : const Color(0xFFF6F8F7),
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

/// Animated circular brand loader.
class BrandLoader extends StatefulWidget {
  const BrandLoader({super.key, this.size = 48});
  final double size;

  @override
  State<BrandLoader> createState() => _BrandLoaderState();
}

class _BrandLoaderState extends State<BrandLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 1))
        ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: RotationTransition(
        turns: _c,
        child: CustomPaint(painter: _LoaderPainter()),
      ),
    );
  }
}

class _LoaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..shader = const SweepGradient(
        colors: [AppColors.primary, AppColors.primaryLight, Colors.transparent],
        stops: [0.0, 0.6, 1.0],
      ).createShader(rect)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawArc(rect.deflate(2), 0, 5.4, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
