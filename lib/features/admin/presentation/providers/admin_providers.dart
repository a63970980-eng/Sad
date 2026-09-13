import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/config/supabase_config.dart';
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

final dashboardStatsProvider =
    FutureProvider.autoDispose<DashboardStats>((ref) async {
  final repo = ref.watch(adminRepositoryProvider);
  return repo.getDashboardStats();
});

final regionalStatsProvider =
    FutureProvider.autoDispose<List<RegionalReportStats>>((ref) async {
  final repo = ref.watch(adminRepositoryProvider);
  return repo.getRegionalStats();
});

final recentActivityProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final repo = ref.watch(adminRepositoryProvider);
  return repo.getRecentActivity(10);
});
