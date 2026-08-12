// ============================================================================
//  REAL Google Maps implementation (opt-in).
//
//  The Map screen uses [CanvasMap] by default so it renders without an API key.
//  To use the real Google map instead:
//
//   1. Add your Maps API keys:
//        - android/app/src/main/AndroidManifest.xml  (com.google.android.geo.API_KEY)
//        - ios/Runner/AppDelegate.swift               (GMSServices.provideAPIKey)
//   2. In map_screen.dart, replace `CanvasMap(...)` with `GoogleMapView(...)`.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/map_place.dart';

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
    final markers = <Marker>{
      for (final p in places)
        Marker(
          markerId: MarkerId(p.id),
          position: LatLng(p.lat, p.lng),
          icon: BitmapDescriptor.defaultMarkerWithHue(_hue(p.type)),
          infoWindow: InfoWindow(title: p.name(isAr)),
          onTap: () => onTapPlace(p),
        ),
    };

    return GoogleMap(
      initialCameraPosition: const CameraPosition(
        target: LatLng(AppConstants.adenLat, AppConstants.adenLng),
        zoom: AppConstants.defaultZoom,
      ),
      markers: markers,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
    );
  }

  double _hue(PlaceType type) => switch (type) {
        PlaceType.report => BitmapDescriptor.hueRed,
        PlaceType.govOffice => BitmapDescriptor.hueGreen,
        PlaceType.electricity => BitmapDescriptor.hueOrange,
        PlaceType.water => BitmapDescriptor.hueAzure,
        PlaceType.police => BitmapDescriptor.hueBlue,
        PlaceType.hospital => BitmapDescriptor.hueCyan,
      };
}
