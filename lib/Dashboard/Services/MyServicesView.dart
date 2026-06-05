import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../App/Manager.dart';
import '../../Shared/KBeautyTheme.dart';
import '../../Shared/KBeautyWidgets.dart';
import '../../Shared/Models.dart';

class MyServicesView extends StatefulWidget {
  const MyServicesView({super.key, required this.manager});

  final Manager manager;

  @override
  State<MyServicesView> createState() => _MyServicesViewState();
}

class _MyServicesViewState extends State<MyServicesView> {
  late final _manager = widget.manager.serviceManager;

  @override
  void initState() {
    super.initState();
    _manager.listMine();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _manager,
      builder: (context, _) => KBeautyPage(
        manager: widget.manager,
        title: 'Mes prestations',
        actions: [
          IconButton(
            tooltip: 'Ajouter',
            onPressed: () => context.go('/beautician/services/new'),
            icon: const Icon(Icons.add_circle_outline_rounded),
          ),
        ],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            KBeautySectionTitle(
              title: 'Gestion des prestations',
              subtitle:
                  '${_manager.ownServices.length} prestation(s). Modifiez leur contenu et leur visibilité.',
              trailing: ElevatedButton.icon(
                onPressed: () => context.go('/beautician/services/new'),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Ajouter'),
              ),
            ),
            if (_manager.lastError != null) ...[
              const SizedBox(height: 14),
              KBeautyErrorBanner(message: _manager.lastError!),
            ],
            const SizedBox(height: 18),
            if (_manager.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(60),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_manager.ownServices.isEmpty)
              KBeautyEmptyState(
                icon: Icons.list_alt_outlined,
                title: 'Aucune prestation publiée',
                message: 'Ajoutez votre première prestation pour être visible.',
                action: ElevatedButton(
                  onPressed: () => context.go('/beautician/services/new'),
                  child: const Text('Publier une prestation'),
                ),
              )
            else
              ..._manager.ownServices.map(_serviceCard),
          ],
        ),
      ),
    );
  }

  Widget _serviceCard(ServiceModel service) {
    return KBeautyCard(
      margin: const EdgeInsets.only(bottom: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: 92,
              height: 92,
              child: service.images.isEmpty
                  ? const ColoredBox(
                      color: KBeautyTheme.primarySoft,
                      child:
                          Icon(Icons.spa_outlined, color: KBeautyTheme.primary),
                    )
                  : Image.network(
                      service.images.first,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const ColoredBox(
                        color: KBeautyTheme.primarySoft,
                        child: Icon(Icons.broken_image_outlined),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      service.title,
                      style: const TextStyle(
                        color: KBeautyTheme.text,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    KBeautyStatusChip(
                      label: service.isVisible ? 'Visible' : 'Masquée',
                      color: service.isVisible
                          ? KBeautyTheme.success
                          : KBeautyTheme.muted,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${service.category} • ${service.durationMinutes} min • ${service.price.toStringAsFixed(0)} €',
                  style:
                      const TextStyle(color: KBeautyTheme.muted, fontSize: 12),
                ),
                const SizedBox(height: 13),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => context.go(
                        '/beautician/services/${service.id}/edit',
                      ),
                      icon: const Icon(Icons.edit_outlined, size: 17),
                      label: const Text('Modifier'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _manager.toggleVisibility(service),
                      icon: Icon(
                        service.isVisible
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 17,
                      ),
                      label: Text(service.isVisible ? 'Masquer' : 'Afficher'),
                    ),
                    IconButton(
                      tooltip: 'Supprimer',
                      color: KBeautyTheme.danger,
                      onPressed: () => _delete(service),
                      icon: const Icon(Icons.delete_outline_rounded),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _delete(ServiceModel service) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la prestation ?'),
        content: Text(
          '« ${service.title} » sera supprimée ou archivée si elle possède un historique.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: KBeautyTheme.danger),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirmed == true) await _manager.deleteService(service.id);
  }
}
