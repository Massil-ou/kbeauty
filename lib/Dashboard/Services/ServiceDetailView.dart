import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../App/Manager.dart';
import '../../Shared/KBeautyTheme.dart';
import '../../Shared/KBeautyWidgets.dart';

class ServiceDetailView extends StatefulWidget {
  const ServiceDetailView({
    super.key,
    required this.manager,
    required this.serviceId,
  });

  final Manager manager;
  final String serviceId;

  @override
  State<ServiceDetailView> createState() => _ServiceDetailViewState();
}

class _ServiceDetailViewState extends State<ServiceDetailView> {
  late final _serviceManager = widget.manager.serviceManager;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _serviceManager.getServiceDetail(widget.serviceId);
  }

  void _book() {
    final service = _serviceManager.selectedService;
    if (service == null) return;
    if (!widget.manager.isAuthenticated) {
      _showAuthRequired();
      return;
    }
    context.pushNamed(
      'time_slots',
      pathParameters: {
        'service_id': service.id,
        'beautician_id': service.beautician.id,
      },
    );
  }

  Future<void> _showAuthRequired() async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.lock_outline_rounded,
          color: KBeautyTheme.primary,
          size: 32,
        ),
        title: const Text('Connectez-vous pour réserver'),
        content: const Text(
          'Votre compte permet de sécuriser la réservation et de suivre le rendez-vous.',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
              this.context.go('/signup');
            },
            child: const Text('Inscription'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              this.context.go('/login');
            },
            child: const Text('Connexion'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _serviceManager,
      builder: (context, _) {
        if (_serviceManager.isLoading) {
          return KBeautyPage(
            manager: widget.manager,
            title: 'Détails',
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 120),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final service = _serviceManager.selectedService;
        if (service == null) {
          return KBeautyPage(
            manager: widget.manager,
            title: 'Détails',
            child: KBeautyEmptyState(
              icon: Icons.search_off_rounded,
              title: 'Prestation introuvable',
              message: _serviceManager.lastError ??
                  'Cette prestation n’est plus disponible.',
              action: ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('Retour aux offres'),
              ),
            ),
          );
        }

        return KBeautyPage(
          manager: widget.manager,
          title: 'Détails de la prestation',
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 840;
              final image = _imageGallery(service.images);
              final details = _details();
              if (wide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 6, child: image),
                    const SizedBox(width: 20),
                    Expanded(flex: 5, child: details),
                  ],
                );
              }
              return Column(
                children: [image, const SizedBox(height: 18), details],
              );
            },
          ),
        );
      },
    );
  }

  Widget _imageGallery(List<String> images) {
    return KBeautyCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          height: 460,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (images.isEmpty)
                Container(
                  color: KBeautyTheme.primarySoft,
                  child: const Icon(
                    Icons.spa_outlined,
                    color: KBeautyTheme.primary,
                    size: 70,
                  ),
                )
              else
                PageView.builder(
                  itemCount: images.length,
                  onPageChanged: (index) {
                    setState(() => _currentImageIndex = index);
                  },
                  itemBuilder: (_, index) => Image.network(
                    images[index],
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: KBeautyTheme.primarySoft,
                      child: const Icon(
                        Icons.spa_outlined,
                        color: KBeautyTheme.primary,
                        size: 70,
                      ),
                    ),
                  ),
                ),
              if (images.length > 1)
                Positioned(
                  bottom: 14,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      images.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        width: index == _currentImageIndex ? 22 : 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          color: index == _currentImageIndex
                              ? Colors.white
                              : Colors.white60,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _details() {
    final service = _serviceManager.selectedService!;
    return Column(
      children: [
        KBeautyCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  KBeautyStatusChip(
                    label: service.category,
                    color: KBeautyTheme.primary,
                  ),
                  KBeautyStatusChip(
                    label: '${service.durationMinutes} min',
                    color: KBeautyTheme.lilac,
                    icon: Icons.schedule_rounded,
                  ),
                  KBeautyStatusChip(
                    label: '${service.rating.toStringAsFixed(1)} / 5',
                    color: KBeautyTheme.gold,
                    icon: Icons.star,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                service.title,
                style: const TextStyle(
                  color: KBeautyTheme.text,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                service.description,
                style: const TextStyle(
                  color: KBeautyTheme.muted,
                  fontSize: 14,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Text(
                    '${service.price.toStringAsFixed(0)} €',
                    style: const TextStyle(
                      color: KBeautyTheme.primary,
                      fontSize: 27,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${service.reviewCount} avis',
                    style: const TextStyle(color: KBeautyTheme.muted),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _book,
                  icon: const Icon(Icons.calendar_month_outlined),
                  label: const Text('Réserver un rendez-vous'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        KBeautyCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const KBeautySectionTitle(
                title: 'Votre professionnelle',
                subtitle: 'Profil vérifié et évalué par la communauté.',
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  SizedBox(
                    width: 54,
                    height: 54,
                    child: ClipOval(
                      child:
                          service.beautician.profileImageUrl?.isNotEmpty == true
                              ? Image.network(
                                  service.beautician.profileImageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      const _ProfessionalAvatarFallback(),
                                )
                              : const _ProfessionalAvatarFallback(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                service.beautician.fullName,
                                style: const TextStyle(
                                  color: KBeautyTheme.text,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            if (service.beautician.isVerified) ...[
                              const SizedBox(width: 5),
                              const Icon(
                                Icons.verified,
                                color: KBeautyTheme.primary,
                                size: 17,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${service.beautician.experienceYears} ans d’expérience • ${service.beautician.appointmentCount} rendez-vous',
                          style: const TextStyle(
                            color: KBeautyTheme.muted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (service.beautician.bio?.isNotEmpty == true) ...[
                const SizedBox(height: 14),
                Text(
                  service.beautician.bio!,
                  style: const TextStyle(
                    color: KBeautyTheme.muted,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
              if (service.beautician.specializations.isNotEmpty) ...[
                const SizedBox(height: 14),
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: service.beautician.specializations
                      .map(
                        (item) => KBeautyStatusChip(
                          label: item,
                          color: KBeautyTheme.primary,
                          icon: Icons.auto_awesome_outlined,
                        ),
                      )
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfessionalAvatarFallback extends StatelessWidget {
  const _ProfessionalAvatarFallback();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: KBeautyTheme.primarySoft,
      child: Icon(
        Icons.person_outline,
        color: KBeautyTheme.primary,
        size: 27,
      ),
    );
  }
}
