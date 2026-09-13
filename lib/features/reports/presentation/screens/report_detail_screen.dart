import 'dart:io' show File;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/settings_controller.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/l10n_lookup.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/report.dart';
import '../providers/report_providers.dart';
import '../widgets/timeline_view.dart';

class ReportDetailScreen extends ConsumerWidget {
  const ReportDetailScreen({super.key, required this.reportId});
  final String reportId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final locale = ref.watch(settingsControllerProvider).locale.languageCode;
    final reportAsync = ref.watch(reportByIdProvider(reportId));
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l.details)),
      body: reportAsync.when(
        loading: () => const Center(child: BrandLoader()),
        error: (_, __) => EmptyState(
            icon: Icons.error_outline_rounded, title: l.errorGeneric),
        data: (report) {
          if (report == null) {
            return EmptyState(
                icon: Icons.search_off_rounded, title: l.noReports);
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            children: [
              _ReportHero(report: report, locale: locale),
              const SizedBox(height: 16),
              AppCard(
                padding: const EdgeInsets.fromLTRB(16, 15, 16, 17),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.details,
                      style: t.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 14),
                    _InfoRow(
                      icon: Icons.confirmation_number_outlined,
                      label: report.id,
                    ),
                    const SizedBox(height: 11),
                    _InfoRow(
                      icon: Icons.calendar_today_outlined,
                      label: Formatters.dateTime(report.createdAt, locale),
                    ),
                    if (report.address != null) ...[
                      const SizedBox(height: 11),
                      _InfoRow(
                        icon: Icons.location_on_outlined,
                        label: report.address!,
                      ),
                    ],
                    const SizedBox(height: 16),
                    Divider(color: scheme.outline),
                    const SizedBox(height: 14),
                    Text(
                      report.description,
                      style: t.bodyMedium?.copyWith(
                        color: scheme.onSurface,
                        height: 1.65,
                      ),
                    ),
                  ],
                ),
              ),
              if (report.photos.isNotEmpty) ...[
                const SizedBox(height: 18),
                SectionHeader(title: l.reportPhotos, icon: Icons.image_outlined),
                const SizedBox(height: 10),
                SizedBox(
                  height: 112,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: report.photos.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (_, i) => ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: _Photo(path: report.photos[i]),
                    ),
                  ),
                ),
              ],
              if (report.hasLocation) ...[
                const SizedBox(height: 18),
                SectionHeader(title: l.reportLocation, icon: Icons.map_outlined),
                const SizedBox(height: 10),
                _MiniMap(report: report),
              ],
              const SizedBox(height: 22),
              SectionHeader(title: l.reportTimeline, icon: Icons.timeline_rounded),
              const SizedBox(height: 12),
              AppCard(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                child: TimelineView(entries: report.timeline, locale: locale),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ReportHero extends StatelessWidget {
  const _ReportHero({required this.report, required this.locale});
  final Report report;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outline),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: report.category.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(report.category.icon,
                color: report.category.color, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: t.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 5),
                Text(
                  tr(l, report.category.labelKey),
                  style: t.bodySmall?.copyWith(
                    color: report.category.color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                StatusPill(
                  label: tr(l, report.status.labelKey),
                  color: report.status.color,
                  dense: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 17, color: scheme.onSurfaceVariant),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ),
      ],
    );
  }
}

class _Photo extends StatelessWidget {
  const _Photo({required this.path});
  final String path;

  Widget _fallback(BuildContext context) => Container(
        width: 132,
        height: 112,
        color: AppColors.primarySoft,
        child: Icon(
          Icons.image_outlined,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      );

  @override
  Widget build(BuildContext context) {
    if (path.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: path,
        width: 132,
        height: 112,
        fit: BoxFit.cover,
        placeholder: (_, __) => _fallback(context),
        errorWidget: (_, __, ___) => _fallback(context),
      );
    }
    if (kIsWeb) {
      return Image.network(
        path,
        width: 132,
        height: 112,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallback(context),
      );
    }
    return Image.file(
      File(path),
      width: 132,
      height: 112,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _fallback(context),
    );
  }
}

class _MiniMap extends StatelessWidget {
  const _MiniMap({required this.report});
  final Report report;

  @override
  Widget build(BuildContext context) {
    // Dependency-free preview retained so location remains useful without a Maps API key.
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: 154,
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.outline),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(child: CustomPaint(painter: _MapGridPainter(scheme.outline))),
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.88),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.18),
                  blurRadius: 18,
                ),
              ],
            ),
            child: const Icon(Icons.location_on, color: AppColors.danger, size: 38),
          ),
          Positioned(
            left: 12,
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: scheme.outline),
              ),
              child: Text(
                '${report.latitude!.toStringAsFixed(4)}, ${report.longitude!.toStringAsFixed(4)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: StatusPill(
              label: l.locationCaptured,
              color: AppColors.primary,
              icon: Icons.check_circle,
              dense: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  const _MapGridPainter(this.lineColor);
  final Color lineColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor.withValues(alpha: 0.32)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    for (var x = -size.height; x < size.width + size.height; x += 46) {
      canvas.drawLine(Offset(x, 0), Offset(x + size.height, size.height), paint);
    }
    for (var x = 10.0; x < size.width; x += 74) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _MapGridPainter oldDelegate) =>
      oldDelegate.lineColor != lineColor;
}
