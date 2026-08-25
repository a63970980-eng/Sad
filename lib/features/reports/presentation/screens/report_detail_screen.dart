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
              Row(
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
                        Text(report.title,
                            style: t.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 4),
                        Text(tr(l, report.category.labelKey),
                            style: t.bodySmall
                                ?.copyWith(color: report.category.color)),
                      ],
                    ),
                  ),
                  StatusPill(
                      label: tr(l, report.status.labelKey),
                      color: report.status.color),
                ],
              ),
              const SizedBox(height: 16),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoRow(
                        icon: Icons.confirmation_number_outlined,
                        label: report.id),
                    const SizedBox(height: 10),
                    _InfoRow(
                        icon: Icons.calendar_today_outlined,
                        label: Formatters.dateTime(report.createdAt, locale)),
                    if (report.address != null) ...[
                      const SizedBox(height: 10),
                      _InfoRow(
                          icon: Icons.location_on_outlined,
                          label: report.address!),
                    ],
                    const SizedBox(height: 14),
                    Text(report.description,
                        style: t.bodyMedium
                            ?.copyWith(color: scheme.onSurface)),
                  ],
                ),
              ),
              if (report.photos.isNotEmpty) ...[
                const SizedBox(height: 16),
                SectionHeader(title: l.reportPhotos, icon: Icons.image_outlined),
                const SizedBox(height: 10),
                SizedBox(
                  height: 110,
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
                const SizedBox(height: 16),
                SectionHeader(
                    title: l.reportLocation, icon: Icons.map_outlined),
                const SizedBox(height: 10),
                _MiniMap(report: report),
              ],
              const SizedBox(height: 20),
              SectionHeader(
                  title: l.reportTimeline, icon: Icons.timeline_rounded),
              const SizedBox(height: 14),
              AppCard(
                child: TimelineView(
                    entries: report.timeline, locale: locale),
              ),
            ],
          );
        },
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
      children: [
        Icon(icon, size: 18, color: scheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label,
              style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}

class _Photo extends StatelessWidget {
  const _Photo({required this.path});
  final String path;
  @override
  Widget build(BuildContext context) {
    if (path.startsWith('http')) {
      return CachedNetworkImage(
          imageUrl: path, width: 130, height: 110, fit: BoxFit.cover);
    }
    if (kIsWeb) {
      return Image.network(path,
          width: 130, height: 110, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
              width: 130,
              height: 110,
              color: AppColors.primarySoft,
              child: const Icon(Icons.image_outlined)));
    }
    return Image.file(File(path),
        width: 130, height: 110, fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
            width: 130,
            height: 110,
            color: AppColors.primarySoft,
            child: const Icon(Icons.image_outlined)));
  }
}

class _MiniMap extends StatelessWidget {
  const _MiniMap({required this.report});
  final dynamic report;

  @override
  Widget build(BuildContext context) {
    // Static, dependency-free location preview (works without Maps API key).
    final l = AppLocalizations.of(context);
    return Container(
      height: 140,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFDDEAE3), Color(0xFFC4DBD0)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(Icons.location_on, color: AppColors.danger, size: 44),
          Positioned(
            bottom: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${report.latitude.toStringAsFixed(4)}, ${report.longitude.toStringAsFixed(4)}',
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
                dense: true),
          ),
        ],
      ),
    );
  }
}
