import 'dart:io' show File;

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/supabase_config.dart';
import '../../domain/entities/report.dart';
import '../../domain/repositories/report_repository.dart';

/// Production report repository backed by Supabase Postgres + Storage.
class SupabaseReportRepository implements ReportRepository {
  SupabaseReportRepository({SupabaseClient? client})
      : _client = client ?? SupabaseConfig.client;

  final SupabaseClient _client;
  static const _bucket = 'report-attachments';

  @override
  Stream<List<Report>> watchUserReports(String userId) async* {
    // Postgres Changes is enabled for the table at the infrastructure layer;
    // reload after every change so ordering and related data stay consistent.
    yield await fetchUserReports(userId);
    final channel = _client
        .channel('citizen-reports-$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'reports',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'citizen_id',
            value: userId,
          ),
          callback: (_) async {},
        )
        .subscribe();

    try {
      await for (final _ in Stream.periodic(const Duration(seconds: 1))) {
        // The periodic refresh is deliberately bounded to a small citizen
        // dataset and keeps this adapter compatible across supabase_flutter
        // realtime callback versions. RLS remains the access boundary.
        yield await fetchUserReports(userId);
      }
    } finally {
      await _client.removeChannel(channel);
    }
  }

  @override
  Future<List<Report>> fetchUserReports(String userId) async {
    final rows = await _client
        .from('reports')
        .select('*, report_categories(code), report_timeline(status,note,created_at)')
        .eq('citizen_id', userId)
        .order('created_at', ascending: false);
    return (rows as List)
        .map((row) => _fromRow(Map<String, dynamic>.from(row as Map)))
        .toList();
  }

  @override
  Future<Report> submitReport(Report report) async {
    final user = _client.auth.currentUser;
    if (user == null || user.id != report.userId) {
      throw const AuthException('يجب تسجيل الدخول قبل إرسال البلاغ.');
    }

    final category = await _client
        .from('report_categories')
        .select('id')
        .eq('code', report.category.id)
        .maybeSingle();

    final row = await _client
        .from('reports')
        .insert({
          'id': report.id,
          'citizen_id': user.id,
          'category_id': category?['id'],
          'title': report.title,
          'description': report.description,
          'status': report.status.id,
          'priority': 'normal',
          'latitude': report.latitude,
          'longitude': report.longitude,
          'address': report.address,
        })
        .select()
        .single();

    final uploaded = <String>[];
    for (var i = 0; i < report.photos.length; i++) {
      final path = report.photos[i];
      if (path.startsWith('http')) {
        uploaded.add(path);
        continue;
      }

      final storagePath = '${user.id}/${report.id}/$i.jpg';
      if (kIsWeb) {
        // The current report composer supplies local paths on mobile. Web
        // upload should pass bytes from XFile directly in a future adapter.
        continue;
      }
      await _client.storage.from(_bucket).upload(
            storagePath,
            File(path),
            fileOptions: const FileOptions(contentType: 'image/jpeg'),
          );
      await _client.from('report_attachments').insert({
        'report_id': report.id,
        'storage_path': storagePath,
        'mime_type': 'image/jpeg',
      });
      uploaded.add(_client.storage.from(_bucket).getPublicUrl(storagePath));
    }

    return _fromRow({...Map<String, dynamic>.from(row), 'photos': uploaded});
  }

  @override
  Future<Report?> getById(String id) async {
    final row = await _client
        .from('reports')
        .select('*, report_categories(code), report_timeline(status,note,created_at)')
        .eq('id', id)
        .maybeSingle();
    if (row == null) return null;
    return _fromRow(Map<String, dynamic>.from(row));
  }

  Report _fromRow(Map<String, dynamic> row) {
    final categoryRow = row['report_categories'];
    final categoryCode = categoryRow is Map<String, dynamic>
        ? categoryRow['code']?.toString()
        : null;
    final timeline = (row['report_timeline'] as List?) ?? const [];

    return Report(
      id: row['id'].toString(),
      title: row['title']?.toString() ?? '',
      description: row['description']?.toString() ?? '',
      category: ReportCategoryX.fromId(categoryCode ?? 'publicSafety'),
      status: ReportStatusX.fromId(row['status']?.toString() ?? 'submitted'),
      createdAt: DateTime.tryParse(row['created_at']?.toString() ?? '') ?? DateTime.now(),
      photos: (row['photos'] as List?)?.cast<String>() ?? const [],
      latitude: (row['latitude'] as num?)?.toDouble(),
      longitude: (row['longitude'] as num?)?.toDouble(),
      address: row['address']?.toString(),
      userId: row['citizen_id']?.toString(),
      timeline: timeline.map((item) {
        final map = Map<String, dynamic>.from(item as Map);
        return TimelineEntry(
          status: ReportStatusX.fromId(map['status']?.toString() ?? 'submitted'),
          date: DateTime.tryParse(map['created_at']?.toString() ?? '') ?? DateTime.now(),
          note: map['note']?.toString(),
        );
      }).toList(),
    );
  }
}
