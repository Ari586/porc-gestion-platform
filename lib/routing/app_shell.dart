import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../core/constants/app_spacing.dart';
import '../core/providers/session_provider.dart';
import '../core/providers/language_provider.dart';
import '../theme/app_colors.dart';

class _NavItem {
  final String label;
  final IconData icon;
  final String path;
  const _NavItem(this.label, this.icon, this.path);
}
List<_NavItem> _getSidebarItems(bool isMg) {
  return [
    _NavItem(isMg ? 'Topy maso' : 'Dashboard', LucideIcons.layoutDashboard, '/dashboard'),
    _NavItem(isMg ? 'Vaovao' : 'Actualités', LucideIcons.newspaper, '/news'),
    _NavItem('Messenger', LucideIcons.messageCircle, '/messenger'),
    _NavItem(isMg ? 'Fiompiana' : 'Élevage', LucideIcons.warehouse, '/breeding'),
    _NavItem(isMg ? 'Insémination' : 'Inséminations', LucideIcons.syringe, '/inseminations'),
    _NavItem(isMg ? 'Kisoa lahy' : 'Verrats', LucideIcons.beef, '/boars'),
    _NavItem(isMg ? 'Kalitaon\'ny tsirinaina' : 'Qualité semence', LucideIcons.testTube, '/semen-quality'),
    _NavItem(isMg ? 'Kisoa vavy' : 'Truies', LucideIcons.heart, '/sows'),
    _NavItem('Pédigrée', LucideIcons.gitBranch, '/pedigree'),
    _NavItem(isMg ? 'Fahasalamana' : 'Santé', LucideIcons.stethoscope, '/health'),
    _NavItem(isMg ? 'Zanakisoa' : 'Porcelets', LucideIcons.baby, '/piglets'),
    _NavItem('Commercial', LucideIcons.shoppingCart, '/commercial'),
    _NavItem('Administration', LucideIcons.shield, '/admin'),
    _NavItem(isMg ? 'Fikirakirana' : 'Paramètres', LucideIcons.settings, '/settings'),
  ];
}
List<_NavItem> _getBottomNavItems(bool isMg) => [
  _NavItem('Accueil', LucideIcons.layoutDashboard, '/dashboard'),
  _NavItem(isMg ? 'Fiompiana' : 'Élevage', LucideIcons.warehouse, '/breeding'),
  _NavItem(isMg ? 'Insémination' : 'Inséminations', LucideIcons.syringe, '/inseminations'),
  _NavItem(isMg ? 'Kisoa lahy' : 'Verrats', LucideIcons.beef, '/boars'),
  _NavItem('Plus', LucideIcons.menu, ''),
];

