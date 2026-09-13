import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/supabase_config.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/repositories/admin_repository.dart';

/// Trusted government dashboard operations exposed through guarded Supabase RPCs.
class SupabaseAdminRepository implements AdminRepository {
  SupabaseAdminRepository({SupabaseClient? client})
      : _client = client ?? SupabaseConfig.client;

  final SupabaseClient _client;

  Future<Map<String, dynamic>> _dashboard() async {
    final response = await _client.rpc('get_admin_dashboard');
    if (response is! Map) {
      throw const PostgrestException(message: 'استجابة لوحة التحكم غير صالحة.');
    }
    return Map<String, dynamic>.from(response);
  }

  int _int(Map<String, dynamic> data, String key) =>
      (data[key] as num?)?.toInt() ?? 0;

  @override
  Future<DashboardStats> getDashboardStats() async {
    final data = await _dashboard();
    return DashboardStats(
      totalReports: _int(data, 'totalReports'),
      newReports: _int(data, 'newReports'),
      inProgressReports: _int(data, 'inProgressReports'),
      resolvedReports: _int(data, 'resolvedReports'),
      rejectedReports: _int(data, 'rejectedReports'),
      totalUsers: _int(data, 'totalUsers'),
      activeUsers: _int(data, 'activeUsers'),
      totalServices: _int(data, 'totalServices'),
      totalRequests: _int(data, 'totalRequests'),
      pendingRequests: _int(data, 'pendingRequests'),
      completedRequests: _int(data, 'completedRequests'),
    );
  }

  @override
  Future<List<RegionalReportStats>> getRegionalStats() async {
    final data = await _dashboard();
    final raw = data['regionalStats'];
    if (raw is! List) return const [];
    return raw.whereType<Map>().map((item) {
      final row = Map<String, dynamic>.from(item);
      return RegionalReportStats(
        region: row['region']?.toString() ?? 'غير محدد',
        total: _int(row, 'total'),
        resolved: _int(row, 'resolved'),
        pending: _int(row, 'pending'),
      );
    }).toList();
  }

  String _databaseStatus(String value) => switch (value) {
        'inProgress' => 'in_progress',
        _ => value,
      };

  @override
  Future<void> updateReportStatus(String reportId, String newStatus) async {
    await _client.rpc('update_report_status', params: {
      'p_report_id': reportId,
      'p_status': _databaseStatus(newStatus),
    });
  }

  @override
  Future<List<Map<String, dynamic>>> getRecentActivity(int limit) async {
    final data = await _dashboard();
    final raw = data['recentActivity'];
    if (raw is! List) return const [];
    return raw.whereType<Map>().take(limit).map((item) {
      final row = Map<String, dynamic>.from(item);
      return {
        ...row,
        'time': DateTime.tryParse(row['created_at']?.toString() ?? '') ??
            DateTime.now(),
      };
    }).toList();
  }
}
