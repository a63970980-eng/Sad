import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.state, required this.child});

  final GoRouterState state;
  final Widget child;

  static const _tabs = [
    AppRoutes.home,
    AppRoutes.services,
    AppRoutes.reports,
    AppRoutes.map,
    AppRoutes.profile,
  ];

  int _indexFor(String location) {
    final i = _tabs.indexWhere((t) => location.startsWith(t));
    return i < 0 ? 0 : i;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final index = _indexFor(state.matchedLocation);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: (i) => context.go(_tabs[i]),
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home_rounded),
              label: l.navHome,
            ),
            NavigationDestination(
              icon: const Icon(Icons.grid_view_outlined),
              selectedIcon: const Icon(Icons.grid_view_rounded),
              label: l.navServices,
            ),
            NavigationDestination(
              icon: const Icon(Icons.report_outlined),
              selectedIcon: const Icon(Icons.report_rounded),
              label: l.navReports,
            ),
            NavigationDestination(
              icon: const Icon(Icons.map_outlined),
              selectedIcon: const Icon(Icons.map_rounded),
              label: l.navMap,
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline_rounded),
              selectedIcon: const Icon(Icons.person_rounded),
              label: l.navProfile,
            ),
          ],
        ),
      ),
      floatingActionButton: index == 2
          ? FloatingActionButton.extended(
              onPressed: () => context.push(AppRoutes.newReport),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: Text(l.newReport),
            )
          : null,
    );
  }
}
