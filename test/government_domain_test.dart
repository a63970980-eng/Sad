import 'package:flutter_test/flutter_test.dart';

import 'package:aden_digital/features/notifications/domain/app_notification.dart';
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
}
