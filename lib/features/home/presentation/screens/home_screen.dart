import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/settings_controller.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/l10n_lookup.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../notifications/domain/app_notification.dart';
import '../../../notifications/presentation/providers/notification_providers.dart';
import '../../../reports/domain/entities/report.dart';
import '../../../reports/presentation/providers/report_providers.dart';
import '../../../services/data/services_catalog.dart';
import '../../data/announcements.dart';
import '../widgets/service_grid_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _greeting(AppLocalizations l) {
    final h = DateTime.now().hour;
    if (h < 12) return l.goodMorning;
    if (h < 17) return l.goodAfternoon;
    return l.goodEvening;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final user = ref.watch(currentUserProvider);
    final locale = ref.watch(settingsControllerProvider).locale.languageCode;
    final isAr = locale.startsWith('ar');
    final reportsAsync = ref.watch(userReportsProvider);
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref.invalidate(userReportsProvider);
          ref.invalidate(notificationsProvider);
          await Future.delayed(const Duration(milliseconds: 600));
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _Header(user: user, greeting: _greeting(l))),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Search Bar
                  _SearchBar().animate().fadeIn(delay: 50.ms).moveY(begin: 10, end: 0),
                  const SizedBox(height: 20),
                  
                  // Quick Actions
                  _QuickActionsBar().animate().fadeIn(delay: 100.ms).moveY(begin: 10, end: 0),
                  const SizedBox(height: 24),
                  
                  // Report Shortcut
                  _ReportShortcut()
                      .animate()
                      .fadeIn(delay: 150.ms)
                      .moveY(begin: 14, end: 0),
                  const SizedBox(height: 24),
                  
                  // Service Categories
                  SectionHeader(
                    title: l.quickServices,
                    icon: Icons.grid_view_rounded,
                    actionLabel: l.viewAll,
                    onAction: () => context.go(AppRoutes.services),
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.92,
                    children: [
                      for (final s in ServicesCatalog.all)
                        ServiceGridCard(
                          service: s,
                          title: tr(l, s.titleKey),
                          onTap: () => context.push('/services/${s.id}'),
                        ),
                    ],
                  ).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 24),
                  
                  // Statistics
                  _StatisticsBar(reportsAsync: reportsAsync, l: l)
                      .animate()
                      .fadeIn(delay: 250.ms),
                  const SizedBox(height: 24),
                  
                  // Recent Requests
                  SectionHeader(
                    title: l.recentRequests,
                    icon: Icons.receipt_long_rounded,
                    actionLabel: l.viewAll,
                    onAction: () => context.go(AppRoutes.reports),
                  ),
                  const SizedBox(height: 12),
                  reportsAsync.when(
                    loading: () => Column(
                      children: List.generate(
                          2,
                          (_) => const Padding(
                                padding: EdgeInsets.only(bottom: 12),
                                child: ShimmerBox(height: 86),
                              )),
                    ),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (reports) {
                      if (reports.isEmpty) {
                        return AppCard(
                          child: Row(
                            children: [
                              const Icon(Icons.inbox_outlined,
                                  color: AppColors.primary),
                              const SizedBox(width: 12),
                              Expanded(child: Text(l.noRecentRequests)),
                            ],
                          ),
                        );
                      }
                      return Column(
                        children: [
                          for (final r in reports.take(3))
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _RecentRequestTile(report: r, isAr: isAr),
                            ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Recent Notifications
                  SectionHeader(
                    title: l.recentNotifications,
                    icon: Icons.notifications_rounded,
                    actionLabel: l.viewAll,
                    onAction: () => context.push(AppRoutes.notifications),
                  ),
                  const SizedBox(height: 12),
                  notificationsAsync.when(
                    loading: () => Column(
                      children: List.generate(
                          2,
                          (_) => const Padding(
                                padding: EdgeInsets.only(bottom: 12),
                                child: ShimmerBox(height: 86),
                              )),
                    ),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (notifications) {
                      if (notifications.isEmpty) {
                        return AppCard(
                          child: Row(
                            children: [
                              const Icon(Icons.notifications_off_outlined,
                                  color: AppColors.primary),
                              const SizedBox(width: 12),
                              Expanded(child: Text(l.noNotifications)),
                            ],
                          ),
                        );
                      }
                      return Column(
                        children: [
                          for (final n in notifications.take(3))
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _NotificationTile(
                                notification: n,
                                isAr: isAr,
                                locale: locale,
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Announcements
                  SectionHeader(
                    title: l.announcements,
                    icon: Icons.campaign_rounded,
                  ),
                  const SizedBox(height: 12),
                  for (final a in Announcements.all)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _AnnouncementCard(a: a, isAr: isAr, locale: locale),
                    ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header({required this.user, required this.greeting});
  final dynamic user;
  final String greeting;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final name = user?.displayName ?? l.welcomeBack;

    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    child: Text(
                      user?.initials ?? '👤',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(greeting,
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 13)),
                        const SizedBox(height: 2),
                        Text(name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                  _IconBadge(
                    icon: Icons.notifications_none_rounded,
                    onTap: () => context.push(AppRoutes.notifications),
                    badge: true,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified_user_outlined,
                        color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        user?.nationalNumber != null
                            ? '${l.nationalNumber}: ${user.nationalNumber}'
                            : l.appTagline,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon, required this.onTap, this.badge = false});
  final IconData icon;
  final VoidCallback onTap;
  final bool badge;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          if (badge)
            Positioned(
              right: 10,
              top: 10,
              child: Container(
                width: 9,
                height: 9,
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ReportShortcut extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    return Material(
      borderRadius: BorderRadius.circular(20),
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push(AppRoutes.newReport),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Color(0xFFCBA14B), Color(0xFFB8862F)],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.3),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.add_alert_rounded,
                    color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.reportAProblem,
                        style: t.titleMedium?.copyWith(
                            color: Colors.white, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text(l.reportShortcutSubtitle,
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 12.5)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded,
                  color: Colors.white, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentRequestTile extends StatelessWidget {
  const _RecentRequestTile({required this.report, required this.isAr});
  final Report report;
  final bool isAr;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    return AppCard(
      onTap: () => context.push('/reports/${report.id}'),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: report.category.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(report.category.icon,
                color: report.category.color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(report.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: t.bodyLarge?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(report.id,
                    style: t.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          StatusPill(
            label: tr(l, report.status.labelKey),
            color: report.status.color,
            dense: true,
          ),
        ],
      ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  const _AnnouncementCard(
      {required this.a, required this.isAr, required this.locale});
  final Announcement a;
  final bool isAr;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: a.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(a.icon, color: a.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(a.title(isAr),
                          style:
                              t.bodyLarge?.copyWith(fontWeight: FontWeight.w700)),
                    ),
                    Text(Formatters.relative(a.date, locale),
                        style: t.bodySmall
                            ?.copyWith(color: scheme.onSurfaceVariant)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(a.body(isAr),
                    style:
                        t.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatefulWidget {
  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        hintText: l.searchServices,
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: _controller.text.isNotEmpty
            ? GestureDetector(
                onTap: () => setState(() => _controller.clear()),
                child: const Icon(Icons.close_rounded),
              )
            : null,
        filled: true,
        fillColor: Theme.of(context).cardColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
      ),
      onChanged: (value) => setState(() {}),
      onSubmitted: (value) {
        if (value.isNotEmpty) {
          // TODO: Implement search functionality
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l.searchNotImplemented)),
          );
        }
      },
    );
  }
}

class _QuickActionsBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _QuickActionButton(
            icon: Icons.report_outlined,
            label: l.report,
            color: AppColors.danger,
            onTap: () => context.push(AppRoutes.newReport),
          ),
          const SizedBox(width: 10),
          _QuickActionButton(
            icon: Icons.assignment_outlined,
            label: l.navServices,
            color: AppColors.primary,
            onTap: () => context.go(AppRoutes.services),
          ),
          const SizedBox(width: 10),
          _QuickActionButton(
            icon: Icons.map_outlined,
            label: l.navMap,
            color: AppColors.info,
            onTap: () => context.go(AppRoutes.map),
          ),
          const SizedBox(width: 10),
          _QuickActionButton(
            icon: Icons.person_outline_rounded,
            label: l.navProfile,
            color: AppColors.accent,
            onTap: () => context.go(AppRoutes.profile),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _StatisticsBar extends StatelessWidget {
  const _StatisticsBar({
    required this.reportsAsync,
    required this.l,
  });

  final AsyncValue<List<Report>> reportsAsync;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return reportsAsync.when(
      loading: () => _StatBarPlaceholder(),
      error: (_, __) => const SizedBox.shrink(),
      data: (reports) {
        final total = reports.length;
        final pending = reports.where((r) => r.status == ReportStatus.submitted).length;
        final resolved = reports.where((r) => r.status == ReportStatus.resolved).length;

        return Row(
          children: [
            Expanded(
              child: _StatCard(
                title: l.totalReports,
                value: total.toString(),
                icon: Icons.receipt_outlined,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                title: l.pending,
                value: pending.toString(),
                icon: Icons.schedule_outlined,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                title: l.resolved,
                value: resolved.toString(),
                icon: Icons.check_circle_outline,
                color: AppColors.success,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StatBarPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: ShimmerBox(height: 80, radius: 14)),
        const SizedBox(width: 10),
        Expanded(child: ShimmerBox(height: 80, radius: 14)),
        const SizedBox(width: 10),
        Expanded(child: ShimmerBox(height: 80, radius: 14)),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: t.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: t.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.isAr,
    required this.locale,
  });

  final AppNotification notification;
  final bool isAr;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return AppCard(
      onTap: () => context.push(AppRoutes.notifications),
      padding: const EdgeInsets.all(12),
      borderColor: notification.read
          ? scheme.outline
          : AppColors.info.withValues(alpha: 0.3),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: notification.type.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              notification.type.icon,
              color: notification.type.color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification.title(isAr),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: t.bodyMedium?.copyWith(
                          fontWeight:
                              notification.read ? FontWeight.w500 : FontWeight.w700,
                        ),
                      ),
                    ),
                    if (!notification.read)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.info,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  notification.body(isAr),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
