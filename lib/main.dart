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

  // Initialize Supabase first. It is the target production backend for the
  // relational government workflow. RLS remains the source of truth for
  // authorization; no service-role key is ever shipped in the app.
  try {
    await SupabaseConfig.initialize();
    AppConfig.supabaseReady = true;
  } catch (e) {
    debugPrint('Supabase init failed: $e');
    AppConfig.supabaseReady = false;
  }

  // Keep Firebase temporarily for features that have not yet been migrated.
  // It will be removed only after authentication, notifications, storage and
  // all feature repositories are migrated and verified on the new backend.
  if (!DefaultFirebaseOptions.isPlaceholder) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      AppConfig.demoMode = false;
    } catch (e) {
      debugPrint('Firebase init failed: $e');
      AppConfig.demoMode = true;
    }
  } else {
    AppConfig.demoMode = true;
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
