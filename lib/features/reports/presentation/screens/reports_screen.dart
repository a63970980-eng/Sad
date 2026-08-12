import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/settings_controller.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/l10n_lookup.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/report.dart';
import '../providers/report_providers.dart';
import '../widgets/report_card.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final reportsAsync = ref.watch(userReportsProvider);
    final locale = ref.watch(settingsControllerProvider).locale.languageCode;

    return Scaffold(
      appBar: AppBar(title: Text(l.myReports)),
      body: reportsAsync.when(
        loading: () => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: 4,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, __) => const ShimmerBox(height: 110),
        ),
        error: (e, _) => EmptyState(
          icon: Icons.error_outline_rounded,
          title: l.errorGeneric,
          action: FilledButton(
            onPressed: () => ref.invalidate(userReportsProvider),
            child: Text(l.retry),
          ),
        ),
        data: (reports) {
          if (reports.isEmpty) {
            return EmptyState(
              icon: Icons.assignment_outlined,
              title: l.noReports,
              subtitle: l.noReportsDesc,
              action: FilledButton.icon(
                onPressed: () => context.push('/reports/new'),
                icon: const Icon(Icons.add),
                label: Text(l.newReport),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(userReportsProvider);
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              itemCount: reports.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final r = reports[i];
                return ReportCard(
                  report: r,
                  categoryLabel: tr(l, r.category.labelKey),
                  statusLabel: tr(l, r.status.labelKey),
                  dateLabel: Formatters.relative(r.createdAt, locale),
                  onTap: () => context.push('/reports/${r.id}'),
                ).animate().fadeIn(delay: (50 * i).ms).moveY(begin: 12, end: 0);
              },
            ),
          );
        },
      ),
    );
  }
}
