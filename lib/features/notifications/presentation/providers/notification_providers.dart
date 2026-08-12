import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/app_notification.dart';

class NotificationsController extends Notifier<List<AppNotification>> {
  @override
  List<AppNotification> build() {
    final now = DateTime.now();
    return [
      // Recent Report Updates
      AppNotification(
        id: 'n1',
        titleAr: 'تحديث حالة البلاغ',
        titleEn: 'Report status updated',
        bodyAr: 'تم تحويل بلاغك RPT-100245 (انقطاع الكهرباء) إلى قيد المعالجة وإرسال فريق صيانة متخصص.',
        bodyEn: 'Your report RPT-100245 (Power outage) is now in progress; a specialist crew was dispatched.',
        type: NotificationType.report,
        date: now.subtract(const Duration(hours: 2)),
      ),
      
      // Service Request Status
      AppNotification(
        id: 'n2',
        titleAr: 'طلبك جاهز للاستلام',
        titleEn: 'Your request is ready for collection',
        bodyAr: 'تمت الموافقة على طلب تجديد البطاقة الشخصية. يرجى الحضور لمكتب الأحوال المدنية للاستلام.',
        bodyEn: 'Your ID renewal request was approved. Please visit the civil affairs office to collect it.',
        type: NotificationType.service,
        date: now.subtract(const Duration(hours: 6)),
      ),
      
      // Government Announcement
      AppNotification(
        id: 'n3',
        titleAr: 'إعلان حكومي مهم',
        titleEn: 'Important government announcement',
        bodyAr: 'صيانة مجدولة لشبكة الكهرباء في منطقة المنصورة يوم الجمعة من 9 صباحاً إلى 1 ظهراً.',
        bodyEn: 'Scheduled electricity maintenance in Al-Mansoura on Friday 9 AM – 1 PM.',
        type: NotificationType.announcement,
        date: now.subtract(const Duration(hours: 12)),
      ),
      
      // Another Report Update
      AppNotification(
        id: 'n5',
        titleAr: 'تم حل بلاغك',
        titleEn: 'Your report has been resolved',
        bodyAr: 'تم حل بلاغ تسرب المياه RPT-100231 بنجاح. شكراً لإبلاغك عن المشكلة.',
        bodyEn: 'Your water leak report RPT-100231 has been successfully resolved. Thank you for reporting.',
        type: NotificationType.report,
        date: now.subtract(const Duration(days: 2)),
      ),
      
      // Service Reminder
      AppNotification(
        id: 'n6',
        titleAr: 'تذكير: جواز سفرك ينتهي قريباً',
        titleEn: 'Reminder: Your passport is expiring soon',
        bodyAr: 'جواز سفرك سينتهي خلال 30 يوماً. نحن نوصي بتجديده الآن عبر التطبيق.',
        bodyEn: 'Your passport expires in 30 days. We recommend renewing it now through the app.',
        type: NotificationType.service,
        date: now.subtract(const Duration(days: 3)),
      ),
      
      // System Message
      AppNotification(
        id: 'n7',
        titleAr: 'مرحباً بك في منصة عدن الرقمية',
        titleEn: 'Welcome to Aden Digital Platform',
        bodyAr: 'شكراً لانضمامك إلى منصة عدن الرقمية. استكشف الخدمات الحكومية المتاحة الآن.',
        bodyEn: 'Thank you for joining Aden Digital. Explore government services now available.',
        type: NotificationType.system,
        date: now.subtract(const Duration(days: 5)),
        read: true,
      ),
      
      // Alert
      AppNotification(
        id: 'n8',
        titleAr: 'تنبيه أمني',
        titleEn: 'Security alert',
        bodyAr: 'تم محاولة دخول غير مصرح بها لحسابك. إذا لم تكن أنت، يرجى تغيير كلمة المرور.',
        bodyEn: 'Unauthorized login attempt detected. If this wasn\'t you, please change your password.',
        type: NotificationType.system,
        date: now.subtract(const Duration(days: 6)),
        read: true,
      ),
      
      // Another Report Update
      AppNotification(
        id: 'n9',
        titleAr: 'بلاغ جديد قيد المراجعة',
        titleEn: 'New report under review',
        bodyAr: 'تم استقبال بلاغك عن تراكم القمامة RPT-100277 وهو الآن قيد المراجعة.',
        bodyEn: 'Your garbage accumulation report RPT-100277 has been received and is under review.',
        type: NotificationType.report,
        date: now.subtract(const Duration(days: 7)),
        read: true,
      ),
    ];
  }

  void markAllRead() {
    state = [for (final n in state) n..read = true];
    state = [...state];
  }

  void markRead(String id) {
    state = [
      for (final n in state)
        if (n.id == id) (n..read = true) else n
    ];
    state = [...state];
  }

  int get unread => state.where((n) => !n.read).length;
}

final notificationsProvider =
    NotifierProvider<NotificationsController, List<AppNotification>>(
        NotificationsController.new);

final unreadCountProvider = Provider<int>((ref) {
  return ref.watch(notificationsProvider).where((n) => !n.read).length;
});
