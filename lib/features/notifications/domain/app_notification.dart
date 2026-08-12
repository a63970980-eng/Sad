import 'package:flutter/material.dart';

enum NotificationType { report, service, announcement, system }

extension NotificationTypeX on NotificationType {
  IconData get icon => switch (this) {
        NotificationType.report => Icons.report_rounded,
        NotificationType.service => Icons.assignment_turned_in_rounded,
        NotificationType.announcement => Icons.campaign_rounded,
        NotificationType.system => Icons.info_rounded,
      };

  Color get color => switch (this) {
        NotificationType.report => const Color(0xFFDC2626),
        NotificationType.service => const Color(0xFF0E7C52),
        NotificationType.announcement => const Color(0xFF2563EB),
        NotificationType.system => const Color(0xFF6366F1),
      };
}

class AppNotification {
  AppNotification({
    required this.id,
    required this.titleAr,
    required this.titleEn,
    required this.bodyAr,
    required this.bodyEn,
    required this.type,
    required this.date,
    this.read = false,
  });

  final String id;
  final String titleAr;
  final String titleEn;
  final String bodyAr;
  final String bodyEn;
  final NotificationType type;
  final DateTime date;
  bool read;

  String title(bool isAr) => isAr ? titleAr : titleEn;
  String body(bool isAr) => isAr ? bodyAr : bodyEn;
}
