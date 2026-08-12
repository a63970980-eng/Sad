import 'package:flutter/material.dart';

import '../domain/entities/gov_service.dart';

/// Static catalog of all government services & their actions.
/// Organized by category for better navigation and user experience.
class ServicesCatalog {
  ServicesCatalog._();

  // Personal Documents & Civil Affairs
  static const List<GovService> personalDocuments = [
    GovService(
      id: 'national_id',
      titleKey: 'svcNationalId',
      icon: Icons.badge_outlined,
      color: Color(0xFF0E7C52),
      actions: [
        ServiceAction(id: 'apply_id', titleKey: 'actApplyId', icon: Icons.add_card_outlined),
        ServiceAction(id: 'renew_id', titleKey: 'actRenewId', icon: Icons.autorenew_rounded),
        ServiceAction(
            id: 'track_id',
            titleKey: 'actTrackId',
            icon: Icons.travel_explore_outlined,
            kind: ServiceActionKind.track),
      ],
    ),
    GovService(
      id: 'passport',
      titleKey: 'svcPassport',
      icon: Icons.menu_book_outlined,
      color: Color(0xFF2563EB),
      actions: [
        ServiceAction(id: 'new_passport', titleKey: 'actNewPassport', icon: Icons.flight_takeoff_outlined),
        ServiceAction(id: 'renew_passport', titleKey: 'actRenewPassport', icon: Icons.autorenew_rounded),
        ServiceAction(
            id: 'track_passport',
            titleKey: 'actTrackPassport',
            icon: Icons.travel_explore_outlined,
            kind: ServiceActionKind.track),
      ],
    ),
  ];

  // Transportation & Vehicles
  static const List<GovService> transportation = [
    GovService(
      id: 'driving_license',
      titleKey: 'svcDrivingLicense',
      icon: Icons.directions_car_filled_outlined,
      color: Color(0xFFCBA14B),
      actions: [
        ServiceAction(id: 'new_license', titleKey: 'actNewLicense', icon: Icons.add_road_outlined),
        ServiceAction(id: 'renew_license', titleKey: 'actRenewLicense', icon: Icons.autorenew_rounded),
        ServiceAction(
            id: 'license_status',
            titleKey: 'actLicenseStatus',
            icon: Icons.travel_explore_outlined,
            kind: ServiceActionKind.track),
      ],
    ),
    GovService(
      id: 'vehicle',
      titleKey: 'svcVehicle',
      icon: Icons.local_shipping_outlined,
      color: Color(0xFF7C3AED),
      actions: [
        ServiceAction(id: 'vehicle_reg', titleKey: 'actVehicleReg', icon: Icons.app_registration_outlined),
        ServiceAction(id: 'ownership_transfer', titleKey: 'actOwnershipTransfer', icon: Icons.swap_horiz_rounded),
        ServiceAction(
            id: 'vehicle_info',
            titleKey: 'actVehicleInfo',
            icon: Icons.info_outline_rounded,
            kind: ServiceActionKind.track),
      ],
    ),
  ];

  // Municipal & Local Services
  static const List<GovService> municipal = [
    GovService(
      id: 'municipality',
      titleKey: 'svcMunicipality',
      icon: Icons.location_city_outlined,
      color: Color(0xFFD97706),
      actions: [
        ServiceAction(id: 'building_permit', titleKey: 'actBuildingPermit', icon: Icons.foundation_outlined),
        ServiceAction(id: 'commercial_permit', titleKey: 'actCommercialPermit', icon: Icons.storefront_outlined),
        ServiceAction(id: 'property_services', titleKey: 'actPropertyServices', icon: Icons.home_work_outlined),
      ],
    ),
  ];

  // Utilities & Essential Services
  static const List<GovService> utilities = [
    GovService(
      id: 'utilities',
      titleKey: 'svcUtilities',
      icon: Icons.bolt_outlined,
      color: Color(0xFF0891B2),
      actions: [
        ServiceAction(id: 'electricity', titleKey: 'actElectricity', icon: Icons.electrical_services_outlined),
        ServiceAction(id: 'water', titleKey: 'actWater', icon: Icons.water_drop_outlined),
        ServiceAction(id: 'internet', titleKey: 'actInternet', icon: Icons.wifi_outlined),
      ],
    ),
  ];

  // All services combined
  static List<GovService> get all => [
    ...personalDocuments,
    ...transportation,
    ...municipal,
    ...utilities,
  ];

  // Get services by category
  static Map<String, List<GovService>> get byCategory => {
    'personal': personalDocuments,
    'transportation': transportation,
    'municipal': municipal,
    'utilities': utilities,
  };

  static GovService? byId(String id) {
    for (final s in all) {
      if (s.id == id) return s;
    }
    return null;
  }
}
