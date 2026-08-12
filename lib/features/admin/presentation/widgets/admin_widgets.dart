import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/dashboard_stats.dart';

class StatsCard extends StatelessWidget {
  const StatsCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.trend,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final double? trend;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                if (trend != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (trend! > 0 ? AppColors.success : AppColors.danger)
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${trend! > 0 ? '+' : ''}${trend!.toStringAsFixed(1)}%',
                      style: t.labelSmall?.copyWith(
                        color: trend! > 0 ? AppColors.success : AppColors.danger,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: t.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: t.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProgressBar extends StatelessWidget {
  const ProgressBar({
    required this.label,
    required this.value,
    required this.max,
    required this.color,
  });

  final String label;
  final int value;
  final int max;
  final Color color;

  double get percentage => max == 0 ? 0 : (value / max) * 100;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: t.labelMedium?.copyWith(fontWeight: FontWeight.w600)),
            Text(
              '$value / $max',
              style: t.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percentage / 100,
            minHeight: 8,
            backgroundColor: color.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}

class RegionalStatsCard extends StatelessWidget {
  const RegionalStatsCard({required this.stats});

  final RegionalReportStats stats;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                stats.region,
                style: t.labelLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${stats.completionPercentage.toStringAsFixed(0)}%',
                  style: t.labelSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ProgressBar(
            label: 'محلول',
            value: stats.resolved,
            max: stats.total,
            color: AppColors.success,
          ),
          const SizedBox(height: 12),
          ProgressBar(
            label: 'معلق',
            value: stats.pending,
            max: stats.total,
            color: AppColors.warning,
          ),
        ],
      ),
    );
  }
}