class AppShell extends ConsumerWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  int _currentIndex(String location, bool isMg) {
    var items = _getBottomNavItems(isMg);
    for (var i = 0; i < items.length - 1; i++) {
      if (location.startsWith(items[i].path)) return i;
    }
    return 4;
  }

  int _sidebarIndex(String location, String userRole, bool isMg) {
    var navigableItems = _getSidebarItems(isMg).where((i) => i.path != '/admin' || userRole.toLowerCase().contains('responsable')).toList();
    for (var i = 0; i < navigableItems.length; i++) {
      if (location.startsWith(navigableItems[i].path)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 980;
    final location = GoRouterState.of(context).uri.toString();
    final session = ref.watch(sessionProvider);
    final isMg = ref.watch(languageProvider) == 'Malagasy';

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            _DesktopSidebar(
              currentIndex: _sidebarIndex(location, session?.role ?? '', isMg),
              userName: session?.name ?? '',
              userRole: session?.role ?? '',
              userAvatar: session?.avatar ?? '?',
              isMg: isMg,
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
        currentIndex: _currentIndex(location, isMg),
        isMg: isMg,
        onMoreTapped: () => _showMoreSheet(context, session?.role ?? '', isMg),
      ),
    );
  }

  void _showMoreSheet(BuildContext context, String userRole, bool isMg) {
    final bottomPathList = _getBottomNavItems(isMg).map((e) => e.path).toList();
    final moreItems = _getSidebarItems(isMg).where((item) {
      if (item.path == '/admin' && !userRole.toLowerCase().contains('responsable')) return false;
      return !bottomPathList.contains(item.path);
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
  final bool isMg;
  final VoidCallback onMoreTapped;

  const _MobileBottomNav({
    required this.currentIndex,
    required this.isMg,
    required this.onMoreTapped,
  });

  @override
  Widget build(BuildContext context) {
    final items = _getBottomNavItems(isMg);
    return NavigationBar(
      selectedIndex: currentIndex,
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.primaryPale,
      onDestinationSelected: (index) {
        if (index == items.length - 1) {
          onMoreTapped();
          return;
        }
        context.go(items[index].path);
      },
      destinations: items
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
  final bool isMg;
  final VoidCallback onLogout;

  const _DesktopSidebar({
    required this.currentIndex,
    required this.userName,
    required this.userRole,
    required this.userAvatar,
    required this.isMg,
    required this.onLogout,
  });

  void _showProfileMenu(BuildContext context, Offset position) {
    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy - 220,
        position.dx + 240,
        position.dy,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: AppColors.cardSurface,
      elevation: 8,
      items: [
        // Profile header
        PopupMenuItem<String>(
          enabled: false,
          padding: EdgeInsets.zero,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.s14),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.borderLight),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    userAvatar,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        userRole,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Profile / Settings
        PopupMenuItem<String>(
          value: 'profile',
          child: Row(
            children: [
              const Icon(LucideIcons.user, size: 18, color: AppColors.textSecondary),
              const SizedBox(width: AppSpacing.s10),
              Text(isMg ? 'Ny mombamomba ahy' : 'Mon profil'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'settings',
          child: Row(
            children: [
              const Icon(LucideIcons.settings, size: 18, color: AppColors.textSecondary),
              const SizedBox(width: AppSpacing.s10),
              Text(isMg ? 'Fikirakirana' : 'Paramètres'),
            ],
          ),
        ),
        if (userRole.toLowerCase().contains('responsable'))
          PopupMenuItem<String>(
            value: 'admin',
            child: Row(
              children: [
                const Icon(LucideIcons.shield, size: 18, color: AppColors.textSecondary),
                const SizedBox(width: AppSpacing.s10),
                const Text('Administration'),
              ],
            ),
          ),
        const PopupMenuDivider(),
          PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              Icon(LucideIcons.logOut, size: 18, color: AppColors.error),
              const SizedBox(width: AppSpacing.s10),
              Text(
                isMg ? 'Hivoaka' : 'Déconnexion',
                style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value == null || !context.mounted) return;
      switch (value) {
        case 'profile':
        case 'settings':
          context.go('/settings');
        case 'admin':
          context.go('/admin');
        case 'logout':
          onLogout();
      }
    });
  }

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
              itemCount: _getSidebarItems(isMg).length,
              itemBuilder: (context, index) {
                final item = _getSidebarItems(isMg)[index];
                if (item.path == '/admin' && !userRole.toLowerCase().contains('responsable')) return const SizedBox.shrink();
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
          // User footer with Facebook-style profile menu
          Padding(
            padding: const EdgeInsets.all(AppSpacing.s12),
            child: GestureDetector(
              onTapUp: (details) {
                final box = context.findRenderObject() as RenderBox;
                final position = box.localToGlobal(details.localPosition);
                _showProfileMenu(context, position);
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.s10),
                  decoration: BoxDecoration(
                    color: AppColors.sidebarUserCardBg,
                    borderRadius: BorderRadius.circular(14),
                    border:
                        Border.all(color: AppColors.sidebarUserCardBorder),
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
                      Icon(
                        LucideIcons.chevronUp,
                        size: 16,
                        color: AppColors.sidebarText,
                      ),
                    ],
                  ),
                ),
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
