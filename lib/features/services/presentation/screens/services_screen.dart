import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/l10n_lookup.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/services_catalog.dart';
import '../../domain/entities/gov_service.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.servicesTitle)),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        itemCount: ServicesCatalog.all.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, i) {
          final s = ServicesCatalog.all[i];
          return _ServiceListCard(service: s)
              .animate()
              .fadeIn(delay: (60 * i).ms)
              .moveX(begin: 16, end: 0);
        },
      ),
    );
  }
}

class _ServiceListCard extends StatelessWidget {
  const _ServiceListCard({required this.service});
  final GovService service;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () => context.push('/services/${service.id}'),
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: scheme.outline),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: service.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(service.icon, color: service.color, size: 30),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tr(l, service.titleKey),
                          style: t.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Text(
                        service.actions.map((a) => tr(l, a.titleKey)).join(' • '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: t.bodySmall
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: scheme.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
