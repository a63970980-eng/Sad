import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/location_service.dart';

/// Full-screen-ish report location picker using the vendor-neutral map stack.
/// GPS and reverse geocoding remain provided by LocationService.
class ReportLocationPicker extends StatefulWidget {
  const ReportLocationPicker({
    super.key,
    required this.initial,
    required this.locationService,
  });

  final LatLng initial;
  final LocationService locationService;

  @override
  State<ReportLocationPicker> createState() => _ReportLocationPickerState();
}

class _ReportLocationPickerState extends State<ReportLocationPicker> {
  final MapController _mapController = MapController();
  LatLng? _selected;
  bool _resolving = false;
  bool _locating = false;

  Future<void> _select(LatLng point) async {
    if (_resolving) return;
    setState(() {
      _selected = point;
      _resolving = true;
    });
    try {
      final location = await widget.locationService.fromCoordinates(
        point.latitude,
        point.longitude,
      );
      if (!mounted) return;
      Navigator.of(context).pop(location);
    } catch (_) {
      if (mounted) setState(() => _resolving = false);
    }
  }

  Future<void> _useCurrentLocation() async {
    if (_locating || _resolving) return;
    setState(() => _locating = true);
    try {
      final location = await widget.locationService.getCurrent();
      final point = LatLng(location.latitude, location.longitude);
      if (!mounted) return;
      setState(() => _selected = point);
      _mapController.move(point, 17);
    } on LocationServiceException catch (e) {
      if (mounted) _showMessage(e.message);
    } catch (_) {
      if (mounted) _showMessage('تعذر تحديد موقعك الحالي. حاول مرة أخرى.');
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selected;
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * .82,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'تحديد موقع البلاغ',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'اضغط على الخريطة لتحديد المكان بدقة، أو استخدم موقعك الحالي.',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'إغلاق',
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: widget.initial,
                    initialZoom: 15,
                    minZoom: 10,
                    maxZoom: 19,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                    ),
                    onTap: (_, point) => _select(point),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c'],
                      userAgentPackageName: 'ye.gov.aden.aden_digital',
                    ),
                    if (selected != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: selected,
                            width: 58,
                            height: 66,
                            child: const _SelectedLocationMarker(),
                          ),
                        ],
                      ),
                    const RichAttributionWidget(
                      attributions: [
                        TextSourceAttribution('OpenStreetMap contributors'),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  left: 16,
                  bottom: 16,
                  child: Material(
                    color: Theme.of(context).cardColor,
                    elevation: 4,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: _locating ? null : _useCurrentLocation,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 11,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_locating)
                              const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            else
                              const Icon(
                                Icons.my_location_rounded,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            const SizedBox(width: 8),
                            Text(
                              'موقعي الحالي',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (_resolving)
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: Material(
                      borderRadius: BorderRadius.circular(14),
                      elevation: 4,
                      child: const Padding(
                        padding: EdgeInsets.all(14),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'جارٍ تحديد العنوان…',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                      ),
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

class _SelectedLocationMarker extends StatelessWidget {
  const _SelectedLocationMarker();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            border: Border.fromBorderSide(
              BorderSide(color: Colors.white, width: 3),
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: SizedBox(
            width: 46,
            height: 46,
            child: Icon(Icons.location_on_rounded, color: Colors.white, size: 27),
          ),
        ),
      ],
    );
  }
}
