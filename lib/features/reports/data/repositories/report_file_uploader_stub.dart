import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> uploadLocalReportFileImpl(
  SupabaseClient client,
  String bucket,
  String localPath,
  String storagePath,
) async {
  throw UnsupportedError(
    'رفع ملف محلي عبر مسار نصي غير متاح على الويب. يجب تمرير bytes من XFile.',
  );
}
