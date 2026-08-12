import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/l10n_lookup.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/services_catalog.dart';
import '../../domain/entities/gov_service.dart';

class ServiceDetailScreen extends StatelessWidget {
  const ServiceDetailScreen({super.key, required this.serviceId});
  final String serviceId;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final service = ServicesCatalog.byId(serviceId);
    if (service == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l.errorGeneric)),
      );
    }
    final t = Theme.of(context).textTheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: service.color,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(tr(l, service.titleKey),
                  style: const TextStyle(fontWeight: FontWeight.w800)),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [service.color, service.color.withValues(alpha: 0.75)],
                  ),
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 28),
                    child: Icon(service.icon,
                        size: 76, color: Colors.white.withValues(alpha: 0.9)),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(l.quickServices,
                    style: t.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 14),
                for (int i = 0; i < service.actions.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ActionTile(
                      service: service,
                      action: service.actions[i],
                    ).animate().fadeIn(delay: (70 * i).ms).moveX(begin: 16, end: 0),
                  ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.service, required this.action});
  final GovService service;
  final ServiceAction action;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final isTrack = action.kind == ServiceActionKind.track;

    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: () {
          if (isTrack) {
            context.push('/services/${service.id}/track/${action.id}');
          } else {
            context.push('/services/${service.id}/form/${action.id}');
          }
        },
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: scheme.outline),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: (isTrack ? AppColors.info : service.color)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(action.icon,
                      color: isTrack ? AppColors.info : service.color),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(tr(l, action.titleKey),
                      style: t.bodyLarge?.copyWith(fontWeight: FontWeight.w700)),
                ),
                Icon(Icons.chevron_right_rounded, color: scheme.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
