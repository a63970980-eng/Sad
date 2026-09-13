import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/supabase_config.dart';

/// Citizen service catalog and request access through Supabase.
class SupabaseServiceRepository {
  SupabaseServiceRepository({SupabaseClient? client}) : _client = client ?? SupabaseConfig.client;
  final SupabaseClient _client;

  Future<List<Map<String, dynamic>>> fetchServices() async {
    final rows = await _client.from('services').select('id,code,name_ar,name_en,description_ar,entity_id,active,sort_order').eq('active', true).order('sort_order');
    return List<Map<String, dynamic>>.from(rows);
  }

  Future<Map<String, dynamic>> submitRequest({required String serviceId, required Map<String, dynamic> formData, String? notes}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw const AuthException('يجب تسجيل الدخول أولاً.');
    final row = await _client.from('service_requests').insert({'citizen_id': userId, 'service_id': serviceId, 'form_data': formData, 'notes': notes}).select('id,reference_no,status,service_id,created_at,updated_at').single();
    return Map<String, dynamic>.from(row);
  }

  Stream<List<Map<String, dynamic>>> watchMyRequests() async* {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) { yield const []; return; }
    Future<List<Map<String, dynamic>>> load() async {
      final rows = await _client.from('service_requests').select('id,reference_no,status,service_id,form_data,notes,created_at,updated_at').eq('citizen_id', userId).order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(rows);
    }
    yield await load();
    final controller = StreamController<List<Map<String, dynamic>>>();
    final channel = _client.channel('service-requests-$userId').onPostgresChanges(
      event: PostgresChangeEvent.all, schema: 'public', table: 'service_requests',
      filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'citizen_id', value: userId),
      callback: (_) async { try { controller.add(await load()); } catch (e, st) { if (!controller.isClosed) controller.addError(e, st); } },
    ).subscribe();
    try { yield* controller.stream; } finally { await _client.removeChannel(channel); await controller.close(); }
  }
}
