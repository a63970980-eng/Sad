import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/dashboard_stats.dart';
import '../../domain/repositories/admin_repository.dart';

class MockAdminRepository implements AdminRepository {
  @override
  Future<DashboardStats> getDashboardStats() async {
    await Future.delayed(const Duration(milliseconds: 600));
    // More realistic statistics representing a growing government platform
    return const DashboardStats(
      totalReports: 3847,        // More reports as the system grows
      newReports: 47,            // New reports today
      inProgressReports: 312,    // Actively being worked on
      resolvedReports: 3421,     // Successfully resolved
      rejectedReports: 67,       // Invalid/rejected
      totalUsers: 15240,         // Registered citizens
      activeUsers: 7650,         // 50% active users
      totalServices: 18,         // Available services
      totalRequests: 12847,      // Total service requests
      pendingRequests: 1240,     // Waiting for processing
      completedRequests: 11607,  // Successfully completed
    );
  }

  @override
  Future<List<RegionalReportStats>> getRegionalStats() async {
    await Future.delayed(const Duration(milliseconds: 400));
    // Statistics by region of Aden
    return [
      const RegionalReportStats(
        region: 'المعلا',
        total: 842,
        resolved: 756,
        pending: 86,
      ),
      const RegionalReportStats(
        region: 'التواهي',
        total: 687,
        resolved: 612,
        pending: 75,
      ),
      const RegionalReportStats(
        region: 'كريتر',
        total: 545,
        resolved: 478,
        pending: 67,
      ),
      const RegionalReportStats(
        region: 'خور مكسر',
        total: 412,
        resolved: 367,
        pending: 45,
      ),
      const RegionalReportStats(
        region: 'الشيخ عثمان',
        total: 678,
        resolved: 589,
        pending: 89,
      ),
      const RegionalReportStats(
        region: 'المنصورة',
        total: 456,
        resolved: 401,
        pending: 55,
      ),
      const RegionalReportStats(
        region: 'البريقة',
        total: 227,
        resolved: 218,
        pending: 9,
      ),
    ];
  }

  @override
  Future<void> updateReportStatus(String reportId, String newStatus) async {
    await Future.delayed(const Duration(milliseconds: 400));
    // In real implementation, this would update the database
  }

  @override
  Future<List<Map<String, dynamic>>> getRecentActivity(int limit) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final now = DateTime.now();
    return [
      {
        'type': 'report',
        'action': 'تم حل البلاغ #RPT-100245',
        'region': 'المعلا',
        'time': now.subtract(const Duration(minutes: 5))
      },
      {
        'type': 'report',
        'action': 'بلاغ جديد #RPT-100301 - انقطاع كهرباء',
        'region': 'الشيخ عثمان',
        'time': now.subtract(const Duration(minutes: 15))
      },
      {
        'type': 'service',
        'action': 'تم تقديم طلب تجديد جواز السفر',
        'region': 'التواهي',
        'time': now.subtract(const Duration(minutes: 25))
      },
      {
        'type': 'user',
        'action': 'مستخدم جديد قام بالتسجيل',
        'region': 'كريتر',
        'time': now.subtract(const Duration(minutes: 45))
      },
      {
        'type': 'report',
        'action': 'تم إعادة فتح البلاغ #RPT-100277',
        'region': 'السيرة',
        'time': now.subtract(const Duration(hours: 1))
      },
      {
        'type': 'service',
        'action': 'تم إصدار رقم هوية وطنية جديدة',
        'region': 'خور مكسر',
        'time': now.subtract(const Duration(hours: 2))
      },
    ];
  }
}

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return MockAdminRepository();
});
