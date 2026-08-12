import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/config/app_config.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/repositories/firebase_report_repository.dart';
import '../../data/repositories/mock_report_repository.dart';
import '../../domain/entities/report.dart';
import '../../domain/repositories/report_repository.dart';

final _mockRepoSingleton = MockReportRepository();

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  if (AppConfig.demoMode) return _mockRepoSingleton;
  return FirebaseReportRepository();
});

/// Live list of the current user's reports.
final userReportsProvider = StreamProvider<List<Report>>((ref) {
  final repo = ref.watch(reportRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  final uid = user?.uid ?? 'me';
  return repo.watchUserReports(uid);
});

final reportByIdProvider =
    FutureProvider.family<Report?, String>((ref, id) async {
  // Prefer the already-loaded list to stay reactive.
  final reports = ref.watch(userReportsProvider).valueOrNull;
  if (reports != null) {
    for (final r in reports) {
      if (r.id == id) return r;
    }
  }
  return ref.watch(reportRepositoryProvider).getById(id);
});

/// Handles submitting a new report.
class SubmitReportController extends AsyncNotifier<Report?> {
  @override
  Future<Report?> build() async => null;

  Future<Report?> submit({
    required String title,
    required String description,
    required ReportCategory category,
    required List<String> photos,
    double? latitude,
    double? longitude,
    String? address,
  }) async {
    state = const AsyncValue.loading();
    final repo = ref.read(reportRepositoryProvider);
    final user = ref.read(currentUserProvider);
    final now = DateTime.now();
    final id = 'RPT-${const Uuid().v4().substring(0, 6).toUpperCase()}';

    final report = Report(
      id: id,
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
      timeline: [TimelineEntry(status: ReportStatus.submitted, date: now)],
    );

    final result = await AsyncValue.guard(() => repo.submitReport(report));
    state = result;
    return result.valueOrNull;
  }
}

final submitReportControllerProvider =
    AsyncNotifierProvider<SubmitReportController, Report?>(
        SubmitReportController.new);
