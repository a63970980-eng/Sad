import '../entities/dashboard_stats.dart';

abstract class AdminRepository {
  Future<DashboardStats> getDashboardStats();
  Future<List<RegionalReportStats>> getRegionalStats();
  Future<void> updateReportStatus(String reportId, String newStatus);
  Future<List<Map<String, dynamic>>> getRecentActivity(int limit);
}
