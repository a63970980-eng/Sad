import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/repositories/mock_report_repository.dart';
import '../../data/repositories/supabase_report_repository.dart';
import '../../domain/entities/report.dart';
import '../../domain/repositories/report_repository.dart';

final _mockRepoSingleton = MockReportRepository();

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  final user = SupabaseConfig.client.auth.currentUser;
  if (AppConfig.supabaseDataEnabled && user != null) return SupabaseReportRepository();
  if (AppConfig.demoMode) return _mockRepoSingleton;
  return SupabaseReportRepository();
});

final userReportsProvider = StreamProvider<List<Report>>((ref) {
  final repo = ref.watch(reportRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  if (user == null && !AppConfig.demoMode) return Stream.value(const []);
  return repo.watchUserReports(user?.uid ?? 'me');
});

final reportByIdProvider = FutureProvider.family<Report?, String>((ref, id) async {
  final reports = ref.watch(userReportsProvider).valueOrNull;
  if (reports != null) {
    for (final report in reports) {
      if (report.id == id) return report;
    }
  }
  return ref.watch(reportRepositoryProvider).getById(id);
});

class SubmitReportController extends AsyncNotifier<Report?> {
  @override
  Future<Report?> build() async => null;

  Future<Report?> submit({
    required String title,
    required String description,
    required ReportCategory category,
    required List<String> photos,
    bool isAnonymous = false,
    double? latitude,
    double? longitude,
    String? address,
  }) async {
    state = const AsyncValue.loading();
    final user = ref.read(currentUserProvider);
    if (user == null && !AppConfig.demoMode) {
      state = AsyncValue.error(
        StateError('يجب تسجيل الدخول قبل إرسال البلاغ.'),
        StackTrace.current,
      );
      return null;
    }

    final now = DateTime.now();
    final report = Report(
      id: const Uuid().v4(),
      title: title,
      description: description,
      category: category,
      status: ReportStatus.submitted,
      createdAt: now,
      photos: photos,
      latitude: latitude,
      longitude: longitude,
      address: address,
      userId: user?.uid ?? 'me',
      isAnonymous: isAnonymous,
      timeline: [TimelineEntry(status: ReportStatus.submitted, date: now)],
    );
    final result = await AsyncValue.guard(
      () => ref.read(reportRepositoryProvider).submitReport(report),
    );
    state = result;
    return result.valueOrNull;
  }
}

final submitReportControllerProvider = AsyncNotifierProvider<SubmitReportController, Report?>(
  SubmitReportController.new,
);
