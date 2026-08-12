import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/widgets/brand_logo.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l.about)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        children: [
          const Center(child: BrandLogo(size: 96)),
          const SizedBox(height: 20),
          Center(
            child: Text(l.appName,
                style: t.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text('${l.appVersion} 1.0.0',
                style:
                    t.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(l.aboutDesc,
                textAlign: TextAlign.center,
                style: t.bodyLarge?.copyWith(
                    color: AppColors.primaryDark, height: 1.6)),
          ),
          const SizedBox(height: 28),
          _AboutRow(icon: Icons.account_balance_rounded, label: l.appName),
          _AboutRow(icon: Icons.public_rounded, label: 'Aden, Yemen'),
          _AboutRow(
              icon: Icons.shield_outlined,
              label: 'Secure • Material 3 • RTL'),
        ],
      ),
    );
  }
}

class _AboutRow extends StatelessWidget {
  const _AboutRow({required this.icon, required this.label});
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Text(label, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
