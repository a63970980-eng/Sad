import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/map_place.dart';

/// Vendor-neutral map surface used by the citizen map screen.
///
/// The implementation uses OpenStreetMap tiles through flutter_map, keeping
/// the app independent from Google Maps SDK billing and API-key configuration.
/// A dedicated tile provider can later be introduced for government-scale
/// production traffic without changing the domain layer.
class GoogleMapView extends StatelessWidget {
  const GoogleMapView({
    super.key,
    required this.places,
    required this.isAr,
    required this.onTapPlace,
  });

  final List<MapPlace> places;
  final bool isAr;
  final ValueChanged<MapPlace> onTapPlace;

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: const LatLng(AppConstants.adenLat, AppConstants.adenLng),
        initialZoom: AppConstants.defaultZoom,
        minZoom: 10,
        maxZoom: 18,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: const ['a', 'b', 'c'],
          userAgentPackageName: 'ye.gov.aden.aden_digital',
        ),
        MarkerLayer(
          markers: [
            for (final place in places)
              Marker(
                point: LatLng(place.lat, place.lng),
                width: 54,
                height: 62,
                child: GestureDetector(
                  onTap: () => onTapPlace(place),
                  child: _PlaceMarker(place: place),
                ),
              ),
          ],
        ),
        const RichAttributionWidget(
          attributions: [
            TextSourceAttribution('OpenStreetMap contributors'),
          ],
        ),
      ],
    );
  }
}

class _PlaceMarker extends StatelessWidget {
  const _PlaceMarker({required this.place});

  final MapPlace place;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: place.type.color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Icon(place.type.icon, color: Colors.white, size: 22),
        ),
        CustomPaint(
          size: const Size(14, 8),
          painter: _PinTailPainter(place.type.color),
        ),
      ],
    );
  }
}

class _PinTailPainter extends CustomPainter {
  const _PinTailPainter(this.color);
  final Color color;

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    final paint = ui.Paint()..color = color;
    final path = ui.Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
