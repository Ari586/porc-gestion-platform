import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../core/constants/app_spacing.dart';
import '../core/providers/session_provider.dart';
import '../theme/app_colors.dart';

class _NavItem {
  final String label;
  final IconData icon;
  final String path;
  const _NavItem(this.label, this.icon, this.path);
}

const _sidebarItems = [
  _NavItem('Dashboard', LucideIcons.layoutDashboard, '/dashboard'),
  _NavItem('Actualités', LucideIcons.newspaper, '/news'),
  _NavItem('Messenger', LucideIcons.messageCircle, '/messenger'),
  _NavItem('Élevage', LucideIcons.warehouse, '/breeding'),
  _NavItem('Inséminations', LucideIcons.syringe, '/inseminations'),
  _NavItem('Verrats', LucideIcons.beef, '/boars'),
  _NavItem('Truies', LucideIcons.heart, '/sows'),
  _NavItem('Pédigrée', LucideIcons.gitBranch, '/pedigree'),
  _NavItem('Santé', LucideIcons.stethoscope, '/health'),
  _NavItem('Commercial', LucideIcons.shoppingCart, '/commercial'),
  _NavItem('Administration', LucideIcons.shield, '/admin'),
  _NavItem('Paramètres', LucideIcons.settings, '/settings'),
];

const _bottomNavItems = [
  _NavItem('Accueil', LucideIcons.layoutDashboard, '/dashboard'),
  _NavItem('Élevage', LucideIcons.warehouse, '/breeding'),
  _NavItem('IA', LucideIcons.syringe, '/inseminations'),
  _NavItem('Santé', LucideIcons.stethoscope, '/health'),
  _NavItem('Plus', LucideIcons.menu, ''),
];

class AppShell extends ConsumerWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  int _currentIndex(String location) {
    for (var i = 0; i < _bottomNavItems.length - 1; i++) {
      if (location.startsWith(_bottomNavItems[i].path)) return i;
    }
    return 4;
  }

  int _sidebarIndex(String location) {
    for (var i = 0; i < _sidebarItems.length; i++) {
      if (location.startsWith(_sidebarItems[i].path)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 980;
    final location = GoRouterState.of(context).uri.toString();
    final session = ref.watch(sessionProvider);

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            _DesktopSidebar(
              currentIndex: _sidebarIndex(location),
              userName: session?.name ?? '',
              userRole: session?.role ?? '',
              userAvatar: session?.avatar ?? '?',
              onLogout: () => ref.read(sessionProvider.notifier).logout(),
            ),
            Expanded(child: child),
          ],
        ),
      );
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: _MobileBottomNav(
        currentIndex: _currentIndex(location),
        onMoreTapped: () => _showMoreSheet(context),
      ),
    );
  }

  void _showMoreSheet(BuildContext context) {
    final moreItems = _sidebarItems.where((item) {
      return !_bottomNavItems.any((bn) => bn.path == item.path);
    }).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.s16),
              child: Text(
                'Plus de modules',
                style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: moreItems
                    .map((item) => ListTile(
                          leading:
                              Icon(item.icon, color: AppColors.primary),
                          title: Text(item.label),
                          onTap: () {
                            Navigator.of(ctx).pop();
                            context.go(item.path);
                          },
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: AppSpacing.s8),
          ],
        ),
      ),
    );
  }
}

class _MobileBottomNav extends StatelessWidget {
  final int currentIndex;
  final VoidCallback onMoreTapped;

  const _MobileBottomNav({
    required this.currentIndex,
    required this.onMoreTapped,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.primaryPale,
      onDestinationSelected: (index) {
        if (index == _bottomNavItems.length - 1) {
          onMoreTapped();
          return;
        }
        context.go(_bottomNavItems[index].path);
      },
      destinations: _bottomNavItems
          .map((item) => NavigationDestination(
                icon: Icon(item.icon),
                selectedIcon:
                    Icon(item.icon, color: AppColors.primaryDark),
                label: item.label,
              ))
          .toList(),
    );
  }
}

class _DesktopSidebar extends StatelessWidget {
  final int currentIndex;
  final String userName;
  final String userRole;
  final String userAvatar;
  final VoidCallback onLogout;

  const _DesktopSidebar({
    required this.currentIndex,
    required this.userName,
    required this.userRole,
    required this.userAvatar,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.sidebarDark, AppColors.sidebarMedium],
        ),
        border: Border(
          right: BorderSide(color: AppColors.border.withAlpha(80)),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.s24),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppSpacing.s18),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    LucideIcons.piggyBank,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.s10),
                Text(
                  'PigIA',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.sidebarTextActive,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.s24),
          Expanded(
            child: ListView.builder(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.s10),
              itemCount: _sidebarItems.length,
              itemBuilder: (context, index) {
                final item = _sidebarItems[index];
                final isActive = index == currentIndex;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.sidebarActiveBg.withAlpha(100)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: isActive
                          ? Border.all(
                              color: AppColors.primary.withAlpha(60))
                          : null,
                    ),
                    child: ListTile(
                      dense: true,
                      leading: Icon(
                        item.icon,
                        size: 18,
                        color: isActive
                            ? AppColors.sidebarTextActive
                            : AppColors.sidebarText,
                      ),
                      title: Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isActive
                              ? FontWeight.w800
                              : FontWeight.w600,
                          color: isActive
                              ? AppColors.sidebarTextActive
                              : AppColors.sidebarText,
                        ),
                      ),
                      onTap: () => context.go(item.path),
                    ),
                  ),
                );
              },
            ),
          ),
          // User footer
          Padding(
            padding: const EdgeInsets.all(AppSpacing.s12),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.s10),
              decoration: BoxDecoration(
                color: AppColors.sidebarUserCardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.sidebarUserCardBorder),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      userAvatar,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: AppColors.sidebarTextActive,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          userRole,
                          style: TextStyle(
                            fontSize: 11,
                            color:
                                AppColors.sidebarText.withAlpha(180),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      LucideIcons.logOut,
                      size: 16,
                      color: AppColors.sidebarText,
                    ),
                    tooltip: 'Déconnexion',
                    onPressed: onLogout,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ),
          // Version
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s10),
            child: Text(
              'PigIA v1.0',
              style: TextStyle(
                fontSize: 10,
                color: AppColors.sidebarTextMuted.withAlpha(150),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
