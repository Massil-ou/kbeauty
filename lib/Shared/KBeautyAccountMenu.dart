import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../App/Manager.dart';
import 'KBeautyTheme.dart';

class KBeautyAccountMenu extends StatelessWidget {
  const KBeautyAccountMenu({super.key, required this.manager});

  final Manager manager;

  static Future<void> open(BuildContext context, Manager manager) =>
      showGeneralDialog<void>(
        context: context,
        barrierDismissible: true,
        barrierLabel: 'Fermer le menu',
        barrierColor: Colors.black.withValues(alpha: 0.30),
        transitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (_, __, ___) => KBeautyAccountMenu(manager: manager),
        transitionBuilder: (_, animation, __, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: child,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Material(
        color: KBeautyTheme.surface,
        borderRadius: const BorderRadius.horizontal(left: Radius.circular(26)),
        child: SafeArea(
          child: SizedBox(
            width: MediaQuery.sizeOf(context).width < 420
                ? MediaQuery.sizeOf(context).width * 0.90
                : 350,
            height: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _header(context),
                const Divider(height: 1),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    children: manager.isAuthenticated
                        ? _authenticatedItems(context)
                        : _publicItems(context),
                  ),
                ),
                if (manager.isAuthenticated) ...[
                  const Divider(height: 1),
                  _item(
                    context,
                    icon: Icons.logout_rounded,
                    label: 'Déconnexion',
                    color: KBeautyTheme.danger,
                    onTap: () async {
                      Navigator.pop(context);
                      await manager.authManager.logout();
                      if (context.mounted) context.go('/');
                    },
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 14, 18),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [KBeautyTheme.primaryDark, KBeautyTheme.primary],
        ),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(26)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.white,
            child: Icon(
              manager.isAuthenticated
                  ? Icons.person_rounded
                  : Icons.spa_rounded,
              color: KBeautyTheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  manager.isAuthenticated
                      ? (manager.currentUserName.isEmpty
                          ? 'Mon compte kBeauty'
                          : manager.currentUserName)
                      : 'Bienvenue sur kBeauty',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  manager.isAuthenticated
                      ? _roleLabel()
                      : 'Réservez votre prochain soin',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }

  List<Widget> _publicItems(BuildContext context) => [
        _section('Navigation'),
        _item(
          context,
          icon: Icons.home_outlined,
          label: 'Accueil',
          onTap: () => _go(context, '/'),
        ),
        _item(
          context,
          icon: Icons.login_rounded,
          label: 'Connexion',
          onTap: () => _go(context, '/login'),
        ),
        _item(
          context,
          icon: Icons.person_add_alt_1_outlined,
          label: 'Créer un compte',
          onTap: () => _go(context, '/signup'),
        ),
      ];

  List<Widget> _authenticatedItems(BuildContext context) => [
        _section('Mon espace'),
        _item(
          context,
          icon: Icons.space_dashboard_outlined,
          label: 'Tableau de bord',
          onTap: () => _go(context, '/account/dashboard'),
        ),
        _item(
          context,
          icon: Icons.person_outline_rounded,
          label: 'Mon profil',
          onTap: () => _go(context, '/account/profile'),
        ),
        _item(
          context,
          icon: Icons.calendar_month_outlined,
          label: 'Mes rendez-vous',
          onTap: () => _go(context, '/appointments'),
        ),
        if (!manager.isBeauticianhRole && !manager.isAdminRole)
          _item(
            context,
            icon: Icons.workspace_premium_outlined,
            label: 'Devenir professionnelle',
            onTap: () => _go(context, '/account/profile?section=pro'),
          ),
        if (manager.isBeauticianhRole) ...[
          _section('Espace professionnelle'),
          _item(
            context,
            icon: Icons.insights_outlined,
            label: 'Dashboard pro',
            onTap: () => _go(context, '/beautician/dashboard'),
          ),
          _item(
            context,
            icon: Icons.list_alt_outlined,
            label: 'Mes prestations',
            onTap: () => _go(context, '/beautician/services'),
          ),
          _item(
            context,
            icon: Icons.add_circle_outline_rounded,
            label: 'Publier une prestation',
            onTap: () => _go(context, '/beautician/services/new'),
          ),
          _item(
            context,
            icon: Icons.badge_outlined,
            label: 'Profil professionnel',
            onTap: () => _go(context, '/account/profile?section=beauty'),
          ),
        ],
        if (manager.isAdminRole) ...[
          _section('Administration'),
          _item(
            context,
            icon: Icons.admin_panel_settings_outlined,
            label: 'Gérer kBeauty',
            onTap: () => _go(context, '/admin'),
          ),
        ],
      ];

  Widget _section(String label) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
        child: Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: KBeautyTheme.muted,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
      );

  Widget _item(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = KBeautyTheme.text,
  }) =>
      ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
        leading: Icon(icon, color: color),
        title: Text(
          label,
          style: TextStyle(color: color, fontWeight: FontWeight.w800),
        ),
        trailing: Icon(Icons.chevron_right_rounded, color: color, size: 20),
        onTap: onTap,
      );

  void _go(BuildContext context, String route) {
    Navigator.pop(context);
    context.go(route);
  }

  String _roleLabel() {
    if (manager.isAdminRole) return 'Administration';
    if (manager.isBeauticianhRole) return 'Compte professionnel';
    return 'Compte client';
  }
}
