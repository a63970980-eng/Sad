import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/map/presentation/screens/map_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/about_screen.dart';
import '../../features/reports/presentation/screens/reports_screen.dart';
import '../../features/reports/presentation/screens/new_report_screen.dart';
import '../../features/reports/presentation/screens/report_detail_screen.dart';
import '../../features/services/presentation/screens/services_screen.dart';
import '../../features/services/presentation/screens/service_detail_screen.dart';
import '../../features/services/presentation/screens/service_form_screen.dart';
import '../../features/services/presentation/screens/track_request_screen.dart';
import '../../features/shell/presentation/app_shell.dart';

class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const otp = '/otp';
  static const home = '/home';
  static const services = '/services';
  static const reports = '/reports';
  static const map = '/map';
  static const profile = '/profile';
  static const notifications = '/notifications';
  static const newReport = '/reports/new';
  static const editProfile = '/profile/edit';
  static const about = '/profile/about';
  static const adminDashboard = '/admin/dashboard';
}

/// Re-runs router redirect whenever auth changes.
class _AuthListenable extends ChangeNotifier {
  _AuthListenable(this.ref) {
    ref.listen(authStateProvider, (_, __) => notifyListeners());
  }
  final Ref ref;
}

final goRouterProvider = Provider<GoRouter>((ref) {
  final authListenable = _AuthListenable(ref);
  final rootKey = GlobalKey<NavigatorState>();
  final shellKey = GlobalKey<NavigatorState>();

  return GoRouter(
    navigatorKey: rootKey,
    initialLocation: AppRoutes.splash,
    refreshListenable: authListenable,
    redirect: (context, state) {
      final auth = ref.read(authStateProvider);
      final loc = state.matchedLocation;

      // While auth state is resolving, stay on splash.
      if (auth.isLoading) {
        return loc == AppRoutes.splash ? null : AppRoutes.splash;
      }

      final loggedIn = auth.valueOrNull != null;
      final onAuthFlow = loc == AppRoutes.login ||
          loc == AppRoutes.otp ||
          loc == AppRoutes.splash;

      if (!loggedIn && !onAuthFlow) return AppRoutes.login;
      if (loggedIn && onAuthFlow) return AppRoutes.home;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.otp,
        builder: (_, __) => const OtpScreen(),
      ),
      // Main shell with bottom navigation.
      ShellRoute(
        navigatorKey: shellKey,
        builder: (context, state, child) => AppShell(state: state, child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            pageBuilder: (_, __) => const NoTransitionPage(child: HomeScreen()),
          ),
          GoRoute(
            path: AppRoutes.services,
            pageBuilder: (_, __) =>
                const NoTransitionPage(child: ServicesScreen()),
          ),
          GoRoute(
            path: AppRoutes.reports,
            pageBuilder: (_, __) =>
                const NoTransitionPage(child: ReportsScreen()),
          ),
          GoRoute(
            path: AppRoutes.map,
            pageBuilder: (_, __) => const NoTransitionPage(child: MapScreen()),
          ),
          GoRoute(
            path: AppRoutes.profile,
            pageBuilder: (_, __) =>
                const NoTransitionPage(child: ProfileScreen()),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.notifications,
        parentNavigatorKey: rootKey,
        builder: (_, __) => const NotificationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.newReport,
        parentNavigatorKey: rootKey,
        builder: (_, __) => const NewReportScreen(),
      ),
      GoRoute(
        path: '/reports/:id',
        parentNavigatorKey: rootKey,
        builder: (_, state) =>
            ReportDetailScreen(reportId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/services/:id',
        parentNavigatorKey: rootKey,
        builder: (_, state) =>
            ServiceDetailScreen(serviceId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/services/:id/form/:action',
        parentNavigatorKey: rootKey,
        builder: (_, state) => ServiceFormScreen(
          serviceId: state.pathParameters['id']!,
          actionId: state.pathParameters['action']!,
        ),
      ),
      GoRoute(
        path: '/services/:id/track/:action',
        parentNavigatorKey: rootKey,
        builder: (_, state) => TrackRequestScreen(
          serviceId: state.pathParameters['id']!,
          actionId: state.pathParameters['action']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.editProfile,
        parentNavigatorKey: rootKey,
        builder: (_, __) => const EditProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.about,
        parentNavigatorKey: rootKey,
        builder: (_, __) => const AboutScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminDashboard,
        parentNavigatorKey: rootKey,
        builder: (_, __) => const AdminDashboardScreen(),
      ),
    ],
  );
});
