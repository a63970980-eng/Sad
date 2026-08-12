import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'core/config/firebase_options.dart';
import 'core/storage/prefs_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Firebase. If credentials are still placeholders (or init fails),
  // fall back to DEMO mode so the app remains fully usable.
  if (!DefaultFirebaseOptions.isPlaceholder) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      AppConfig.demoMode = false;
    } catch (e) {
      debugPrint('Firebase init failed, running in demo mode: $e');
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
