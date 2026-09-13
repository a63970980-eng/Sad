import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/config/supabase_config.dart';
import '../../domain/app_notification.dart';

class NotificationsController extends Notifier<List<AppNotification>> {
  bool _loading = false;
  bool _disposed = false;
  StreamSubscription? _authSubscription;

  @override
  List<AppNotification> build() {
    ref.onDispose(() {
      _disposed = true;
      _authSubscription?.cancel();
    });
    _authSubscription = SupabaseConfig.client.auth.onAuthStateChange.listen((_) {
      if (_disposed) return;
      ref.invalidateSelf();
    });

    final user = SupabaseConfig.client.auth.currentUser;
    if (AppConfig.supabaseDataEnabled && user != null) {
      scheduleMicrotask(_loadFromSupabase);
      _subscribeRealtime(user.id);
      return const [];
    }
    return AppConfig.demoMode ? _demoNotifications() : const [];
  }

  Future<void> _loadFromSupabase() async {
    if (_loading || _disposed) return;
    _loading = true;
    try {
      final userId = SupabaseConfig.client.auth.currentUser?.id;
      if (userId == null || !AppConfig.supabaseDataEnabled || _disposed) return;
      final rows = await SupabaseConfig.client
          .from('notifications')
          .select('id,title_ar,body_ar,type,read_at,created_at')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(100);
      if (_disposed) return;
      state = List<Map<String, dynamic>>.from(rows).map(_fromRow).toList();
    } catch (_) {
      // Notifications are non-blocking; keep the current state on failure.
    } finally {
      _loading = false;
    }
  }

  void _subscribeRealtime(String userId) {
    final channel = SupabaseConfig.client.channel('notifications-$userId');
    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (_) => unawaited(_loadFromSupabase()),
        )
        .subscribe();
    ref.onDispose(() => SupabaseConfig.client.removeChannel(channel));
  }

  AppNotification _fromRow(Map<String, dynamic> row) => AppNotification(
        id: row['id'].toString(),
        titleAr: row['title_ar']?.toString() ?? 'إشعار',
        titleEn: row['title_ar']?.toString() ?? 'Notification',
        bodyAr: row['body_ar']?.toString() ?? '',
        bodyEn: row['body_ar']?.toString() ?? '',
        type: _type(row['type']?.toString()),
        date: DateTime.tryParse(row['created_at']?.toString() ?? '') ?? DateTime.now(),
        read: row['read_at'] != null,
      );

  NotificationType _type(String? value) => switch (value) {
        'report_status' || 'report' => NotificationType.report,
        'service' || 'service_status' => NotificationType.service,
        'announcement' => NotificationType.announcement,
        _ => NotificationType.system,
      };

  Future<void> markAllRead() async {
    final userId = SupabaseConfig.client.auth.currentUser?.id;
    final previous = [for (final notification in state) notification.copyWith()];
    state = [for (final notification in state) notification.copyWith(read: true)];
    if (!AppConfig.supabaseDataEnabled || userId == null) return;
    try {
      await SupabaseConfig.client
          .from('notifications')
          .update({'read_at': DateTime.now().toIso8601String()})
          .eq('user_id', userId)
          .isFilter('read_at', null);
    } catch (_) {
      if (!_disposed) state = previous;
    }
  }

  Future<void> markRead(String id) async {
    final userId = SupabaseConfig.client.auth.currentUser?.id;
    final previous = [for (final notification in state) notification.copyWith()];
    state = [
      for (final notification in state)
        notification.id == id ? notification.copyWith(read: true) : notification,
    ];
    if (!AppConfig.supabaseDataEnabled || userId == null) return;
    try {
      await SupabaseConfig.client
          .from('notifications')
          .update({'read_at': DateTime.now().toIso8601String()})
          .eq('id', id)
          .eq('user_id', userId);
    } catch (_) {
      if (!_disposed) state = previous;
    }
  }

  List<AppNotification> _demoNotifications() {
    final now = DateTime.now();
    return [
      AppNotification(id:'n1',titleAr:'تحديث حالة البلاغ',titleEn:'Report status updated',bodyAr:'تم تحويل بلاغك إلى قيد المعالجة وإرسال فريق مختص.',bodyEn:'Your report is now in progress.',type:NotificationType.report,date:now.subtract(const Duration(hours:2))),
      AppNotification(id:'n2',titleAr:'طلبك جاهز للاستلام',titleEn:'Your request is ready',bodyAr:'تمت الموافقة على طلبك.',bodyEn:'Your request has been approved.',type:NotificationType.service,date:now.subtract(const Duration(hours:6))),
      AppNotification(id:'n3',titleAr:'إعلان حكومي مهم',titleEn:'Important announcement',bodyAr:'يوجد إعلان حكومي جديد.',bodyEn:'A new government announcement is available.',type:NotificationType.announcement,date:now.subtract(const Duration(hours:12))),
      AppNotification(id:'n5',titleAr:'تم حل بلاغك',titleEn:'Your report has been resolved',bodyAr:'تم حل البلاغ بنجاح.',bodyEn:'Your report was resolved successfully.',type:NotificationType.report,date:now.subtract(const Duration(days:2))),
      AppNotification(id:'n7',titleAr:'مرحباً بك في منصة عدن الرقمية',titleEn:'Welcome to Aden Digital',bodyAr:'استكشف الخدمات الحكومية المتاحة الآن.',bodyEn:'Explore government services.',type:NotificationType.system,date:now.subtract(const Duration(days:5)),read:true),
    ];
  }
}

final notificationsProvider = NotifierProvider<NotificationsController,List<AppNotification>>(NotificationsController.new);
final unreadCountProvider = Provider<int>((ref) => ref.watch(notificationsProvider).where((n) => !n.read).length);
