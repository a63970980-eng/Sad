import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  SupabaseConfig._();

  static const url = 'https://leicuwqyrsvieubszvyf.supabase.co';

  // This is a Supabase publishable client key. It is intentionally safe for
  // mobile/web distribution; database access is enforced by PostgreSQL RLS.
  static const publishableKey = 'sb_publishable_22BGykc4RT7x7Xe5TGQxvA_Yb_9mDYN';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: url,
      anonKey: publishableKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
