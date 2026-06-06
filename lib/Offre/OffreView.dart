import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../App/Manager.dart';
import '../Shared/KBeautyCategoryIcons.dart';
import '../Shared/KBeautyTheme.dart';
import '../Shared/KBeautyWidgets.dart';
import '../Shared/Models.dart';

class OffreView extends StatefulWidget {
  const OffreView({super.key, required this.manager});

  final Manager manager;

  @override
  State<OffreView> createState() => _OffreViewState();
}

class _OffreViewState extends State<OffreView> {
  static const _maxWidth = 1180.0;
  final _searchCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  late final _serviceManager = widget.manager.serviceManager;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _serviceManager.loadCategories();
    _serviceManager.loadFeaturedServices();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    FocusScope.of(context).unfocus();
    final city = _cityCtrl.text.trim();
    if (city.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Indiquez votre ville pour voir les offres disponibles.'),
        ),
      );
      return;
    }
    await _serviceManager.searchServices(
      query: _searchCtrl.text.trim().isEmpty ? null : _searchCtrl.text.trim(),
      category: _selectedCategory,
      city: city,
    );
  }

  Future<void> _reset() async {
    setState(() {
      _searchCtrl.clear();
      _cityCtrl.clear();
      _selectedCategory = null;
    });
    _serviceManager.clearSearch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KBeautyTheme.background,
      appBar: KBeautyHeader(manager: widget.manager),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const KBeautyBackdrop(),
          RefreshIndicator(
            onRefresh: _search,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  _Hero(
                    controller: _searchCtrl,
                    cityController: _cityCtrl,
                    onSearch: _search,
                    manager: widget.manager,
                  ),
                  Transform.translate(
                    offset: const Offset(0, -34),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: KBeautyTheme.background.withValues(alpha: 0.96),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(36),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: KBeautyTheme.primaryDark.withValues(
                              alpha: 0.09,
                            ),
                            blurRadius: 30,
                            offset: const Offset(0, -8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints:
                              const BoxConstraints(maxWidth: _maxWidth),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 28, 16, 20),
                            child: Column(
                              children: [
                                _featuredOffers(),
                                const SizedBox(height: 30),
                                _categoryPicker(),
                                const SizedBox(height: 30),
                                _servicesSection(),
                                const SizedBox(height: 42),
                                const _HowItWorks(),
                                const SizedBox(height: 34),
                                _PartnerCallout(manager: widget.manager),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryPicker() {
    return ListenableBuilder(
      listenable: _serviceManager,
      builder: (context, _) {
        final categories = _serviceManager.categories;
        if (_serviceManager.isLoadingCategories && categories.isEmpty) {
          return const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              KBeautySectionTitle(
                title: 'Explorez par catégorie',
                subtitle: 'Chargement des catégories disponibles...',
              ),
              SizedBox(height: 16),
              KBeautySkeletonSlots(count: 5),
            ],
          );
        }
        if (categories.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            KBeautySectionTitle(
              title: 'Explorez par catégorie',
              subtitle:
                  'Des prestations sélectionnées pour chaque envie beauté.',
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 102,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, index) {
                  final item = categories[index];
                  final selected = item.name == _selectedCategory;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedCategory = selected ? null : item.name;
                      });
                      _search();
                    },
                    borderRadius: BorderRadius.circular(18),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 126,
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        color: selected
                            ? KBeautyTheme.primary
                            : KBeautyTheme.surface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: selected
                              ? KBeautyTheme.primary
                              : KBeautyTheme.divider,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: KBeautyTheme.primaryDark.withValues(
                              alpha: 0.06,
                            ),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            kBeautyCategoryIcon(item.icon),
                            color:
                                selected ? Colors.white : KBeautyTheme.primary,
                            size: 25,
                          ),
                          const SizedBox(height: 9),
                          Text(
                            item.name,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: selected
                                  ? Colors.white
                                  : KBeautyTheme.primaryDark,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _featuredOffers() {
    return ListenableBuilder(
      listenable: _serviceManager,
      builder: (context, _) {
        final offers = _serviceManager.activeSearchCity == null
            ? _serviceManager.featuredServices.take(8).toList()
            : _serviceManager.services.take(8).toList();
        if ((_serviceManager.isLoadingFeatured || _serviceManager.isLoading) &&
            offers.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const KBeautySectionTitle(
                title: 'À découvrir aujourd’hui',
                subtitle: 'Préparation de vos offres beauté...',
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 245,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 4,
                  separatorBuilder: (_, __) => const SizedBox(width: 13),
                  itemBuilder: (_, __) => const SizedBox(
                    width: 300,
                    child: KBeautySkeletonCard(),
                  ),
                ),
              ),
            ],
          );
        }
        if (offers.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            KBeautySectionTitle(
              title: 'À découvrir aujourd’hui',
              subtitle: _serviceManager.activeSearchCity == null
                  ? 'Des annonces visibles en vitrine. Recherchez votre ville avant de réserver.'
                  : 'Des offres disponibles dans votre zone de recherche.',
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 245,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: offers.length,
                separatorBuilder: (_, __) => const SizedBox(width: 13),
                itemBuilder: (_, index) {
                  final service = offers[index];
                  return _FeaturedOfferCard(
                    service: service,
                    onTap: () => context.pushNamed(
                      'service_detail',
                      pathParameters: {'id': service.id},
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _servicesSection() {
    return ListenableBuilder(
      listenable: _serviceManager,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            KBeautySectionTitle(
              title: _selectedCategory ?? 'Prestations recommandées',
              subtitle: _serviceManager.isLoading
                  ? 'Recherche en cours...'
                  : _serviceManager.activeSearchCity == null
                      ? 'Choisissez d’abord votre ville pour éviter les rendez-vous hors zone.'
                      : '${_serviceManager.services.length} prestation(s) disponible(s) à ${_serviceManager.activeSearchCity}',
              trailing: _selectedCategory != null ||
                      _searchCtrl.text.isNotEmpty ||
                      _cityCtrl.text.isNotEmpty
                  ? TextButton.icon(
                      onPressed: _reset,
                      icon: const Icon(Icons.close, size: 17),
                      label: const Text('Effacer'),
                    )
                  : null,
            ),
            const SizedBox(height: 18),
            if (_serviceManager.isLoading)
              const KBeautySkeletonGrid()
            else if (_serviceManager.activeSearchCity == null &&
                _serviceManager.services.isEmpty)
              KBeautyEmptyState(
                icon: Icons.location_city_outlined,
                title: 'Choisissez votre ville',
                message:
                    'Les offres sont filtrées par zone d’intervention. Cela évite de réserver une prestation trop loin de chez vous.',
                action: ElevatedButton.icon(
                  onPressed: _search,
                  icon: const Icon(Icons.search_rounded),
                  label: const Text('Rechercher dans ma ville'),
                ),
              )
            else if (_serviceManager.services.isEmpty)
              KBeautyEmptyState(
                icon: Icons.search_off_rounded,
                title: 'Aucune prestation trouvée',
                message: _serviceManager.lastError ??
                    'Essayez une autre recherche ou retirez les filtres.',
                action: OutlinedButton(
                  onPressed: _reset,
                  child: const Text('Changer de recherche'),
                ),
              )
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final columns = width >= 1020
                      ? 3
                      : width >= 650
                          ? 2
                          : 1;
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _serviceManager.services.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      mainAxisSpacing: 18,
                      crossAxisSpacing: 18,
                      mainAxisExtent: columns == 1 ? 355 : 380,
                    ),
                    itemBuilder: (_, index) => _ServiceCard(
                      service: _serviceManager.services[index],
                      onTap: () => context.pushNamed(
                        'service_detail',
                        pathParameters: {
                          'id': _serviceManager.services[index].id,
                        },
                      ),
                    ),
                  );
                },
              ),
            if (_serviceManager.hasMore) ...[
              const SizedBox(height: 20),
              Center(
                child: OutlinedButton(
                  onPressed: _serviceManager.loadMore,
                  child: const Text('Afficher plus de prestations'),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({
    required this.controller,
    required this.cityController,
    required this.onSearch,
    required this.manager,
  });

  final TextEditingController controller;
  final TextEditingController cityController;
  final Future<void> Function() onSearch;
  final Manager manager;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).width < 720 ? 390 : 330,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const KBeautyBackdrop(strong: true),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 34, 18, 72),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const KBeautyStatusChip(
                      label: 'Beauté à domicile, simplement',
                      color: Colors.white,
                      icon: Icons.auto_awesome,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      manager.isAuthenticated &&
                              manager.currentUserName.isNotEmpty
                          ? 'Bonjour ${manager.currentUserName}, prenez soin de vous'
                          : 'Votre beauté, au bon endroit et au bon moment',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        height: 1.08,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Indiquez votre ville pour afficher uniquement les professionnelles qui couvrent votre zone.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.86),
                        fontSize: 14,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.16),
                            blurRadius: 28,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: TextField(
                              controller: cityController,
                              onSubmitted: (_) => onSearch(),
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                hintText: 'Votre ville',
                                prefixIcon: Icon(
                                  Icons.location_city_outlined,
                                  color: KBeautyTheme.primary,
                                ),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                filled: false,
                              ),
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 34,
                            color: KBeautyTheme.divider,
                          ),
                          Expanded(
                            flex: 7,
                            child: TextField(
                              controller: controller,
                              onSubmitted: (_) => onSearch(),
                              textInputAction: TextInputAction.search,
                              decoration: const InputDecoration(
                                hintText: 'Coiffure, ongles, maquillage...',
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: KBeautyTheme.primary,
                                ),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                filled: false,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          SizedBox(
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: onSearch,
                              icon: const Icon(Icons.search, size: 18),
                              label: Text(
                                MediaQuery.sizeOf(context).width < 540
                                    ? ''
                                    : 'Rechercher',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.service, required this.onTap});

  final ServiceModel service;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: KBeautyTheme.cardDecoration(radius: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (service.images.isNotEmpty)
                      Image.network(
                        service.images.first,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const _ImageFallback(),
                      )
                    else
                      const _ImageFallback(),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: KBeautyStatusChip(
                        label: service.category,
                        color: KBeautyTheme.primary,
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.94),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star,
                                color: Colors.amber, size: 15),
                            const SizedBox(width: 4),
                            Text(
                              service.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                color: KBeautyTheme.text,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: KBeautyTheme.text,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      service.beautician.businessName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: KBeautyTheme.muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule_rounded,
                          size: 16,
                          color: KBeautyTheme.muted,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '${service.durationMinutes} min',
                          style: const TextStyle(
                            color: KBeautyTheme.muted,
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${service.price.toStringAsFixed(0)} €',
                          style: const TextStyle(
                            color: KBeautyTheme.primary,
                            fontSize: 19,
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
      ),
    );
  }
}

class _FeaturedOfferCard extends StatelessWidget {
  const _FeaturedOfferCard({required this.service, required this.onTap});

  final ServiceModel service;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: MediaQuery.sizeOf(context).width < 600 ? 285 : 340,
        clipBehavior: Clip.antiAlias,
        decoration: KBeautyTheme.cardDecoration(radius: 22),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (service.images.isNotEmpty)
              Image.network(
                service.images.first,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const _ImageFallback(),
              )
            else
              const _ImageFallback(),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xE6000000)],
                  stops: [0.30, 1],
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
                children: [
                  Text(
                    service.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
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
                          fontSize: 19,
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

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

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

class _HowItWorks extends StatelessWidget {
  const _HowItWorks();

  @override
  Widget build(BuildContext context) {
    const steps = [
      (
        icon: Icons.search_rounded,
        title: 'Trouvez',
        text: 'Explorez les prestations et choisissez votre professionnelle.'
      ),
      (
        icon: Icons.calendar_month_outlined,
        title: 'Réservez',
        text: 'Sélectionnez la date et le créneau qui vous conviennent.'
      ),
      (
        icon: Icons.auto_awesome_rounded,
        title: 'Profitez',
        text: 'Recevez votre prestation beauté et partagez votre avis.'
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const KBeautySectionTitle(
          title: 'Comment ça marche ?',
          subtitle: 'Trois étapes pour prendre soin de vous.',
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final vertical = constraints.maxWidth < 720;
            Widget card(({IconData icon, String title, String text}) step) {
              return KBeautyCard(
                child: Column(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(
                        color: KBeautyTheme.primarySoft,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(step.icon, color: KBeautyTheme.primary),
                    ),
                    const SizedBox(height: 13),
                    Text(
                      step.title,
                      style: const TextStyle(
                        color: KBeautyTheme.text,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      step.text,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: KBeautyTheme.muted,
                        fontSize: 12,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (vertical) {
              return Column(
                children: [
                  for (final step in steps) ...[
                    card(step),
                    const SizedBox(height: 12),
                  ],
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < steps.length; i++) ...[
                  Expanded(child: card(steps[i])),
                  if (i < steps.length - 1) const SizedBox(width: 14),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

class _PartnerCallout extends StatelessWidget {
  const _PartnerCallout({required this.manager});

  final Manager manager;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
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
      child: Wrap(
        spacing: 20,
        runSpacing: 18,
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.spaceBetween,
        children: [
          const SizedBox(
            width: 610,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vous êtes professionnelle de la beauté ?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 7),
                Text(
                  'Les partenaires keauty validées accèdent à leur espace professionnel pour publier leurs prestations et gérer leurs rendez-vous.',
                  style: TextStyle(color: Colors.white70, height: 1.45),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => context.go(
              manager.isBeauticianhRole
                  ? '/beautician/dashboard'
                  : manager.isAuthenticated
                      ? '/account/profile?section=pro'
                      : '/login',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: KBeautyTheme.primaryDark,
            ),
            icon: const Icon(Icons.arrow_forward_rounded),
            label: Text(
              manager.isBeauticianhRole
                  ? 'Ouvrir mon espace'
                  : manager.isAuthenticated
                      ? 'Devenir professionnelle'
                      : 'Se connecter',
            ),
          ),
        ],
      ),
    );
  }
}
