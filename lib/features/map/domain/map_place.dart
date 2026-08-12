import 'package:flutter/material.dart';

enum PlaceType {
  report,
  govOffice,
  electricity,
  water,
  police,
  hospital,
}

extension PlaceTypeX on PlaceType {
  String get labelKey => switch (this) {
        PlaceType.report => 'filterReports',
        PlaceType.govOffice => 'filterGovOffices',
        PlaceType.electricity => 'filterElectricity',
        PlaceType.water => 'filterWater',
        PlaceType.police => 'filterPolice',
        PlaceType.hospital => 'filterHospitals',
      };

  IconData get icon => switch (this) {
        PlaceType.report => Icons.report_rounded,
        PlaceType.govOffice => Icons.account_balance_rounded,
        PlaceType.electricity => Icons.bolt_rounded,
        PlaceType.water => Icons.water_drop_rounded,
        PlaceType.police => Icons.local_police_rounded,
        PlaceType.hospital => Icons.local_hospital_rounded,
      };

  Color get color => switch (this) {
        PlaceType.report => const Color(0xFFDC2626),
        PlaceType.govOffice => const Color(0xFF0E7C52),
        PlaceType.electricity => const Color(0xFFF59E0B),
        PlaceType.water => const Color(0xFF2563EB),
        PlaceType.police => const Color(0xFF1E3A8A),
        PlaceType.hospital => const Color(0xFF059669),
      };
}

class MapPlace {
  const MapPlace({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.type,
    required this.lat,
    required this.lng,
  });

  final String id;
  final String nameAr;
  final String nameEn;
  final PlaceType type;
  final double lat;
  final double lng;

  String name(bool isAr) => isAr ? nameAr : nameEn;
}

/// Sample places around Aden.
class MapData {
  MapData._();
  static const List<MapPlace> places = [
    MapPlace(id: 'g1', nameAr: 'مبنى محافظة عدن', nameEn: 'Aden Governorate', type: PlaceType.govOffice, lat: 12.7903, lng: 45.0270),
    MapPlace(id: 'g2', nameAr: 'مكتب الأحوال المدنية - كريتر', nameEn: 'Civil Affairs - Crater', type: PlaceType.govOffice, lat: 12.7782, lng: 45.0345),
    MapPlace(id: 'e1', nameAr: 'مؤسسة كهرباء عدن', nameEn: 'Aden Electricity Corp.', type: PlaceType.electricity, lat: 12.8005, lng: 45.0210),
    MapPlace(id: 'e2', nameAr: 'محطة كهرباء المنصورة', nameEn: 'Al-Mansoura Power Station', type: PlaceType.electricity, lat: 12.8650, lng: 45.0030),
    MapPlace(id: 'w1', nameAr: 'مؤسسة المياه - المعلا', nameEn: 'Water Corp. - Al-Mualla', type: PlaceType.water, lat: 12.7920, lng: 45.0150),
    MapPlace(id: 'p1', nameAr: 'مركز شرطة كريتر', nameEn: 'Crater Police Station', type: PlaceType.police, lat: 12.7760, lng: 45.0380),
    MapPlace(id: 'p2', nameAr: 'مركز شرطة خور مكسر', nameEn: 'Khormaksar Police', type: PlaceType.police, lat: 12.8270, lng: 45.0240),
    MapPlace(id: 'h1', nameAr: 'مستشفى الجمهورية', nameEn: 'Al-Jumhuriya Hospital', type: PlaceType.hospital, lat: 12.7799, lng: 45.0301),
    MapPlace(id: 'h2', nameAr: 'مستشفى الصداقة', nameEn: 'Al-Sadaqa Hospital', type: PlaceType.hospital, lat: 12.8540, lng: 44.9990),
    MapPlace(id: 'r1', nameAr: 'بلاغ: انقطاع كهرباء', nameEn: 'Report: Power outage', type: PlaceType.report, lat: 12.7905, lng: 45.0335),
    MapPlace(id: 'r2', nameAr: 'بلاغ: تسرب مياه', nameEn: 'Report: Water leak', type: PlaceType.report, lat: 12.7782, lng: 45.0301),
  ];
}
