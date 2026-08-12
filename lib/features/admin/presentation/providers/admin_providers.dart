import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/mock_admin_repository.dart';
import '../../domain/entities/dashboard_stats.dart';

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
