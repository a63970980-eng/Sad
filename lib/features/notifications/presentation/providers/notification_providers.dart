import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/config/supabase_config.dart';
import '../../domain/app_notification.dart';

class NotificationsController extends Notifier<List<AppNotification>> {
  bool _loading = false;

  @override
  List<AppNotification> build() {
    if (AppConfig.supabaseDataEnabled &&
        SupabaseConfig.client.auth.currentUser != null) {
      scheduleMicrotask(_loadFromSupabase);
      return const [];
    }
    if (AppConfig.demoMode) return _demoNotifications();
    return const [];
  }

  Future<void> _loadFromSupabase() async {
    if (_loading) return;
    _loading = true;
    try {
      final userId = SupabaseConfig.client.auth.currentUser?.id;
      if (userId == null) return;
      final rows = await SupabaseConfig.client
          .from('notifications')
          .select('id,title_ar,body_ar,type,read_at,created_at')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(100);
      if (!ref.mounted) return;
      state = List<Map<String, dynamic>>.from(rows)
          .map(_fromRow)
          .toList();
    } catch (_) {
      // Keep the notification surface resilient; a temporary notification
      // failure must never block the citizen app.
    } finally {
      _loading = false;
    }
  }

  AppNotification _fromRow(Map<String, dynamic> row) {
    return AppNotification(
      id: row['id'].toString(),
      titleAr: row['title_ar']?.toString() ?? 'إشعار',
      titleEn: row['title_ar']?.toString() ?? 'Notification',
      bodyAr: row['body_ar']?.toString() ?? '',
      bodyEn: row['body_ar']?.toString() ?? '',
      type: _type(row['type']?.toString()),
      date: DateTime.tryParse(row['created_at']?.toString() ?? '') ?? DateTime.now(),
      read: row['read_at'] != null,
    );
  }

  NotificationType _type(String? value) => switch (value) {
        'report_status' || 'report' => NotificationType.report,
        'service' || 'service_status' => NotificationType.service,
        'announcement' => NotificationType.announcement,
        _ => NotificationType.system,
      };

  Future<void> markAllRead() async {
    state = [for (final n in state) n..read = true];
    state = [...state];
    final userId = SupabaseConfig.client.auth.currentUser?.id;
    if (AppConfig.supabaseDataEnabled && userId != null) {
      await SupabaseConfig.client
          .from('notifications')
          .update({'read_at': DateTime.now().toIso8601String()})
          .eq('user_id', userId)
          .isFilter('read_at', null);
    }
  }

  Future<void> markRead(String id) async {
    state = [
      for (final n in state) if (n.id == id) (n..read = true) else n,
    ];
    state = [...state];
    if (AppConfig.supabaseDataEnabled) {
      await SupabaseConfig.client
          .from('notifications')
          .update({'read_at': DateTime.now().toIso8601String()})
          .eq('id', id);
    }
  }

  List<AppNotification> _demoNotifications() {
    final now = DateTime.now();
    return [
      AppNotification(id: 'n1', titleAr: 'تحديث حالة البلاغ', titleEn: 'Report status updated', bodyAr: 'تم تحويل بلاغك إلى قيد المعالجة وإرسال فريق مختص.', bodyEn: 'Your report is now in progress.', type: NotificationType.report, date: now.subtract(const Duration(hours: 2))),
      AppNotification(id: 'n2', titleAr: 'طلبك جاهز للاستلام', titleEn: 'Your request is ready', bodyAr: 'تمت الموافقة على طلبك.', bodyEn: 'Your request has been approved.', type: NotificationType.service, date: now.subtract(const Duration(hours: 6))),
      AppNotification(id: 'n3', titleAr: 'إعلان حكومي مهم', titleEn: 'Important announcement', bodyAr: 'يوجد إعلان حكومي جديد.', bodyEn: 'A new government announcement is available.', type: NotificationType.announcement, date: now.subtract(const Duration(hours: 12))),
      AppNotification(id: 'n5', titleAr: 'تم حل بلاغك', titleEn: 'Your report has been resolved', bodyAr: 'تم حل البلاغ بنجاح.', bodyEn: 'Your report was resolved successfully.', type: NotificationType.report, date: now.subtract(const Duration(days: 2))),
      AppNotification(id: 'n7', titleAr: 'مرحباً بك في منصة عدن الرقمية', titleEn: 'Welcome to Aden Digital', bodyAr: 'استكشف الخدمات الحكومية المتاحة الآن.', bodyEn: 'Explore available government services.', type: NotificationType.system, date: now.subtract(const Duration(days: 5)), read: true),
    ];
  }
}

final notificationsProvider =
    NotifierProvider<NotificationsController, List<AppNotification>>(
  NotificationsController.new,
);

final unreadCountProvider = Provider<int>((ref) {
  return ref.watch(notificationsProvider).where((n) => !n.read).length;
});
