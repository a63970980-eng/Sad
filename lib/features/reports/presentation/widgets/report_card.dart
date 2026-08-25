import 'dart:io' show File;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/app_widgets.dart';
import '../../domain/entities/report.dart';

class ReportCard extends StatelessWidget {
  const ReportCard({
    super.key,
    required this.report,
    required this.categoryLabel,
    required this.statusLabel,
    required this.dateLabel,
    required this.onTap,
  });

  final Report report;
  final String categoryLabel;
  final String statusLabel;
  final String dateLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: report.category.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(report.category.icon,
                    color: report.category.color, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(report.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            t.bodyLarge?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 3),
                    Text(categoryLabel,
                        style: t.bodySmall
                            ?.copyWith(color: report.category.color)),
                  ],
                ),
              ),
              StatusPill(
                  label: statusLabel, color: report.status.color, dense: true),
            ],
          ),
          const SizedBox(height: 10),
          Text(report.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: t.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
          if (report.photos.isNotEmpty) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 56,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: report.photos.length.clamp(0, 4),
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) => ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: _Thumb(path: report.photos[i]),
                ),
              ),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.confirmation_number_outlined,
                  size: 14, color: scheme.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(report.id,
                  style:
                      t.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
              const Spacer(),
              Icon(Icons.schedule_rounded,
                  size: 14, color: scheme.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(dateLabel,
                  style:
                      t.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.path});
  final String path;

  @override
  Widget build(BuildContext context) {
    if (path.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: path,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        placeholder: (_, __) => const ShimmerBox(width: 56, height: 56, radius: 10),
        errorWidget: (_, __, ___) =>
            const Icon(Icons.broken_image_outlined),
      );
    }
    if (kIsWeb) {
      return Image.network(path,
          width: 56, height: 56, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(Icons.broken_image_outlined));
    }
    return Image.file(File(path),
        width: 56, height: 56, fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image_outlined));
  }
}
