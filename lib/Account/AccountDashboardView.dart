import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../App/Manager.dart';
import '../Shared/KBeautyTheme.dart';
import '../Shared/KBeautyWidgets.dart';
import '../Shared/Models.dart';

class AccountDashboardView extends StatefulWidget {
  const AccountDashboardView({super.key, required this.manager});

  final Manager manager;

  @override
  State<AccountDashboardView> createState() => _AccountDashboardViewState();
}

class _AccountDashboardViewState extends State<AccountDashboardView> {
  Manager get manager => widget.manager;

  @override
  void initState() {
    super.initState();
    manager.serviceManager.loadFeaturedServices();
  }

  @override
  Widget build(BuildContext context) {
    final role = _roleConfig();
    final cards = _shortcutsForRole();

    return KBeautyPage(
      manager: manager,
      title: 'Mon espace',
      showBack: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _hero(role),
          if (!manager.isBeauticianhRole && !manager.isAdminRole) ...[
            const SizedBox(height: 18),
            _becomeProCallout(context),
          ],
          const SizedBox(height: 24),
          KBeautySectionTitle(
            title: role.sectionTitle,
            subtitle: role.sectionSubtitle,
          ),
          const SizedBox(height: 16),
          _shortcutGrid(context, cards),
          const SizedBox(height: 28),
          _featuredOffers(context),
        ],
      ),
    );
  }

  _RoleDashboard _roleConfig() {
    if (manager.isAdminRole) {
      return const _RoleDashboard(
        chip: 'Admin',
        title: 'Pilotage keauty',
        subtitle:
            'Vous avez uniquement les accès d’administration et de contrôle.',
        sectionTitle: 'Menu administrateur',
        sectionSubtitle:
            'Validation des professionnelles, modération et utilisateurs.',
        icon: Icons.admin_panel_settings_outlined,
      );
    }
    if (manager.isBeauticianhRole) {
      return const _RoleDashboard(
        chip: 'Compte professionnel',
        title: 'Votre activité beauté',
        subtitle:
            'Gérez vos prestations, vos demandes clientes et votre profil visible.',
        sectionTitle: 'Menu professionnelle',
        sectionSubtitle: 'Tout ce qui sert à vendre et gérer vos services.',
        icon: Icons.spa_outlined,
      );
    }
    return const _RoleDashboard(
      chip: 'Compte client',
      title: 'Votre espace beauté',
      subtitle:
          'Réservez vos prestations à domicile, suivez vos rendez-vous ou passez pro.',
      sectionTitle: 'Menu client',
      sectionSubtitle: 'Réservation, profil et demande professionnelle.',
      icon: Icons.favorite_border_rounded,
    );
  }

  List<_Shortcut> _shortcutsForRole() {
    if (manager.isAdminRole) {
      return const [
        _Shortcut(
          'Dashboard admin',
          'Demandes pro, utilisateurs et modération des prestations.',
          Icons.admin_panel_settings_outlined,
          '/admin',
          KBeautyTheme.primary,
        ),
        _Shortcut(
          'Mon profil',
          'Mettre à jour les informations du compte administrateur.',
          Icons.person_outline_rounded,
          '/account/profile',
          KBeautyTheme.lilac,
        ),
      ];
    }
    if (manager.isBeauticianhRole) {
      return const [
        _Shortcut(
          'Dashboard pro',
          'Confirmer les demandes, terminer les rendez-vous et suivre l’historique.',
          Icons.insights_outlined,
          '/beautician/dashboard',
          KBeautyTheme.primary,
        ),
        _Shortcut(
          'Mes prestations',
          'Ajouter, modifier, masquer ou supprimer vos offres.',
          Icons.list_alt_outlined,
          '/beautician/services',
          KBeautyTheme.gold,
        ),
        _Shortcut(
          'Publier une prestation',
          'Créer une nouvelle offre beauté à domicile.',
          Icons.add_circle_outline_rounded,
          '/beautician/services/new',
          KBeautyTheme.success,
        ),
        _Shortcut(
          'Profil professionnel',
          'Bio, spécialités, téléphone pro et photo visible par les clientes.',
          Icons.badge_outlined,
          '/account/profile?section=beauty',
          KBeautyTheme.lilac,
        ),
        _Shortcut(
          'Mes RDV client',
          'Vos réservations personnelles en tant que cliente.',
          Icons.calendar_month_outlined,
          '/appointments',
          KBeautyTheme.primaryDark,
        ),
      ];
    }
    return const [
      _Shortcut(
        'Mes rendez-vous',
        'Suivre vos réservations, paiements et historique.',
        Icons.calendar_month_outlined,
        '/appointments',
        KBeautyTheme.primary,
      ),
      _Shortcut(
        'Réserver une prestation',
        'Découvrir les offres beauté disponibles à domicile.',
        Icons.search_rounded,
        '/',
        KBeautyTheme.gold,
      ),
      _Shortcut(
        'Mon profil',
        'Mettre à jour vos informations personnelles.',
        Icons.person_outline_rounded,
        '/account/profile',
        KBeautyTheme.lilac,
      ),
      _Shortcut(
        'Devenir pro',
        'Créer votre dossier professionnel et attendre la validation admin.',
        Icons.workspace_premium_outlined,
        '/account/profile?section=pro',
        KBeautyTheme.success,
      ),
    ];
  }

  Widget _hero(_RoleDashboard role) {
    return Container(
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
          KBeautyStatusChip(
            label: role.chip,
            color: Colors.white,
            icon: role.icon,
          ),
          const SizedBox(height: 14),
          Text(
            manager.currentUserName.isEmpty
                ? role.title
                : 'Bonjour ${manager.currentUserName}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 27,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            role.subtitle,
            style: const TextStyle(color: Colors.white70, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _becomeProCallout(BuildContext context) {
    return KBeautyCard(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final action = ElevatedButton.icon(
            onPressed: () => context.go('/account/profile?section=pro'),
            icon: const Icon(Icons.workspace_premium_outlined),
            label: const Text('Commencer ma demande pro'),
          );
          final content = [
            const CircleAvatar(
              radius: 25,
              backgroundColor: KBeautyTheme.goldSoft,
              child: Icon(Icons.storefront_outlined, color: KBeautyTheme.gold),
            ),
            const SizedBox(width: 14, height: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vous proposez des services beauté ?',
                    style: TextStyle(
                      color: KBeautyTheme.text,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Remplissez votre dossier, l’admin valide, puis vous pouvez publier vos prestations.',
                    style: TextStyle(
                      color: KBeautyTheme.muted,
                      fontSize: 12,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ];
          if (constraints.maxWidth < 620) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: content),
                const SizedBox(height: 14),
                SizedBox(width: double.infinity, child: action),
              ],
            );
          }
          return Row(
            children: [
              ...content,
              const SizedBox(width: 14),
              action,
            ],
          );
        },
      ),
    );
  }

  Widget _shortcutGrid(BuildContext context, List<_Shortcut> cards) {
    return LayoutBuilder(
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
            mainAxisExtent: 188,
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
                      backgroundColor: item.color.withValues(alpha: 0.12),
                      child: Icon(item.icon, color: item.color),
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
    );
  }

  Widget _featuredOffers(BuildContext context) {
    final serviceManager = manager.serviceManager;
    return ListenableBuilder(
      listenable: serviceManager,
      builder: (context, _) {
        final offers = serviceManager.featuredServices.take(8).toList();
        if (serviceManager.isLoadingFeatured && offers.isEmpty) {
          return const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              KBeautySectionTitle(
                title: 'Annonces à découvrir',
                subtitle: 'Préparation de votre vitrine beauté...',
              ),
              SizedBox(height: 16),
              SizedBox(
                height: 205,
                child: Row(
                  children: [
                    Expanded(child: KBeautySkeletonCard()),
                    SizedBox(width: 12),
                    Expanded(child: KBeautySkeletonCard()),
                  ],
                ),
              ),
            ],
          );
        }
        if (offers.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const KBeautySectionTitle(
              title: 'Annonces à découvrir',
              subtitle:
                  'Elles restent visibles dans votre espace. Pour réserver, lancez une recherche avec votre ville.',
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 235,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: offers.length,
                separatorBuilder: (_, __) => const SizedBox(width: 13),
                itemBuilder: (_, index) => _DashboardOfferCard(
                  service: offers[index],
                  onTap: () => context.pushNamed(
                    'service_detail',
                    pathParameters: {'id': offers[index].id},
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () => context.go('/'),
                icon: const Icon(Icons.location_city_outlined),
                label: const Text('Rechercher par ville pour réserver'),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DashboardOfferCard extends StatelessWidget {
  const _DashboardOfferCard({required this.service, required this.onTap});

  final ServiceModel service;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: MediaQuery.sizeOf(context).width < 620 ? 280 : 330,
        clipBehavior: Clip.antiAlias,
        decoration: KBeautyTheme.cardDecoration(radius: 22),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (service.images.isNotEmpty)
              Image.network(
                service.images.first,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const _DashboardOfferFallback(),
              )
            else
              const _DashboardOfferFallback(),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xE6000000)],
                  stops: [0.28, 1],
                ),
              ),
            ),
            Positioned(
              top: 13,
              left: 13,
              child: KBeautyStatusChip(
                label: service.category,
                color: Colors.white,
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    service.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      height: 1.1,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${service.beautician.businessName} • ${service.durationMinutes} min',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        '${service.price.toStringAsFixed(0)} €',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardOfferFallback extends StatelessWidget {
  const _DashboardOfferFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: KBeautyTheme.primarySoft,
      alignment: Alignment.center,
      child: const Icon(
        Icons.spa_outlined,
        color: KBeautyTheme.primary,
        size: 44,
      ),
    );
  }
}

class _Shortcut {
  const _Shortcut(this.title, this.subtitle, this.icon, this.route, this.color);

  final String title;
  final String subtitle;
  final IconData icon;
  final String route;
  final Color color;
}

class _RoleDashboard {
  const _RoleDashboard({
    required this.chip,
    required this.title,
    required this.subtitle,
    required this.sectionTitle,
    required this.sectionSubtitle,
    required this.icon,
  });

  final String chip;
  final String title;
  final String subtitle;
  final String sectionTitle;
  final String sectionSubtitle;
  final IconData icon;
}
