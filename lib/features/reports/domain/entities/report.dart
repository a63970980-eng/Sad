import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum ReportCategory {
  powerOutage,
  waterLeak,
  roadDamage,
  garbage,
  corruption,
  streetLight,
  sewage,
  publicSafety,
}

extension ReportCategoryX on ReportCategory {
  String get id => name;

  String get labelKey => switch (this) {
        ReportCategory.powerOutage => 'catPowerOutage',
        ReportCategory.waterLeak => 'catWaterLeak',
        ReportCategory.roadDamage => 'catRoadDamage',
        ReportCategory.garbage => 'catGarbage',
        ReportCategory.corruption => 'catCorruption',
        ReportCategory.streetLight => 'catStreetLight',
        ReportCategory.sewage => 'catSewage',
        ReportCategory.publicSafety => 'catPublicSafety',
      };

  IconData get icon => switch (this) {
        ReportCategory.powerOutage => Icons.power_off_outlined,
        ReportCategory.waterLeak => Icons.water_damage_outlined,
        ReportCategory.roadDamage => Icons.dangerous_outlined,
        ReportCategory.garbage => Icons.delete_outline_rounded,
        ReportCategory.corruption => Icons.gavel_outlined,
        ReportCategory.streetLight => Icons.light_outlined,
        ReportCategory.sewage => Icons.plumbing_outlined,
        ReportCategory.publicSafety => Icons.health_and_safety_outlined,
      };

  Color get color => switch (this) {
        ReportCategory.powerOutage => const Color(0xFFF59E0B),
        ReportCategory.waterLeak => const Color(0xFF2563EB),
        ReportCategory.roadDamage => const Color(0xFF92400E),
        ReportCategory.garbage => const Color(0xFF16A34A),
        ReportCategory.corruption => const Color(0xFFDC2626),
        ReportCategory.streetLight => const Color(0xFFCA8A04),
        ReportCategory.sewage => const Color(0xFF7C3AED),
        ReportCategory.publicSafety => const Color(0xFF0891B2),
      };

  static ReportCategory fromId(String id) =>
      ReportCategory.values.firstWhere((e) => e.name == id,
          orElse: () => ReportCategory.publicSafety);
}

enum ReportStatus { submitted, reviewing, inProgress, resolved, rejected }

extension ReportStatusX on ReportStatus {
  String get id => name;

  String get labelKey => switch (this) {
        ReportStatus.submitted => 'statusSubmitted',
        ReportStatus.reviewing => 'statusReviewing',
        ReportStatus.inProgress => 'statusInProgress',
        ReportStatus.resolved => 'statusResolved',
        ReportStatus.rejected => 'statusRejected',
      };

  Color get color => switch (this) {
        ReportStatus.submitted => const Color(0xFF6366F1),
        ReportStatus.reviewing => const Color(0xFFF59E0B),
        ReportStatus.inProgress => const Color(0xFF2563EB),
        ReportStatus.resolved => const Color(0xFF16A34A),
        ReportStatus.rejected => const Color(0xFFDC2626),
      };

  static ReportStatus fromId(String id) =>
      ReportStatus.values.firstWhere((e) => e.name == id,
          orElse: () => ReportStatus.submitted);
}

class TimelineEntry extends Equatable {
  const TimelineEntry({
    required this.status,
    required this.date,
    this.note,
  });

  final ReportStatus status;
  final DateTime date;
  final String? note;

  @override
  List<Object?> get props => [status, date, note];
}

class Report extends Equatable {
  const Report({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.createdAt,
    required this.photos,
    required this.timeline,
    this.latitude,
    this.longitude,
    this.address,
    this.userId,
  });

  final String id;
  final String title;
  final String description;
  final ReportCategory category;
  final ReportStatus status;
  final DateTime createdAt;
  final List<String> photos; // local paths or remote URLs
  final List<TimelineEntry> timeline;
  final double? latitude;
  final double? longitude;
  final String? address;
  final String? userId;

  bool get hasLocation => latitude != null && longitude != null;

  Report copyWith({
    String? id,
    ReportStatus? status,
    List<TimelineEntry>? timeline,
  }) {
    return Report(
      id: id ?? this.id,
      title: title,
      description: description,
      category: category,
      status: status ?? this.status,
      createdAt: createdAt,
      photos: photos,
      timeline: timeline ?? this.timeline,
      latitude: latitude,
      longitude: longitude,
      address: address,
      userId: userId,
    );
  }

  @override
  List<Object?> get props => [id, title, status, createdAt];
}
