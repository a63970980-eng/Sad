import 'dart:async';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/report.dart';
import '../../domain/repositories/report_repository.dart';

/// In-memory reports store (demo mode). Seeded with realistic sample data.
class MockReportRepository implements ReportRepository {
  MockReportRepository() {
    _seed();
  }

  final _reports = <Report>[];
  final _controller = StreamController<List<Report>>.broadcast();

  void _seed() {
    final now = DateTime.now();
    _reports.addAll([
      // Recent Power Outage - In Progress
      Report(
        id: 'RPT-100245',
        title: 'انقطاع الكهرباء في حي المعلا',
        description: 'انقطاع مستمر للتيار الكهربائي منذ الصباح الباكر في شارع الملكة أروى. لا كهرباء والجو حار جداً.',
        category: ReportCategory.powerOutage,
        status: ReportStatus.inProgress,
        createdAt: now.subtract(const Duration(days: 1, hours: 3)),
        photos: const [],
        latitude: 12.7905,
        longitude: 45.0335,
        address: 'المعلا، عدن',
        userId: 'me',
        timeline: [
          TimelineEntry(status: ReportStatus.submitted, date: now.subtract(const Duration(days: 1, hours: 3)), note: 'تم استقبال البلاغ'),
          TimelineEntry(status: ReportStatus.reviewing, date: now.subtract(const Duration(days: 1, hours: 1)), note: 'جاري المراجعة'),
          TimelineEntry(status: ReportStatus.inProgress, date: now.subtract(const Duration(hours: 6)), note: 'تم إرسال فريق الصيانة'),
        ],
      ),
      
      // Resolved Water Leak
      Report(
        id: 'RPT-100231',
        title: 'تسرب مياه في خط رئيسي',
        description: 'تسرب كبير للمياه أمام مستشفى الجمهورية يسبب إهداراً كبيراً وتأثراً للحي.',
        category: ReportCategory.waterLeak,
        status: ReportStatus.resolved,
        createdAt: now.subtract(const Duration(days: 5)),
        photos: const [],
        latitude: 12.7782,
        longitude: 45.0301,
        address: 'كريتر، عدن',
        userId: 'me',
        timeline: [
          TimelineEntry(status: ReportStatus.submitted, date: now.subtract(const Duration(days: 5)), note: 'تم استقبال البلاغ'),
          TimelineEntry(status: ReportStatus.reviewing, date: now.subtract(const Duration(days: 5)).add(const Duration(hours: 2)), note: 'جاري المراجعة'),
          TimelineEntry(status: ReportStatus.inProgress, date: now.subtract(const Duration(days: 4)), note: 'تم تكليف الفريق'),
          TimelineEntry(status: ReportStatus.resolved, date: now.subtract(const Duration(days: 3)), note: 'تم إصلاح الخط بنجاح ✓'),
        ],
      ),
      
      // Road Damage - Submitted
      Report(
        id: 'RPT-100289',
        title: 'حفرة كبيرة في الطريق',
        description: 'توجد حفرة كبيرة في شارع 26 يوليو قد تسبب حوادث. الطريق متضرر بشدة.',
        category: ReportCategory.roadDamage,
        status: ReportStatus.submitted,
        createdAt: now.subtract(const Duration(hours: 8)),
        photos: const [],
        latitude: 12.8045,
        longitude: 45.0421,
        address: 'الشيخ عثمان، عدن',
        userId: 'me',
        timeline: [
          TimelineEntry(status: ReportStatus.submitted, date: now.subtract(const Duration(hours: 8)), note: 'تم استقبال البلاغ'),
        ],
      ),
      
      // Garbage Issue - Reviewing
      Report(
        id: 'RPT-100277',
        title: 'تراكم القمامة في الحي السكني',
        description: 'تراكم كبير للقمامة والأوساخ في منطقة خدمات الحي. رائحة كريهة وحشرات.',
        category: ReportCategory.garbage,
        status: ReportStatus.reviewing,
        createdAt: now.subtract(const Duration(days: 2, hours: 5)),
        photos: const [],
        latitude: 12.7654,
        longitude: 45.0268,
        address: 'السيرة، عدن',
        userId: 'me',
        timeline: [
          TimelineEntry(status: ReportStatus.submitted, date: now.subtract(const Duration(days: 2, hours: 5)), note: 'تم استقبال البلاغ'),
          TimelineEntry(status: ReportStatus.reviewing, date: now.subtract(const Duration(days: 1, hours: 10)), note: 'جاري التحقق من البلاغ'),
        ],
      ),
      
      // Street Light Out - In Progress
      Report(
        id: 'RPT-100256',
        title: 'أعطال في أنوار الشارع',
        description: 'عدة أعمدة إضاءة معطلة في شارع 30 يوليو مما يسبب ظلام دامس ليلاً.',
        category: ReportCategory.streetLight,
        status: ReportStatus.inProgress,
        createdAt: now.subtract(const Duration(days: 7)),
        photos: const [],
        latitude: 12.8123,
        longitude: 45.0512,
        address: 'التواهي، عدن',
        userId: 'me',
        timeline: [
          TimelineEntry(status: ReportStatus.submitted, date: now.subtract(const Duration(days: 7)), note: 'تم استقبال البلاغ'),
          TimelineEntry(status: ReportStatus.reviewing, date: now.subtract(const Duration(days: 6)), note: 'تم التحقق'),
          TimelineEntry(status: ReportStatus.inProgress, date: now.subtract(const Duration(days: 5)), note: 'تم شراء الأعمدة الجديدة'),
        ],
      ),
      
      // Sewage Issue - Resolved
      Report(
        id: 'RPT-100198',
        title: 'مشكلة في نظام الصرف الصحي',
        description: 'تسرب من خطوط الصرف الصحي في حي معين مما أثر على النظافة والصحة العامة.',
        category: ReportCategory.sewage,
        status: ReportStatus.resolved,
        createdAt: now.subtract(const Duration(days: 14)),
        photos: const [],
        latitude: 12.7856,
        longitude: 45.0198,
        address: 'المنصورة، عدن',
        userId: 'me',
        timeline: [
          TimelineEntry(status: ReportStatus.submitted, date: now.subtract(const Duration(days: 14)), note: 'تم استقبال البلاغ'),
          TimelineEntry(status: ReportStatus.reviewing, date: now.subtract(const Duration(days: 13)), note: 'تم التحقق'),
          TimelineEntry(status: ReportStatus.inProgress, date: now.subtract(const Duration(days: 12)), note: 'تم الكشف والإصلاح'),
          TimelineEntry(status: ReportStatus.resolved, date: now.subtract(const Duration(days: 10)), note: 'تم إصلاح المشكلة بنجاح ✓'),
        ],
      ),
      
      // Public Safety - Rejected
      Report(
        id: 'RPT-100112',
        title: 'مجموعة مشبوهة في المنطقة',
        description: 'تجمع لأشخاص مشبوهين في ساحة السلام. يثيرون مخاوف أمنية.',
        category: ReportCategory.publicSafety,
        status: ReportStatus.rejected,
        createdAt: now.subtract(const Duration(days: 21)),
        photos: const [],
        latitude: 12.7923,
        longitude: 45.0276,
        address: 'ساحة السلام، عدن',
        userId: 'me',
        timeline: [
          TimelineEntry(status: ReportStatus.submitted, date: now.subtract(const Duration(days: 21)), note: 'تم استقبال البلاغ'),
          TimelineEntry(status: ReportStatus.reviewing, date: now.subtract(const Duration(days: 20)), note: 'جاري التحقق'),
          TimelineEntry(status: ReportStatus.rejected, date: now.subtract(const Duration(days: 19)), note: 'تم التحقق وتبين عدم وجود مشكلة'),
        ],
      ),
      
      // Another Power Outage - Submitted
      Report(
        id: 'RPT-100301',
        title: 'انقطاع كهرباء جزئي في منطقة الشيخ عثمان',
        description: 'انقطاع متقطع للكهرباء في شارع النيل. الكهرباء تنقطع وتعود كل بضع دقائق.',
        category: ReportCategory.powerOutage,
        status: ReportStatus.submitted,
        createdAt: now.subtract(const Duration(hours: 2)),
        photos: const [],
        latitude: 12.8067,
        longitude: 45.0398,
        address: 'الشيخ عثمان، عدن',
        userId: 'me',
        timeline: [
          TimelineEntry(status: ReportStatus.submitted, date: now.subtract(const Duration(hours: 2)), note: 'تم استقبال البلاغ'),
        ],
      ),
      
      // Water Leak - Reviewing
      Report(
        id: 'RPT-100265',
        title: 'تسرب مياه من خط توزيع',
        description: 'تسرب مستمر من خطوط توزيع المياه مما يسبب هدراً وفقداناً للضغط.',
        category: ReportCategory.waterLeak,
        status: ReportStatus.reviewing,
        createdAt: now.subtract(const Duration(days: 3, hours: 12)),
        photos: const [],
        latitude: 12.7701,
        longitude: 45.0345,
        address: 'البريقة، عدن',
        userId: 'me',
        timeline: [
          TimelineEntry(status: ReportStatus.submitted, date: now.subtract(const Duration(days: 3, hours: 12)), note: 'تم استقبال البلاغ'),
          TimelineEntry(status: ReportStatus.reviewing, date: now.subtract(const Duration(days: 2, hours: 8)), note: 'جاري الفحص والتقييم'),
        ],
      ),
    ]);
  }

  List<Report> _forUser(String userId) =>
      _reports.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  @override
  Stream<List<Report>> watchUserReports(String userId) async* {
    yield _forUser(userId);
    yield* _controller.stream;
  }

  @override
  Future<List<Report>> fetchUserReports(String userId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _forUser(userId);
  }

  @override
  Future<Report> submitReport(Report report) async {
    await Future.delayed(const Duration(milliseconds: 900));
    _reports.insert(0, report);
    _controller.add(_forUser(report.userId ?? 'me'));
    return report;
  }

  @override
  Future<Report?> getById(String id) async {
    try {
      return _reports.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }
}

// silence unused import lint if constants not referenced elsewhere
// ignore: unused_element
const _kPageSize = AppConstants.pageSize;
