import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'core/config/firebase_options.dart';
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

  // Firebase remains available for legacy messaging/storage integrations when
  // real platform options are supplied, but it no longer controls whether the
  // app enters demo mode. Production authentication is governed explicitly by
  // AppConfig and Supabase.
  if (!DefaultFirebaseOptions.isPlaceholder) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      debugPrint('Firebase init failed: $e');
    }
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
