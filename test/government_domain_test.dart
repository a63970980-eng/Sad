import 'package:flutter_test/flutter_test.dart';

import 'package:aden_digital/features/notifications/domain/app_notification.dart';
import 'package:aden_digital/features/reports/domain/entities/report.dart';
import 'package:aden_digital/features/services/data/services_catalog.dart';

void main() {
  group('ServicesCatalog', () {
    test('contains stable unique service identifiers', () {
      final services = ServicesCatalog.all;
      final ids = services.map((service) => service.id).toList();

      expect(services, isNotEmpty);
      expect(ids.toSet(), hasLength(ids.length));
      expect(ids, containsAll(<String>[
        'national_id',
        'passport',
        'driving_license',
        'vehicle',
        'municipality',
        'utilities',
      ]));
    });

    test('resolves services by id and returns null for unknown ids', () {
      expect(ServicesCatalog.byId('passport')?.id, 'passport');
      expect(ServicesCatalog.byId('does_not_exist'), isNull);
    });

    test('service actions have unique identifiers within each service', () {
      for (final service in ServicesCatalog.all) {
        final actionIds = service.actions.map((action) => action.id).toList();
        expect(actionIds.toSet(), hasLength(actionIds.length),
            reason: 'Duplicate action id in ${service.id}');
      }
    });
  });

  group('AppNotification', () {
    final notification = AppNotification(
      id: 'n1',
      titleAr: 'تحديث البلاغ',
      titleEn: 'Report update',
      bodyAr: 'تم تحديث حالة البلاغ.',
      bodyEn: 'Your report was updated.',
      type: NotificationType.report,
      date: DateTime(2026, 9, 15),
    );

    test('selects localized title and body', () {
      expect(notification.title(true), 'تحديث البلاغ');
      expect(notification.title(false), 'Report update');
      expect(notification.body(true), 'تم تحديث حالة البلاغ.');
      expect(notification.body(false), 'Your report was updated.');
    });

    test('copyWith changes read state without losing notification data', () {
      final read = notification.copyWith(read: true);

      expect(read.read, isTrue);
      expect(read.id, notification.id);
      expect(read.titleAr, notification.titleAr);
      expect(read.titleEn, notification.titleEn);
      expect(read.bodyAr, notification.bodyAr);
      expect(read.bodyEn, notification.bodyEn);
      expect(read.type, notification.type);
      expect(read.date, notification.date);
    });
  });

  group('Report domain behavior', () {
    final report = Report(
      id: 'r1',
      referenceNo: 'ADN-AB12CD34EF',
      title: 'تسرب مياه',
      description: 'يوجد تسرب في الطريق.',
      category: ReportCategory.waterLeak,
      status: ReportStatus.reviewing,
      createdAt: DateTime(2026, 9, 15),
      photos: const ['photo.jpg'],
      timeline: const [],
      latitude: 12.8,
      longitude: 45.0,
      address: 'عدن',
      userId: 'u1',
    );

    test('exposes location and stable display reference', () {
      expect(report.hasLocation, isTrue);
      expect(report.displayReference, 'ADN-AB12CD34EF');
    });

    test('falls back to id when reference is missing or blank', () {
      final missing = report.copyWith(referenceNo: null);
      expect(missing.displayReference, 'ADN-AB12CD34EF');

      final blank = Report(
        id: 'r2',
        referenceNo: '   ',
        title: report.title,
        description: report.description,
        category: report.category,
        status: report.status,
        createdAt: report.createdAt,
        photos: const [],
        timeline: const [],
      );
      expect(blank.displayReference, 'r2');
    });

    test('copyWith preserves identity and supports anonymous handling', () {
      final anonymous = report.copyWith(
        status: ReportStatus.inProgress,
        isAnonymous: true,
      );

      expect(anonymous.id, report.id);
      expect(anonymous.userId, report.userId);
      expect(anonymous.status, ReportStatus.inProgress);
      expect(anonymous.isAnonymous, isTrue);
      expect(anonymous.title, report.title);
      expect(anonymous.category, report.category);
    });

    test('unknown category and status ids fail safely to defined defaults', () {
      expect(
        ReportCategoryX.fromId('unknown_category'),
        ReportCategory.publicSafety,
      );
      expect(
        ReportStatusX.fromId('unknown_status'),
        ReportStatus.submitted,
      );
    });
  });
}
