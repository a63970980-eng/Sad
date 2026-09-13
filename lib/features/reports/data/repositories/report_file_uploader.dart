import 'report_file_uploader_stub.dart'
    if (dart.library.io) 'report_file_uploader_io.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> uploadLocalReportFile(
  SupabaseClient client,
  String bucket,
  String localPath,
  String storagePath,
) => uploadLocalReportFileImpl(client, bucket, localPath, storagePath);
