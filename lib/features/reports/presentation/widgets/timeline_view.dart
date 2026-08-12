import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/l10n_lookup.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/report.dart';

class TimelineView extends StatelessWidget {
  const TimelineView({super.key, required this.entries, required this.locale});
  final List<TimelineEntry> entries;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        for (int i = 0; i < entries.length; i++)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: entries[i].status.color,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color:
                                entries[i].status.color.withValues(alpha: 0.25),
                            width: 4),
                      ),
                    ),
                    if (i != entries.length - 1)
                      Expanded(
                        child: Container(
                            width: 2, color: scheme.outline),
                      ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tr(l, entries[i].status.labelKey),
                            style: t.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text(Formatters.dateTime(entries[i].date, locale),
                            style: t.bodySmall
                                ?.copyWith(color: scheme.onSurfaceVariant)),
                        if (entries[i].note != null) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.primarySoft,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(entries[i].note!,
                                style: t.bodySmall
                                    ?.copyWith(color: AppColors.primaryDark)),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
