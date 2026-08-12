import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class CapturedLocation {
  const CapturedLocation({
    required this.latitude,
    required this.longitude,
    this.address,
  });
  final double latitude;
  final double longitude;
  final String? address;
}

class LocationService {
  /// Requests permission and returns the current position with a best-effort
  /// reverse-geocoded address.
  Future<CapturedLocation> getCurrent() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      throw Exception('Location services are disabled.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception('Location permission denied.');
    }

    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    String? address;
    try {
      final marks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
      if (marks.isNotEmpty) {
        final m = marks.first;
        address = [m.subLocality, m.locality, m.administrativeArea]
            .where((e) => e != null && e.isNotEmpty)
            .join('، ');
      }
    } catch (_) {
      // Reverse geocoding may be unavailable; ignore.
    }

    return CapturedLocation(
      latitude: pos.latitude,
      longitude: pos.longitude,
      address: address,
    );
  }
}

final locationServiceProvider = Provider<LocationService>((ref) => LocationService());
