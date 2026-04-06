import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/models/user_profile.dart';
import '../core/providers/session_provider.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/dashboard/presentation/pages/dashboard_page.dart';
import '../features/boars/presentation/pages/boar_list_page.dart';
import '../features/boars/presentation/pages/semen_quality_page.dart';
import '../features/sows/presentation/pages/sow_list_page.dart';
import '../features/insemination/presentation/pages/insemination_page.dart';
import '../features/health/presentation/pages/health_page.dart';
import '../features/breeding/presentation/pages/breeding_page.dart';
import '../features/commercial/presentation/pages/commercial_page.dart';
import '../features/pedigree/presentation/pages/pedigree_page.dart';
import '../features/messenger/presentation/pages/messenger_page.dart';
import '../features/news/presentation/pages/news_page.dart';
import '../features/admin/presentation/pages/admin_page.dart';
import '../features/piglets/presentation/pages/piglet_care_page.dart';
import '../features/settings/presentation/pages/settings_page.dart';
import 'app_shell.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final shellNavigatorKey = GlobalKey<NavigatorState>();

class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(Ref ref) {
    ref.listen<UserProfile?>(sessionProvider, (_, __) => notifyListeners());
  }
}

final _routerNotifierProvider = ChangeNotifierProvider<_RouterNotifier>(
  (ref) => _RouterNotifier(ref),
);

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(_routerNotifierProvider);
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/login',
    refreshListenable: notifier,
    redirect: (context, state) {
      final session = ref.read(sessionProvider);
      final onLogin = state.matchedLocation == '/login';
      if (session == null && !onLogin) return '/login';
      if (session != null && onLogin) return '/dashboard';
      if (session != null && state.matchedLocation == '/admin' && !session.role.toLowerCase().contains('responsable')) {
        return '/dashboard';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: LoginPage()),
      ),
      ShellRoute(
        navigatorKey: shellNavigatorKey,
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: DashboardPage()),
          ),
          GoRoute(
            path: '/boars',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: BoarListPage()),
          ),
          GoRoute(
            path: '/semen-quality',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: SemenQualityPage()),
          ),
          GoRoute(
            path: '/sows',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: SowListPage()),
          ),
          GoRoute(
            path: '/inseminations',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: InseminationPage()),
          ),
          GoRoute(
            path: '/health',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: HealthPage()),
          ),
          GoRoute(
            path: '/breeding',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: BreedingPage()),
          ),
          GoRoute(
            path: '/commercial',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: CommercialPage()),
          ),
          GoRoute(
            path: '/pedigree',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: PedigreePage()),
          ),
          GoRoute(
            path: '/messenger',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: MessengerPage()),
          ),
          GoRoute(
            path: '/news',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: NewsPage()),
          ),
          GoRoute(
            path: '/piglets',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: PigletCarePage()),
          ),
          GoRoute(
            path: '/admin',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: AdminPage()),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: SettingsPage()),
          ),
        ],
      ),
    ],
  );
});
