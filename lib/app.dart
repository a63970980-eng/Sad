import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/settings_controller.dart';
import 'l10n/app_localizations.dart';

class AdenDigitalApp extends ConsumerWidget {
  const AdenDigitalApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final router = ref.watch(goRouterProvider);
    final localeCode = settings.locale.languageCode;

    return MaterialApp.router(
      title: 'Aden Digital',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      themeMode: settings.themeMode,
      theme: AppTheme.light(localeCode),
      darkTheme: AppTheme.dark(localeCode),
      locale: settings.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        // Lock text scaling to keep the premium layout consistent.
        final mq = MediaQuery.of(context);
        return MediaQuery(
          data: mq.copyWith(
            textScaler: mq.textScaler.clamp(
              minScaleFactor: 0.9,
              maxScaleFactor: 1.2,
            ),
          ),
          child: child!,
        );
      },
    );
  }
}
