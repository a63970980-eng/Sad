import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationServiceException implements Exception {
  const LocationServiceException(this.message);
  final String message;

  @override
  String toString() => message;
}

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
  Future<CapturedLocation> getCurrent() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationServiceException('خدمة الموقع في الهاتف غير مفعّلة. فعّل الموقع ثم حاول مرة أخرى.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw const LocationServiceException('تم رفض صلاحية الوصول إلى الموقع. اسمح للتطبيق باستخدام موقعك لإرسال البلاغ بدقة.');
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationServiceException('صلاحية الموقع مرفوضة نهائيًا. افتح إعدادات التطبيق واسمح بالوصول إلى الموقع.');
    }

    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 15),
    );

    return fromCoordinates(pos.latitude, pos.longitude);
  }

  Future<CapturedLocation> fromCoordinates(double latitude, double longitude) async {
    String? address;
    try {
      final marks = await placemarkFromCoordinates(latitude, longitude);
      if (marks.isNotEmpty) {
        final m = marks.first;
        address = [m.subLocality, m.locality, m.administrativeArea]
            .where((e) => e != null && e.trim().isNotEmpty)
            .join('، ');
      }
    } catch (_) {
      // Coordinates remain valid even when reverse geocoding is unavailable.
    }

    return CapturedLocation(
      latitude: latitude,
      longitude: longitude,
      address: address,
    );
  }
}

final locationServiceProvider = Provider<LocationService>((ref) => LocationService());
