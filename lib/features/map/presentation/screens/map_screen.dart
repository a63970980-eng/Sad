import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/settings_controller.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/map_place.dart';
import '../widgets/canvas_map.dart';

final mapFilterProvider =
    StateProvider<Set<PlaceType>>((ref) => PlaceType.values.toSet());

class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  String _typeLabel(AppLocalizations l, PlaceType type) => switch (type) {
        PlaceType.report => l.filterReports,
        PlaceType.govOffice => l.filterGovOffices,
        PlaceType.electricity => l.filterElectricity,
        PlaceType.water => l.filterWater,
        PlaceType.police => l.filterPolice,
        PlaceType.hospital => l.filterHospitals,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final isAr = ref
        .watch(settingsControllerProvider)
        .locale
        .languageCode
        .startsWith('ar');
    final filter = ref.watch(mapFilterProvider);
    final visible = MapData.places.where((p) => filter.contains(p.type)).toList();

    return Scaffold(
      appBar: AppBar(title: Text(l.mapTitle)),
      body: Column(
        children: [
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                for (final type in PlaceType.values)
                  Padding(
                    padding: const EdgeInsets.only(left: 8, right: 8),
                    child: _FilterChip(
                      label: _typeLabel(l, type),
                      color: type.color,
                      icon: type.icon,
                      selected: filter.contains(type),
                      onTap: () {
                        final next = {...filter};
                        if (next.contains(type)) {
                          next.remove(type);
                        } else {
                          next.add(type);
                        }
                        ref.read(mapFilterProvider.notifier).state = next;
                      },
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                CanvasMap(
                  places: visible,
                  isAr: isAr,
                  onTapPlace: (p) => _showPlaceSheet(context, p, isAr, l),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: _Legend(label: l.mapLegend),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPlaceSheet(
      BuildContext context, MapPlace place, bool isAr, AppLocalizations l) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: place.type.color.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(place.type.icon, color: place.type.color),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(place.name(isAr),
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Text('${place.lat.toStringAsFixed(4)}, ${place.lng.toStringAsFixed(4)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    label: Text(l.close),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.directions_rounded),
                    label: Text(l.details),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.color,
    required this.icon,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final Color color;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.14)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: selected ? color : Theme.of(context).colorScheme.outline,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 18,
                color: selected
                    ? color
                    : Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? color
                      : Theme.of(context).colorScheme.onSurface,
                )),
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          for (final type in PlaceType.values)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                        color: type.color, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    switch (type) {
                      PlaceType.report => l.filterReports,
                      PlaceType.govOffice => l.filterGovOffices,
                      PlaceType.electricity => l.filterElectricity,
                      PlaceType.water => l.filterWater,
                      PlaceType.police => l.filterPolice,
                      PlaceType.hospital => l.filterHospitals,
                    },
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
