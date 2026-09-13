import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/config/supabase_config.dart';
import '../../data/repositories/government_employee_repository.dart';
import '../../data/repositories/mock_admin_repository.dart';
import '../../data/repositories/supabase_admin_repository.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/repositories/admin_repository.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  if (AppConfig.supabaseDataEnabled &&
      SupabaseConfig.client.auth.currentUser != null) {
    return SupabaseAdminRepository();
  }
  if (AppConfig.demoMode) return MockAdminRepository();
  throw StateError('جلسة حكومية مطلوبة للوصول إلى لوحة الإدارة.');
});

final governmentEmployeeRepositoryProvider = Provider<GovernmentEmployeeRepository>((ref) {
  return GovernmentEmployeeRepository();
});

final governmentEmployeesProvider = FutureProvider.autoDispose<List<GovernmentEmployee>>((ref) async {
  return ref.watch(governmentEmployeeRepositoryProvider).listActive();
});

final dashboardStatsProvider = FutureProvider.autoDispose<DashboardStats>((ref) async {
  return ref.watch(adminRepositoryProvider).getDashboardStats();
});

final regionalStatsProvider = FutureProvider.autoDispose<List<RegionalReportStats>>((ref) async {
  return ref.watch(adminRepositoryProvider).getRegionalStats();
});

final recentActivityProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  return ref.watch(adminRepositoryProvider).getRecentActivity(10);
});
