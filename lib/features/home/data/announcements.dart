import 'package:flutter/material.dart';

class Announcement {
  const Announcement({
    required this.id,
    required this.titleAr,
    required this.titleEn,
    required this.bodyAr,
    required this.bodyEn,
    required this.date,
    required this.icon,
    required this.color,
    this.priority = 'normal',
  });

  final String id;
  final String titleAr;
  final String titleEn;
  final String bodyAr;
  final String bodyEn;
  final DateTime date;
  final IconData icon;
  final Color color;
  final String priority; // 'critical', 'high', 'normal'

  String title(bool isAr) => isAr ? titleAr : titleEn;
  String body(bool isAr) => isAr ? bodyAr : bodyEn;
}

class Announcements {
  Announcements._();

  static List<Announcement> all = [
    // Critical/Urgent Announcements
    Announcement(
      id: 'a1',
      titleAr: 'إطلاق منصة عدن الرقمية الرسمية',
      titleEn: 'Official Aden Digital Platform Launch',
      bodyAr: 'تم إطلاق منصة عدن الرقمية الرسمية لتوفير الخدمات الحكومية الإلكترونية. يمكنكم الآن إنجاز معاملاتكم بسهولة وسرعة.',
      bodyEn: 'The official Aden Digital platform has been launched to provide government services online. Complete your transactions easily and quickly.',
      date: DateTime.now().subtract(const Duration(hours: 2)),
      icon: Icons.campaign_outlined,
      color: const Color(0xFF0E7C52),
      priority: 'high',
    ),
    
    // Maintenance Notices
    Announcement(
      id: 'a2',
      titleAr: 'جدول صيانة الكهرباء',
      titleEn: 'Electricity Maintenance Schedule',
      bodyAr: 'سيتم إجراء صيانة دورية لشبكة الكهرباء في منطقة المنصورة يوم الجمعة من 09:00 صباحًا إلى 01:00 ظهرًا. نعتذر عن الإزعاج.',
      bodyEn: 'Scheduled maintenance in Al-Mansoura district on Friday 9 AM – 1 PM. We apologize for any inconvenience.',
      date: DateTime.now().subtract(const Duration(hours: 5)),
      icon: Icons.bolt_outlined,
      color: const Color(0xFFF59E0B),
      priority: 'high',
    ),

    // Service Hours
    Announcement(
      id: 'a3',
      titleAr: 'تمديد ساعات العمل في مكاتب الأحوال المدنية',
      titleEn: 'Extended Working Hours - Civil Affairs',
      bodyAr: 'تم تمديد ساعات عمل مكاتب الأحوال المدنية من 8:00 صباحًا إلى 8:00 مساءً خلال موسم الإصدار. تفضلوا بزيارتنا.',
      bodyEn: 'Civil affairs offices now open from 8 AM to 8 PM during issuance season. Visit us anytime.',
      date: DateTime.now().subtract(const Duration(days: 1)),
      icon: Icons.access_time_rounded,
      color: const Color(0xFF2563EB),
      priority: 'normal',
    ),

    // Service Updates
    Announcement(
      id: 'a4',
      titleAr: 'خدمة تحديث بيانات الهاتف الجديدة',
      titleEn: 'New Phone Number Update Service',
      bodyAr: 'يمكنكم الآن تحديث رقم هاتفكم الجديد من خلال التطبيق دون الحاجة لزيارة المكتب. الخدمة متاحة 24/7.',
      bodyEn: 'You can now update your phone number through the app anytime. Service available 24/7.',
      date: DateTime.now().subtract(const Duration(days: 2)),
      icon: Icons.phone_in_talk_rounded,
      color: const Color(0xFF16A34A),
      priority: 'normal',
    ),

    // Traffic/Public Safety
    Announcement(
      id: 'a5',
      titleAr: 'تنبيه: الازدحام على الطريق السريعة',
      titleEn: 'Alert: Traffic on Highway',
      bodyAr: 'نتوقع ازدحاماً مرورياً على الطريق السريعة الرئيسية غدًا بسبب أعمال صيانة. الرجاء اختيار طرق بديلة.',
      bodyEn: 'Expect traffic on main highway tomorrow due to maintenance works. Please use alternative routes.',
      date: DateTime.now().subtract(const Duration(days: 3)),
      icon: Icons.traffic_outlined,
      color: const Color(0xFFDC2626),
      priority: 'high',
    ),

    // Water Services
    Announcement(
      id: 'a6',
      titleAr: 'إشعار: انقطاع المياه المتوقع',
      titleEn: 'Notice: Water Supply Interruption',
      bodyAr: 'سيتم قطع المياه في منطقة الشيخ عثمان يوم السبت من 6:00 صباحًا إلى 6:00 مساءً للصيانة الدورية.',
      bodyEn: 'Water supply will be cut in Sheikh Othman area Saturday 6 AM - 6 PM for maintenance.',
      date: DateTime.now().subtract(const Duration(days: 4)),
      icon: Icons.water_drop_outlined,
      color: const Color(0xFF0891B2),
      priority: 'high',
    ),
  ];
}
