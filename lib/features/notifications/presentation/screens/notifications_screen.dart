import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/settings_controller.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/app_notification.dart';
import '../providers/notification_providers.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  NotificationType? _selectedFilter;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final items = ref.watch(notificationsProvider);
    final locale = ref.watch(settingsControllerProvider).locale.languageCode;
    final isAr = locale.startsWith('ar');

    final filteredItems = _selectedFilter == null
        ? items
        : items.where((n) => n.type == _selectedFilter).toList();

    final unreadCount = items.where((n) => !n.read).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.notificationsTitle),
        elevation: 0,
        actions: [
          if (unreadCount > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.danger,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    unreadCount.toString(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          if (items.isNotEmpty)
            TextButton(
              onPressed: () =>
                  ref.read(notificationsProvider.notifier).markAllRead(),
              child: Text(l.markAllRead),
            ),
        ],
      ),
      body: items.isEmpty
          ? EmptyState(
              icon: Icons.notifications_off_outlined,
              title: l.noNotifications)
          : CustomScrollView(
              slivers: [
                // Filter Chips
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  sliver: SliverToBoxAdapter(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _FilterChip(
                            label: l.all,
                            selected: _selectedFilter == null,
                            onTap: () =>
                                setState(() => _selectedFilter = null),
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: l.reports,
                            selected: _selectedFilter == NotificationType.report,
                            color: NotificationType.report.color,
                            onTap: () => setState(
                              () => _selectedFilter = NotificationType.report,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: l.services,
                            selected: _selectedFilter == NotificationType.service,
                            color: NotificationType.service.color,
                            onTap: () => setState(
                              () => _selectedFilter = NotificationType.service,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: l.announcements,
                            selected: _selectedFilter == NotificationType.announcement,
                            color: NotificationType.announcement.color,
                            onTap: () => setState(
                              () => _selectedFilter = NotificationType.announcement,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Notifications List
                if (filteredItems.isEmpty)
                  SliverFillRemaining(
                    child: EmptyState(
                      icon: Icons.notifications_off_outlined,
                      title: l.noNotifications,
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) {
                          final n = filteredItems[i];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _NotificationTile(
                              notification: n,
                              isAr: isAr,
                              locale: locale,
                              onTap: () => ref
                                  .read(notificationsProvider.notifier)
                                  .markRead(n.id),
                            )
                                .animate()
                                .fadeIn(delay: (50 * i).ms)
                                .moveX(begin: 16, end: 0),
                          );
                        },
                        childCount: filteredItems.length,
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? (color ?? AppColors.primary)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? (color ?? AppColors.primary)
                : Theme.of(context).colorScheme.outline,
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: selected ? Colors.white : null,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.isAr,
    required this.locale,
    required this.onTap,
  });

  final AppNotification notification;
  final bool isAr;
  final String locale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AppCard(
        padding: const EdgeInsets.all(14),
        color: notification.read ? null : AppColors.primarySoft.withValues(alpha: 0.5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: notification.type.color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(notification.type.icon, color: notification.type.color),
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
                          style: t.bodyLarge?.copyWith(
                            fontWeight: notification.read
                                ? FontWeight.w500
                                : FontWeight.w700,
                          ),
                        ),
                      ),
                      if (!notification.read)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.body(isAr),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: t.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        Formatters.relative(notification.date, locale),
                        style: t.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: notification.type.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _getTypeLabel(context, notification.type),
                          style: t.labelSmall?.copyWith(
                            color: notification.type.color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTypeLabel(BuildContext context, NotificationType type) {
    final l = AppLocalizations.of(context);
    switch (type) {
      case NotificationType.report:
        return l.reports;
      case NotificationType.service:
        return l.services;
      case NotificationType.announcement:
        return l.announcements;
      case NotificationType.system:
        return l.system;
    }
  }
}
