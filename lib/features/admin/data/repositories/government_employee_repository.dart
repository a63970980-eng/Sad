import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/supabase_config.dart';

class GovernmentEmployee {
  const GovernmentEmployee({
    required this.id,
    required this.profileId,
    required this.name,
    required this.phone,
    required this.jobTitle,
    required this.entityName,
    this.departmentName,
    required this.active,
  });

  final String id;
  final String profileId;
  final String name;
  final String phone;
  final String jobTitle;
  final String entityName;
  final String? departmentName;
  final bool active;

  factory GovernmentEmployee.fromJson(Map<String, dynamic> json) => GovernmentEmployee(
        id: json['id'].toString(),
        profileId: json['profile_id'].toString(),
        name: json['full_name']?.toString() ?? 'موظف حكومي',
        phone: json['phone']?.toString() ?? '',
        jobTitle: json['job_title_ar']?.toString() ?? '',
        entityName: json['entity_name_ar']?.toString() ?? 'جهة حكومية',
        departmentName: json['department_name_ar']?.toString(),
        active: json['active'] == true,
      );
}

class GovernmentEmployeeRepository {
  GovernmentEmployeeRepository({SupabaseClient? client})
      : _client = client ?? SupabaseConfig.client;

  final SupabaseClient _client;

  Future<List<GovernmentEmployee>> listActive() async {
    final response = await _client.rpc('get_government_employee_directory');
    if (response is! List) return const [];
    return response
        .whereType<Map>()
        .map((row) => GovernmentEmployee.fromJson(Map<String, dynamic>.from(row)))
        .toList();
  }

  Future<void> assignReport({
    required String reportId,
    required String employeeId,
    String? note,
  }) async {
    await _client.rpc('assign_report_to_employee', params: {
      'p_report_id': reportId,
      'p_employee_id': employeeId,
      'p_note': note,
    });
  }
}
