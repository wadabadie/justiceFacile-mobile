import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:showcaseview/showcaseview.dart';
import '../../core/constants/app_colors.dart';
import '../../core/router/role_router.dart';
import '../../features/auth/infrastructure/auth_repository_impl.dart';

/// Every tab any layout uses. New layouts pick a subset from this list.
enum NavTab {
  home, dossiers, ia, messages, profil,
  // Specialiste (juriste/psychologue/ong)
  casDispo, planning,
  // ONG
  activites,
  // Admin
  adminDash, adminRapports, adminNotifs,
}

class AppBottomNav extends StatefulWidget {
  const AppBottomNav({
    super.key,
    required this.current,
    this.messagesTipKey,
  });

  final NavTab current;
  final GlobalKey? messagesTipKey;

  @override
  State<AppBottomNav> createState() => _AppBottomNavState();
}

class _AppBottomNavState extends State<AppBottomNav> {
  String? _role;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final user = await AuthRepositoryImpl().restoreSession();
    if (mounted) setState(() => _role = user?.role);
  }

  static const _citizenItems = [
    _NavItem(tab: NavTab.home,     icon: Icons.home_rounded,         route: '/home',       label: 'Accueil'),
    _NavItem(tab: NavTab.dossiers, icon: Icons.folder_copy_rounded,  route: '/dossiers',   label: 'Dossiers'),
    _NavItem(tab: NavTab.ia,       icon: Icons.auto_awesome_rounded, route: '/ia',         label: 'IA'),
    _NavItem(tab: NavTab.messages, icon: Icons.forum_rounded,        route: '/messagerie', label: 'Messages'),
    _NavItem(tab: NavTab.profil,   icon: Icons.person_rounded,       route: '/profil',     label: 'Profil'),
  ];

  static const _specialisteItems = [
    _NavItem(tab: NavTab.home,     icon: Icons.dashboard_rounded,    route: '/home-specialiste', label: 'Accueil'),
    _NavItem(tab: NavTab.casDispo, icon: Icons.inbox_rounded,        route: '/cas-disponibles',  label: 'Cas'),
    _NavItem(tab: NavTab.dossiers, icon: Icons.folder_copy_rounded,  route: '/dossiers',         label: 'Dossiers'),
    _NavItem(tab: NavTab.planning, icon: Icons.calendar_month_rounded, route: '/planning',       label: 'Planning'),
    _NavItem(tab: NavTab.messages, icon: Icons.forum_rounded,        route: '/messagerie',       label: 'Messages'),
  ];

  static const _ongItems = [
    _NavItem(tab: NavTab.home,      icon: Icons.dashboard_rounded,      route: '/home-ong',        label: 'Accueil'),
    _NavItem(tab: NavTab.casDispo,  icon: Icons.inbox_rounded,          route: '/cas-disponibles', label: 'Cas'),
    _NavItem(tab: NavTab.activites, icon: Icons.event_available_rounded, route: '/activites',      label: 'Activités'),
    _NavItem(tab: NavTab.dossiers,  icon: Icons.folder_copy_rounded,    route: '/dossiers',        label: 'Dossiers'),
    _NavItem(tab: NavTab.messages,  icon: Icons.forum_rounded,          route: '/messagerie',      label: 'Messages'),
  ];

  static const _adminItems = [
    _NavItem(tab: NavTab.adminDash,     icon: Icons.dashboard_rounded,     route: '/admin',         label: 'Dashboard'),
    _NavItem(tab: NavTab.dossiers,      icon: Icons.folder_copy_rounded,   route: '/dossiers',      label: 'Dossiers'),
    _NavItem(tab: NavTab.adminNotifs,   icon: Icons.notifications_rounded, route: '/notifications', label: 'Notifs'),
    _NavItem(tab: NavTab.adminRapports, icon: Icons.bar_chart_rounded,     route: '/rapports',      label: 'Rapports'),
    _NavItem(tab: NavTab.profil,        icon: Icons.person_rounded,        route: '/profil',        label: 'Profil'),
  ];

  List<_NavItem> get _items {
    return switch (parseRole(_role)) {
      UserRole.juriste || UserRole.psychologue => _specialisteItems,
      UserRole.ong                             => _ongItems,
      UserRole.admin                           => _adminItems,
      _                                        => _citizenItems,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.blanc,
        boxShadow: [
          BoxShadow(color: Color(0x18000000), blurRadius: 20, offset: Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 72,
          child: Row(
            children: _items.map((item) {
              final isActive = item.tab == widget.current;
              final chip = _NavChip(item: item, isActive: isActive);
              if (item.tab == NavTab.messages && widget.messagesTipKey != null) {
                return Expanded(
                  child: Showcase(
                    key: widget.messagesTipKey!,
                    description: 'Vos échanges sécurisés avec vos juristes et psychologues.',
                    child: _TapTarget(item: item, chip: chip),
                  ),
                );
              }
              return Expanded(child: _TapTarget(item: item, chip: chip));
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _TapTarget extends StatelessWidget {
  const _TapTarget({required this.item, required this.chip});
  final _NavItem item;
  final Widget chip;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => context.go(item.route),
      child: chip,
    );
  }
}

class _NavChip extends StatelessWidget {
  const _NavChip({required this.item, required this.isActive});
  final _NavItem item;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isActive)
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.bleuNuit,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(item.icon, size: 20, color: AppColors.orPale),
                  const SizedBox(width: 5),
                  Text(
                    item.label,
                    style: const TextStyle(
                      fontFamily: 'GoogleSans',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.orPale,
                      letterSpacing: 0.1,
                    ),
                  ),
                ],
              ),
            ),
          )
        else ...[
          Icon(item.icon, size: 24, color: AppColors.grisLight),
          const SizedBox(height: 4),
          Text(
            item.label,
            style: const TextStyle(
              fontFamily: 'GoogleSans',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.grisLight,
            ),
          ),
        ],
      ],
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.tab,
    required this.icon,
    required this.route,
    required this.label,
  });
  final NavTab tab;
  final IconData icon;
  final String route;
  final String label;
}
