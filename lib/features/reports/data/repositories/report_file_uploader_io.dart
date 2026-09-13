import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> uploadLocalReportFileImpl(
  SupabaseClient client,
  String bucket,
  String localPath,
  String storagePath,
) async {
  await client.storage.from(bucket).upload(
        storagePath,
        File(localPath),
        fileOptions: const FileOptions(contentType: 'image/jpeg'),
      );
}
