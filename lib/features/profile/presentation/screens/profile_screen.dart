import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/settings_controller.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../widgets/settings_tile.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final user = ref.watch(currentUserProvider);
    final settings = ref.watch(settingsControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final t = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(l.profileTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        children: [
          // Profile header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.heroGradient,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white.withValues(alpha: 0.25),
                  child: Text(
                    user?.initials ?? '👤',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.displayName ?? l.welcomeBack,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Text(user?.phoneNumber ?? '',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 14)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => context.push(AppRoutes.editProfile),
                  icon: const Icon(Icons.edit_outlined, color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _SectionLabel(l.settings),
          SettingsCard(
            children: [
              SettingsTile(
                icon: Icons.person_outline_rounded,
                title: l.personalInfo,
                onTap: () => context.push(AppRoutes.editProfile),
              ),
              SettingsTile(
                icon: Icons.language_rounded,
                title: l.language,
                trailing: Text(
                  settings.locale.languageCode == 'ar' ? l.arabic : l.english,
                  style: t.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                onTap: () => _showLanguageSheet(context, ref),
              ),
              SettingsTile(
                icon: Icons.dark_mode_outlined,
                title: l.darkMode,
                trailing: Switch.adaptive(
                  value: isDark,
                  activeColor: AppColors.primary,
                  onChanged: (v) => ref
                      .read(settingsControllerProvider.notifier)
                      .toggleDarkMode(v),
                ),
              ),
              SettingsTile(
                icon: Icons.notifications_outlined,
                title: l.notifications,
                trailing: Switch.adaptive(
                  value: settings.notificationsEnabled,
                  activeColor: AppColors.primary,
                  onChanged: (v) => ref
                      .read(settingsControllerProvider.notifier)
                      .setNotificationsEnabled(v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _SectionLabel(l.about),
          SettingsCard(
            children: [
              SettingsTile(
                icon: Icons.info_outline_rounded,
                title: l.about,
                onTap: () => context.push(AppRoutes.about),
              ),
              SettingsTile(
                icon: Icons.notifications_active_outlined,
                title: l.notificationsTitle,
                onTap: () => context.push(AppRoutes.notifications),
              ),
            ],
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => _confirmLogout(context, ref),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.danger,
              side: BorderSide(color: AppColors.danger.withValues(alpha: 0.4)),
            ),
            icon: const Icon(Icons.logout_rounded),
            label: Text(l.logout),
          ),
        ],
      ),
    );
  }

  void _showLanguageSheet(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final current = ref.read(settingsControllerProvider).locale.languageCode;
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(l.language,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800)),
            ),
            RadioListTile<String>(
              value: 'ar',
              groupValue: current,
              activeColor: AppColors.primary,
              title: Text(l.arabic),
              onChanged: (v) {
                ref
                    .read(settingsControllerProvider.notifier)
                    .setLocale(const Locale('ar'));
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              value: 'en',
              groupValue: current,
              activeColor: AppColors.primary,
              title: Text(l.english),
              onChanged: (v) {
                ref
                    .read(settingsControllerProvider.notifier)
                    .setLocale(const Locale('en'));
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l.logout),
        content: Text(l.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(profileControllerProvider.notifier).signOut();
            },
            child: Text(l.logout),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10, right: 4, left: 4),
        child: Text(text,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                )),
      );
}
