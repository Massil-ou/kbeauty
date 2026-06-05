import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../App/Manager.dart';
import '../Shared/KBeautyTheme.dart';
import '../Shared/KBeautyWidgets.dart';

class AccountDashboardView extends StatelessWidget {
  const AccountDashboardView({super.key, required this.manager});

  final Manager manager;

  @override
  Widget build(BuildContext context) {
    final cards = <_Shortcut>[
      _Shortcut(
        'Mes rendez-vous',
        'Suivre mes demandes et consulter mon historique.',
        Icons.calendar_month_outlined,
        '/appointments',
      ),
      _Shortcut(
        'Mon profil',
        'Mettre à jour mes informations personnelles.',
        Icons.person_outline_rounded,
        '/account/profile',
      ),
      if (!manager.isBeauticianhRole && !manager.isAdminRole)
        _Shortcut(
          'Devenir pro',
          'Envoyer une demande de compte professionnel.',
          Icons.workspace_premium_outlined,
          '/account/profile?section=pro',
        ),
      if (manager.isBeauticianhRole) ...[
        _Shortcut(
          'Dashboard pro',
          'Gérer les demandes et les prochains rendez-vous.',
          Icons.insights_outlined,
          '/beautician/dashboard',
        ),
        _Shortcut(
          'Mes prestations',
          'Ajouter, modifier, masquer ou supprimer mes offres.',
          Icons.list_alt_outlined,
          '/beautician/services',
        ),
      ],
      if (manager.isAdminRole)
        _Shortcut(
          'Administration',
          'Piloter les utilisateurs et modérer les prestations.',
          Icons.admin_panel_settings_outlined,
          '/admin',
        ),
    ];

    return KBeautyPage(
      manager: manager,
      title: 'Mon espace',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(26),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [KBeautyTheme.primaryDark, KBeautyTheme.primary],
              ),
              borderRadius: BorderRadius.circular(26),
              image: const DecorationImage(
                image: AssetImage('assets/images/back.png'),
                fit: BoxFit.cover,
                opacity: 0.12,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const KBeautyStatusChip(
                  label: 'Espace connecté',
                  color: Colors.white,
                  icon: Icons.verified_user_outlined,
                ),
                const SizedBox(height: 14),
                Text(
                  manager.currentUserName.isEmpty
                      ? 'Bienvenue dans votre espace'
                      : 'Bonjour ${manager.currentUserName}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Tout ce dont vous avez besoin pour gérer votre activité kBeauty.',
                  style: TextStyle(color: Colors.white70, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const KBeautySectionTitle(
            title: 'Accès rapides',
            subtitle: 'Votre espace s’adapte automatiquement à votre profil.',
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 900
                  ? 3
                  : constraints.maxWidth >= 570
                      ? 2
                      : 1;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: cards.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  mainAxisExtent: 180,
                ),
                itemBuilder: (_, index) {
                  final item = cards[index];
                  return InkWell(
                    onTap: () => context.go(item.route),
                    borderRadius: BorderRadius.circular(20),
                    child: KBeautyCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            backgroundColor: KBeautyTheme.primarySoft,
                            child: Icon(item.icon, color: KBeautyTheme.primary),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            item.title,
                            style: const TextStyle(
                              color: KBeautyTheme.text,
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            item.subtitle,
                            style: const TextStyle(
                              color: KBeautyTheme.muted,
                              fontSize: 12,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Shortcut {
  const _Shortcut(this.title, this.subtitle, this.icon, this.route);

  final String title;
  final String subtitle;
  final IconData icon;
  final String route;
}
