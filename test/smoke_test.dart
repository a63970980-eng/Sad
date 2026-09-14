import 'package:flutter_test/flutter_test.dart';
import 'package:aden_digital/features/auth/domain/entities/app_user.dart';

void main() {
  group('AppUser domain behavior', () {
    test('falls back to phone number when full name is empty', () {
      const user = AppUser(uid: 'u1', phoneNumber: '777000000');

      expect(user.displayName, '777000000');
      expect(user.initials, '👤');
      expect(user.isGovernmentUser, isFalse);
      expect(user.canAccessAdminDashboard, isFalse);
    });

    test('identifies government roles and admin dashboard roles correctly', () {
      const fieldWorker = AppUser(
        uid: 'u2',
        phoneNumber: '777000001',
        role: 'field_worker',
      );
      const supervisor = AppUser(
        uid: 'u3',
        phoneNumber: '777000002',
        role: 'supervisor',
      );

      expect(fieldWorker.isGovernmentUser, isTrue);
      expect(fieldWorker.canAccessAdminDashboard, isFalse);
      expect(supervisor.isGovernmentUser, isTrue);
      expect(supervisor.canAccessAdminDashboard, isTrue);
    });

    test('copyWith preserves the server-controlled role', () {
      const user = AppUser(
        uid: 'u4',
        phoneNumber: '777000003',
        fullName: 'أحمد محمد',
        role: 'entity_manager',
      );

      final updated = user.copyWith(fullName: 'أحمد علي');

      expect(updated.fullName, 'أحمد علي');
      expect(updated.uid, user.uid);
      expect(updated.phoneNumber, user.phoneNumber);
      expect(updated.role, 'entity_manager');
      expect(updated.canAccessAdminDashboard, isTrue);
    });

    test('serializes and restores a user without losing core identity', () {
      final createdAt = DateTime.utc(2026, 9, 14, 12, 30);
      final user = AppUser(
        uid: 'u5',
        phoneNumber: '777000004',
        fullName: 'سارة علي',
        nationalNumber: '123456789',
        email: 'sara@example.test',
        createdAt: createdAt,
        role: 'citizen',
      );

      final restored = AppUser.fromMap(user.toMap());

      expect(restored.uid, user.uid);
      expect(restored.phoneNumber, user.phoneNumber);
      expect(restored.fullName, user.fullName);
      expect(restored.nationalNumber, user.nationalNumber);
      expect(restored.email, user.email);
      expect(restored.createdAt, createdAt);
      expect(restored.role, 'citizen');
      expect(restored.displayName, 'سارة علي');
    });
  });
}
