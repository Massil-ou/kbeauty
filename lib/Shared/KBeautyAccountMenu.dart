import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../App/Manager.dart';
import 'KBeautyTheme.dart';

class KBeautyAccountMenu extends StatelessWidget {
  const KBeautyAccountMenu({super.key, required this.manager});

  final Manager manager;

  static Future<void> open(BuildContext context, Manager manager) {
    if (!manager.isAuthenticated) return Future.value();
    return showGeneralDialog<void>(
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
  }

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
                    children: _authenticatedItems(context),
                  ),
                ),
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
            child:
                const Icon(Icons.person_rounded, color: KBeautyTheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  manager.currentUserName.isEmpty
                      ? 'Mon compte keauty'
                      : manager.currentUserName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _roleLabel(),
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

  List<Widget> _authenticatedItems(BuildContext context) {
    if (manager.isAdminRole) {
      return [
        _section('Administration'),
        _item(
          context,
          icon: Icons.admin_panel_settings_outlined,
          label: 'Dashboard admin',
          subtitle: 'Utilisateurs, demandes pro et modération.',
          onTap: () => _go(context, '/admin'),
        ),
        _item(
          context,
          icon: Icons.space_dashboard_outlined,
          label: 'Mon espace',
          subtitle: 'Accès rapides administrateur.',
          onTap: () => _go(context, '/account/dashboard'),
        ),
        _item(
          context,
          icon: Icons.person_outline_rounded,
          label: 'Mon profil',
          subtitle: 'Informations du compte.',
          onTap: () => _go(context, '/account/profile'),
        ),
      ];
    }

    if (manager.isBeauticianhRole) {
      return [
        _section('Espace professionnelle'),
        _item(
          context,
          icon: Icons.space_dashboard_outlined,
          label: 'Mon espace pro',
          subtitle: 'Vos raccourcis métier.',
          onTap: () => _go(context, '/account/dashboard'),
        ),
        _item(
          context,
          icon: Icons.person_outline_rounded,
          label: 'Mon profil',
          subtitle: 'Infos personnelles et dossier pro.',
          onTap: () => _go(context, '/account/profile'),
        ),
        _item(
          context,
          icon: Icons.calendar_month_outlined,
          label: 'Mes rendez-vous client',
          subtitle: 'Vos réservations personnelles.',
          onTap: () => _go(context, '/appointments'),
        ),
        _item(
          context,
          icon: Icons.insights_outlined,
          label: 'Dashboard pro',
          subtitle: 'Demandes, RDV et historique.',
          onTap: () => _go(context, '/beautician/dashboard'),
        ),
        _item(
          context,
          icon: Icons.list_alt_outlined,
          label: 'Mes prestations',
          subtitle: 'CRUD complet de vos offres.',
          onTap: () => _go(context, '/beautician/services'),
        ),
        _item(
          context,
          icon: Icons.add_circle_outline_rounded,
          label: 'Publier une prestation',
          subtitle: 'Créer une nouvelle offre à domicile.',
          onTap: () => _go(context, '/beautician/services/new'),
        ),
        _item(
          context,
          icon: Icons.badge_outlined,
          label: 'Profil professionnel',
          subtitle: 'Présentation visible par les clientes.',
          onTap: () => _go(context, '/account/profile?section=beauty'),
        ),
      ];
    }

    return [
      _section('Espace client'),
      _item(
        context,
        icon: Icons.space_dashboard_outlined,
        label: 'Tableau de bord',
        subtitle: 'Vos raccourcis beauté.',
        onTap: () => _go(context, '/account/dashboard'),
      ),
      _item(
        context,
        icon: Icons.calendar_month_outlined,
        label: 'Mes rendez-vous',
        subtitle: 'Réservations, paiements et historique.',
        onTap: () => _go(context, '/appointments'),
      ),
      _item(
        context,
        icon: Icons.person_outline_rounded,
        label: 'Mon profil',
        subtitle: 'Informations personnelles.',
        onTap: () => _go(context, '/account/profile'),
      ),
      _section('Professionnelle'),
      _item(
        context,
        icon: Icons.workspace_premium_outlined,
        label: 'Devenir professionnelle',
        subtitle: 'Remplir le dossier et demander validation.',
        color: KBeautyTheme.primary,
        onTap: () => _go(context, '/account/profile?section=pro'),
      ),
    ];
  }

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
    String? subtitle,
    Color color = KBeautyTheme.text,
  }) =>
      ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
        leading: Icon(icon, color: color),
        title: Text(
          label,
          style: TextStyle(color: color, fontWeight: FontWeight.w800),
        ),
        subtitle: subtitle == null
            ? null
            : Text(
                subtitle,
                style: const TextStyle(
                  color: KBeautyTheme.muted,
                  fontSize: 11,
                ),
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
