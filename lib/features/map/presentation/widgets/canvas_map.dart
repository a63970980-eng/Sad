import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/map_place.dart';

/// A lightweight, dependency-free interactive map.
///
/// It draws a stylized street grid and positions place markers by projecting
/// their lat/lng onto the canvas. Supports pan & pinch-zoom via
/// [InteractiveViewer]. This guarantees the Map screen renders beautifully
/// even before a Google Maps API key is configured.
///
/// To switch to the real Google map, see `google_map_view.dart`.
class CanvasMap extends StatelessWidget {
  const CanvasMap({
    super.key,
    required this.places,
    required this.isAr,
    required this.onTapPlace,
  });

  final List<MapPlace> places;
  final bool isAr;
  final ValueChanged<MapPlace> onTapPlace;

  // Bounding box around Aden used for projection.
  static const double _minLat = 12.75;
  static const double _maxLat = 12.88;
  static const double _minLng = 44.98;
  static const double _maxLng = 45.05;

  Offset _project(MapPlace p, Size size) {
    final x = (p.lng - _minLng) / (_maxLng - _minLng) * size.width;
    final y = (1 - (p.lat - _minLat) / (_maxLat - _minLat)) * size.height;
    return Offset(x, y);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        return InteractiveViewer(
          minScale: 1,
          maxScale: 4,
          child: Stack(
            children: [
              // Map background + grid
              Positioned.fill(
                child: CustomPaint(painter: _MapBackgroundPainter(isDark)),
              ),
              // Markers
              for (final p in places)
                Builder(builder: (context) {
                  final pos = _project(p, size);
                  return Positioned(
                    left: pos.dx - 22,
                    top: pos.dy - 44,
                    child: _Marker(
                      place: p,
                      isAr: isAr,
                      onTap: () => onTapPlace(p),
                    ),
                  );
                }),
              // "You are here" pin at Aden center
              Builder(builder: (context) {
                final center = _project(
                  const MapPlace(
                      id: 'me',
                      nameAr: '',
                      nameEn: '',
                      type: PlaceType.govOffice,
                      lat: AppConstants.adenLat,
                      lng: AppConstants.adenLng),
                  size,
                );
                return Positioned(
                  left: center.dx - 11,
                  top: center.dy - 11,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: AppColors.info,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                            color: AppColors.info.withValues(alpha: 0.5),
                            blurRadius: 12,
                            spreadRadius: 2),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class _Marker extends StatelessWidget {
  const _Marker({required this.place, required this.isAr, required this.onTap});
  final MapPlace place;
  final bool isAr;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: place.type.color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 4)),
              ],
            ),
            child: Icon(place.type.icon, color: Colors.white, size: 22),
          ),
          CustomPaint(
            size: const Size(14, 8),
            painter: _PinTailPainter(place.type.color),
          ),
        ],
      ),
    );
  }
}

class _PinTailPainter extends CustomPainter {
  _PinTailPainter(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MapBackgroundPainter extends CustomPainter {
  _MapBackgroundPainter(this.isDark);
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()
      ..color = isDark ? const Color(0xFF16201C) : const Color(0xFFEAF0ED);
    canvas.drawRect(Offset.zero & size, bg);

    // Soft "parks"
    final park = Paint()
      ..color = (isDark ? AppColors.primaryDark : AppColors.primarySoft)
          .withValues(alpha: 0.6);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(size.width * 0.05, size.height * 0.55,
                size.width * 0.28, size.height * 0.3),
            const Radius.circular(18)),
        park);
    canvas.drawCircle(Offset(size.width * 0.78, size.height * 0.22),
        size.width * 0.12, park);

    // "Sea" on one edge
    final sea = Paint()
      ..color = (isDark ? const Color(0xFF12303A) : const Color(0xFFCFE6EE));
    canvas.drawRect(
        Rect.fromLTWH(0, size.height * 0.86, size.width, size.height * 0.14), sea);

    // Street grid
    final road = Paint()
      ..color = (isDark ? const Color(0xFF2A3631) : Colors.white)
      ..strokeWidth = 6;
    for (double x = size.width * 0.12;
        x < size.width;
        x += size.width * 0.18) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height * 0.86), road);
    }
    for (double y = size.height * 0.12;
        y < size.height * 0.86;
        y += size.height * 0.16) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), road);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
