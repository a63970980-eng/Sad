import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class SettingsCard extends StatelessWidget {
  const SettingsCard({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outline),
      ),
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1)
              Divider(
                  height: 1,
                  indent: 60,
                  color: scheme.outline.withValues(alpha: 0.6)),
          ],
        ],
      ),
    );
  }
}

class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(title,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(fontWeight: FontWeight.w600)),
      trailing: trailing ??
          (onTap != null
              ? Icon(Icons.chevron_right_rounded,
                  color: Theme.of(context).colorScheme.onSurfaceVariant)
              : null),
    );
  }
}
