import 'package:flutter/material.dart';

import '../../../services/domain/entities/gov_service.dart';

class ServiceGridCard extends StatelessWidget {
  const ServiceGridCard({
    super.key,
    required this.service,
    required this.title,
    required this.onTap,
  });

  final GovService service;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: scheme.outline),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: service.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(service.icon, color: service.color, size: 28),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: t.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
