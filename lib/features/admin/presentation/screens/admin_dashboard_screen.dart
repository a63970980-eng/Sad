import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/admin_providers.dart';
import '../widgets/admin_widgets.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final statsAsync = ref.watch(dashboardStatsProvider);
    final regionalStatsAsync = ref.watch(regionalStatsProvider);
    final recentActivityAsync = ref.watch(recentActivityProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.adminDashboard),
        elevation: 0,
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dashboardStatsProvider);
          ref.invalidate(regionalStatsProvider);
          ref.invalidate(recentActivityProvider);
          await Future.delayed(const Duration(milliseconds: 600));
        },
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Main Stats Overview
                  statsAsync.when(
                    loading: () => Column(
                      children: List.generate(
                          2,
                          (_) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: ShimmerBox(height: 100, radius: 16),
                          )),
                    ),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (stats) => _StatsGrid(stats: stats)
                        .animate()
                        .fadeIn(delay: 50.ms),
                  ),
                  const SizedBox(height: 24),

                  // Section: Regional Analysis
                  SectionHeader(
                    title: l.regionalAnalysis,
                    icon: Icons.location_on_outlined,
                  ),
                  const SizedBox(height: 12),
                  regionalStatsAsync.when(
                    loading: () => Column(
                      children: List.generate(
                          2,
                          (_) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: ShimmerBox(height: 120, radius: 14),
                          )),
                    ),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (regionalStats) => Column(
                      children: [
                        for (final region in regionalStats)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: RegionalStatsCard(stats: region)
                                .animate()
                                .fadeIn(delay: 100.ms),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Section: Recent Activity
                  SectionHeader(
                    title: l.recentActivity,
                    icon: Icons.history_outlined,
                  ),
                  const SizedBox(height: 12),
                  recentActivityAsync.when(
                    loading: () => Column(
                      children: List.generate(
                          3,
                          (_) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: ShimmerBox(height: 80, radius: 14),
                          )),
                    ),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (activities) => _ActivityList(activities: activities)
                        .animate()
                        .fadeIn(delay: 150.ms),
                  ),
                  const SizedBox(height: 32),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats});
  final dynamic stats;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatsCard(
                label: l.totalReports,
                value: stats.totalReports.toString(),
                icon: Icons.report_outlined,
                color: AppColors.primary,
                trend: 12.5,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatsCard(
                label: l.newReports,
                value: stats.newReports.toString(),
                icon: Icons.new_releases_outlined,
                color: AppColors.info,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatsCard(
                label: l.resolvedReports,
                value: stats.resolvedReports.toString(),
                icon: Icons.check_circle_outline,
                color: AppColors.success,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatsCard(
                label: l.inProgressReports,
                value: stats.inProgressReports.toString(),
                icon: Icons.hourglass_bottom_outlined,
                color: AppColors.warning,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatsCard(
                label: l.totalUsers,
                value: stats.totalUsers.toString(),
                icon: Icons.people_outline_rounded,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatsCard(
                label: l.totalServices,
                value: stats.totalServices.toString(),
                icon: Icons.assignment_outlined,
                color: AppColors.accent,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActivityList extends StatelessWidget {
  const _ActivityList({required this.activities});
  final List<Map<String, dynamic>> activities;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Column(
      children: [
        for (final activity in activities)
          AppCard(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getActivityIcon(activity['type']),
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity['action'] ?? 'نشاط',
                        style: t.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatTime(activity['time'] as DateTime),
                        style: t.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        if (activities.isEmpty) ...[
          AppCard(
            child: Text(
              AppLocalizations.of(context).noActivity,
              style: t.bodyMedium,
            ),
          ),
        ],
      ],
    );
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'report':
        return Icons.report_outlined;
      case 'service':
        return Icons.assignment_outlined;
      case 'user':
        return Icons.person_add_outlined;
      default:
        return Icons.history_outlined;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inHours == 0) {
      return 'قبل ${diff.inMinutes} دقيقة';
    } else if (diff.inDays == 0) {
      return 'قبل ${diff.inHours} ساعة';
    } else {
      return 'قبل ${diff.inDays} يوم';
    }
  }
}
