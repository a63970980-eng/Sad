import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/supabase_config.dart';
import '../../domain/entities/report.dart';
import '../../domain/repositories/report_repository.dart';
import 'report_file_uploader.dart';

/// Production citizen report repository backed by Supabase Postgres + private Storage.
class SupabaseReportRepository implements ReportRepository {
  SupabaseReportRepository({SupabaseClient? client}) : _client = client ?? SupabaseConfig.client;

  final SupabaseClient _client;
  static const _bucket = 'report-attachments';

  @override
  Stream<List<Report>> watchUserReports(String userId) async* {
    yield await fetchUserReports(userId);
    final controller = StreamController<List<Report>>();
    var closed = false;
    Future<void> refresh() async {
      if (closed || controller.isClosed) return;
      try {
        controller.add(await fetchUserReports(userId));
      } catch (e, st) {
        if (!controller.isClosed) controller.addError(e, st);
      }
    }
    final channel = _client.channel('citizen-reports-$userId').onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'reports',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'citizen_id',
        value: userId,
      ),
      callback: (_) => unawaited(refresh()),
    ).subscribe();
    try {
      yield* controller.stream;
    } finally {
      closed = true;
      await _client.removeChannel(channel);
      await controller.close();
    }
  }

  @override
  Future<List<Report>> fetchUserReports(String userId) async {
    final rows = await _client
        .from('reports')
        .select('*, report_categories(code), report_timeline(status,note,created_at)')
        .eq('citizen_id', userId)
        .order('created_at', ascending: false);
    final reports = <Report>[];
    for (final raw in (rows as List)) {
      final row = Map<String, dynamic>.from(raw as Map);
      row['photos'] = await _signedAttachmentUrls(row['id'].toString());
      reports.add(_fromRow(row));
    }
    return reports;
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
    final row = await _client.from('reports').insert({
      'id': report.id,
      'citizen_id': user.id,
      'category_id': category?['id'],
      'title': report.title,
      'description': report.description,
      'status': _databaseStatus(report.status),
      'priority': 'normal',
      'latitude': report.latitude,
      'longitude': report.longitude,
      'address': report.address,
    }).select().single();
    final uploaded = <String>[];
    for (var i = 0; i < report.photos.length; i++) {
      final path = report.photos[i];
      if (path.startsWith('http')) {
        uploaded.add(path);
        continue;
      }
      final storagePath = '${user.id}/${report.id}/$i.jpg';
      await uploadLocalReportFile(_client, _bucket, path, storagePath);
      await _client.from('report_attachments').insert({
        'report_id': report.id,
        'storage_path': storagePath,
        'mime_type': 'image/jpeg',
      });
      uploaded.add(await _client.storage.from(_bucket).createSignedUrl(storagePath, 3600));
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
    final mapped = Map<String, dynamic>.from(row);
    mapped['photos'] = await _signedAttachmentUrls(id);
    return _fromRow(mapped);
  }

  Future<List<String>> _signedAttachmentUrls(String reportId) async {
    final rows = await _client
        .from('report_attachments')
        .select('storage_path')
        .eq('report_id', reportId)
        .order('created_at');
    final urls = <String>[];
    for (final raw in (rows as List)) {
      final path = (raw as Map)['storage_path']?.toString();
      if (path == null || path.isEmpty) continue;
      urls.add(await _client.storage.from(_bucket).createSignedUrl(path, 3600));
    }
    return urls;
  }

  String _databaseStatus(ReportStatus status) => switch (status) {
        ReportStatus.inProgress => 'in_progress',
        _ => status.id,
      };

  ReportStatus _appStatus(String? value) => switch (value) {
        'in_progress' || 'inProgress' => ReportStatus.inProgress,
        'reviewing' => ReportStatus.reviewing,
        'resolved' => ReportStatus.resolved,
        'rejected' => ReportStatus.rejected,
        _ => ReportStatus.submitted,
      };

  Report _fromRow(Map<String, dynamic> row) {
    final categoryRow = row['report_categories'];
    final categoryCode = categoryRow is Map<String, dynamic>
        ? categoryRow['code']?.toString()
        : null;
    final timeline = (row['report_timeline'] as List?) ?? const [];
    return Report(
      id: row['id'].toString(),
      referenceNo: row['reference_no']?.toString(),
      title: row['title']?.toString() ?? '',
      description: row['description']?.toString() ?? '',
      category: ReportCategoryX.fromId(categoryCode ?? 'publicSafety'),
      status: _appStatus(row['status']?.toString()),
      createdAt: DateTime.tryParse(row['created_at']?.toString() ?? '') ?? DateTime.now(),
      photos: (row['photos'] as List?)?.cast<String>() ?? const [],
      latitude: (row['latitude'] as num?)?.toDouble(),
      longitude: (row['longitude'] as num?)?.toDouble(),
      address: row['address']?.toString(),
      userId: row['citizen_id']?.toString(),
      timeline: timeline.map((item) {
        final map = Map<String, dynamic>.from(item as Map);
        return TimelineEntry(
          status: _appStatus(map['status']?.toString()),
          date: DateTime.tryParse(map['created_at']?.toString() ?? '') ?? DateTime.now(),
          note: map['note']?.toString(),
        );
      }).toList(),
    );
  }
}
