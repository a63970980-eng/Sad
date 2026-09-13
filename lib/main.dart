import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'core/config/supabase_config.dart';
import 'core/storage/prefs_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  try {
    await SupabaseConfig.initialize();
    AppConfig.supabaseReady = true;
    AppConfig.supabaseDataEnabled = true;
  } catch (e) {
    debugPrint('Supabase init failed: $e');
    AppConfig.supabaseReady = false;
    AppConfig.supabaseDataEnabled = false;
  }

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        prefsServiceProvider.overrideWithValue(PrefsService(prefs)),
      ],
      child: const AdenDigitalApp(),
    ),
  );
}
