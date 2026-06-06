import 'package:flutter/material.dart';

import '../App/Manager.dart';
import '../Shared/KBeautyCategoryIcons.dart';
import '../Shared/KBeautyTheme.dart';
import '../Shared/KBeautyWidgets.dart';

class AdminDashboardView extends StatefulWidget {
  const AdminDashboardView({super.key, required this.manager});

  final Manager manager;

  @override
  State<AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<AdminDashboardView> {
  late final _manager = widget.manager.adminManager;

  @override
  void initState() {
    super.initState();
    _manager.loadAll();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _manager,
      builder: (context, _) => KBeautyPage(
        manager: widget.manager,
        title: 'Administration',
        showBack: false,
        actions: [
          IconButton(
            tooltip: 'Actualiser',
            onPressed: _manager.loadAll,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const KBeautySectionTitle(
              title: 'Pilotage keauty',
              subtitle:
                  'Vue d’ensemble, utilisateurs et modération des prestations.',
            ),
            if (_manager.lastError != null) ...[
              const SizedBox(height: 14),
              KBeautyErrorBanner(message: _manager.lastError!),
            ],
            const SizedBox(height: 18),
            if (_manager.isLoading)
              const KBeautySkeletonList(count: 5, compact: true)
            else ...[
              _stats(),
              if (_manager.pendingPartners.isNotEmpty) ...[
                const SizedBox(height: 26),
                KBeautySectionTitle(
                  title: 'Demandes professionnelles',
                  subtitle:
                      '${_manager.pendingPartners.length} dossier(s) à examiner.',
                ),
                const SizedBox(height: 13),
                ..._manager.pendingPartners.map(_partnerRequest),
              ],
              const SizedBox(height: 26),
              KBeautySectionTitle(
                title: 'Catégories',
                subtitle:
                    '${_manager.categories.length} catégorie(s) paramétrable(s). Elles ne se suppriment pas.',
                trailing: ElevatedButton.icon(
                  onPressed: () => _categoryDialog(),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Ajouter'),
                ),
              ),
              const SizedBox(height: 13),
              ..._manager.categories.map(_category),
              const SizedBox(height: 26),
              KBeautySectionTitle(
                title: 'Prestations à modérer',
                subtitle: '${_manager.services.length} prestation(s) au total.',
              ),
              const SizedBox(height: 13),
              ..._manager.services.map(_service),
              const SizedBox(height: 26),
              KBeautySectionTitle(
                title: 'Utilisateurs',
                subtitle: '${_manager.users.length} compte(s) synchronisé(s).',
              ),
              const SizedBox(height: 13),
              KBeautyCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: _manager.users.take(100).map(_user).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _stats() {
    final items = [
      ('Utilisateurs', _manager.summary['users'], Icons.people_alt_outlined),
      ('Professionnelles', _manager.summary['beauticians'], Icons.spa_outlined),
      (
        'Prestations actives',
        _manager.summary['activeServices'],
        Icons.visibility_outlined
      ),
      (
        'Rendez-vous',
        _manager.summary['appointments'],
        Icons.calendar_month_outlined
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900
            ? 4
            : constraints.maxWidth >= 520
                ? 2
                : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 125,
          ),
          itemBuilder: (_, index) {
            final item = items[index];
            return KBeautyCard(
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: KBeautyTheme.primarySoft,
                    child: Icon(item.$3, color: KBeautyTheme.primary),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${item.$2 ?? 0}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: KBeautyTheme.text,
                        ),
                      ),
                      Text(
                        item.$1,
                        style: const TextStyle(
                          color: KBeautyTheme.muted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _category(Map<String, dynamic> category) {
    final active = category['isActive'] != false;
    final iconName = category['icon']?.toString() ?? 'spa';
    return KBeautyCard(
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor:
                active ? KBeautyTheme.primarySoft : KBeautyTheme.divider,
            child: Icon(
              kBeautyCategoryIcon(iconName),
              color: active ? KBeautyTheme.primary : KBeautyTheme.muted,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category['name']?.toString() ?? '',
                  style: const TextStyle(
                    color: KBeautyTheme.text,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  [
                    if ((category['description']?.toString() ?? '').isNotEmpty)
                      category['description'].toString(),
                    'ordre ${category['sortOrder'] ?? 0}',
                    active ? 'active' : 'masquée',
                  ].join(' • '),
                  style:
                      const TextStyle(color: KBeautyTheme.muted, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Modifier',
            onPressed: () => _categoryDialog(category),
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
    );
  }

  Future<void> _categoryDialog([Map<String, dynamic>? category]) async {
    final isEdit = category != null;
    final name = TextEditingController(text: category?['name']?.toString());
    final icon = TextEditingController(
      text: category?['icon']?.toString() ?? 'spa',
    );
    final description = TextEditingController(
      text: category?['description']?.toString() ?? '',
    );
    final sort = TextEditingController(
      text: (category?['sortOrder'] ?? 0).toString(),
    );
    var active = category?['isActive'] != false;

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title:
              Text(isEdit ? 'Modifier la catégorie' : 'Ajouter une catégorie'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: name,
                  decoration: const InputDecoration(
                    labelText: 'Nom',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: icon,
                  decoration: const InputDecoration(
                    labelText: 'Icône',
                    hintText: 'spa, brush, content_cut...',
                    prefixIcon: Icon(Icons.insert_emoticon_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: description,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    prefixIcon: Icon(Icons.notes_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: sort,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Ordre',
                    prefixIcon: Icon(Icons.sort_outlined),
                  ),
                ),
                if (isEdit) ...[
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: active,
                    title: const Text('Disponible pour les partenaires'),
                    subtitle: const Text('Masquer sans supprimer.'),
                    onChanged: (value) => setDialogState(() => active = value),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(isEdit ? 'Enregistrer' : 'Ajouter'),
            ),
          ],
        ),
      ),
    );

    if (saved == true) {
      final payloadName = name.text.trim();
      if (payloadName.isEmpty) return;
      if (isEdit) {
        await _manager.updateCategory(
          id: category['id']?.toString() ?? '',
          name: payloadName,
          icon: icon.text.trim(),
          description: description.text.trim(),
          sortOrder: int.tryParse(sort.text.trim()) ?? 0,
          isActive: active,
        );
      } else {
        await _manager.createCategory(
          name: payloadName,
          icon: icon.text.trim(),
          description: description.text.trim(),
          sortOrder: int.tryParse(sort.text.trim()) ?? 0,
        );
      }
    }

    name.dispose();
    icon.dispose();
    description.dispose();
    sort.dispose();
  }

  Widget _service(Map<String, dynamic> service) {
    final active = service['status'] == 'active';
    return KBeautyCard(
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor:
                active ? KBeautyTheme.primarySoft : KBeautyTheme.divider,
            child: Icon(
              active
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: active ? KBeautyTheme.primary : KBeautyTheme.muted,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service['title']?.toString() ?? '',
                  style: const TextStyle(
                    color: KBeautyTheme.text,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  '${service['beautician_name'] ?? ''} • ${service['category'] ?? ''}',
                  style:
                      const TextStyle(color: KBeautyTheme.muted, fontSize: 12),
                ),
              ],
            ),
          ),
          Switch(
            value: active,
            onChanged: (value) => _manager.updateServiceStatus(
              service['id']?.toString() ?? '',
              value,
            ),
          ),
        ],
      ),
    );
  }

  Widget _partnerRequest(Map<String, dynamic> partner) => KBeautyCard(
        margin: const EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: KBeautyTheme.goldSoft,
                  child: Icon(
                    Icons.workspace_premium_outlined,
                    color: KBeautyTheme.gold,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        partner['company_name']?.toString() ?? 'Dossier pro',
                        style: const TextStyle(
                          color: KBeautyTheme.text,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        '${partner['first_name'] ?? ''} ${partner['last_name'] ?? ''} • ${partner['email'] ?? ''}',
                        style: const TextStyle(
                          color: KBeautyTheme.muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Refuser',
                  color: KBeautyTheme.danger,
                  onPressed: () => _reviewPartner(partner, false),
                  icon: const Icon(Icons.close_rounded),
                ),
                IconButton(
                  tooltip: 'Accepter',
                  color: KBeautyTheme.success,
                  onPressed: () => _reviewPartner(partner, true),
                  icon: const Icon(Icons.check_rounded),
                ),
              ],
            ),
            const SizedBox(height: 13),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if ((partner['trade_name']?.toString() ?? '').isNotEmpty)
                  KBeautyStatusChip(
                    label: partner['trade_name'].toString(),
                    color: KBeautyTheme.primary,
                    icon: Icons.storefront_outlined,
                  ),
                if ((partner['company_type']?.toString() ?? '').isNotEmpty)
                  KBeautyStatusChip(
                    label: partner['company_type'].toString(),
                    color: KBeautyTheme.lilac,
                    icon: Icons.account_balance_outlined,
                  ),
                if ((partner['siret']?.toString() ?? '').isNotEmpty)
                  KBeautyStatusChip(
                    label: 'SIRET ${partner['siret']}',
                    color: KBeautyTheme.muted,
                    icon: Icons.numbers_outlined,
                  ),
                if ((partner['phone']?.toString() ?? '').isNotEmpty)
                  KBeautyStatusChip(
                    label: partner['phone'].toString(),
                    color: KBeautyTheme.muted,
                    icon: Icons.phone_outlined,
                  ),
              ],
            ),
          ],
        ),
      );

  Future<void> _reviewPartner(
    Map<String, dynamic> partner,
    bool approve,
  ) async {
    final company = partner['company_name']?.toString() ?? 'ce dossier';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title:
            Text(approve ? 'Valider le partenaire ?' : 'Refuser la demande ?'),
        content: Text(
          approve
              ? '$company pourra publier et gérer ses prestations keauty.'
              : '$company pourra corriger son dossier puis envoyer une nouvelle demande.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  approve ? KBeautyTheme.success : KBeautyTheme.danger,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(approve ? 'Valider' : 'Refuser'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _manager.reviewPartner(
      partner['iduser']?.toString() ?? '',
      approve,
    );
  }

  Widget _user(Map<String, dynamic> user) {
    final role = user['role']?.toString() ?? 'client';
    return ListTile(
      leading: const CircleAvatar(
        backgroundColor: KBeautyTheme.primarySoft,
        child: Icon(Icons.person_outline, color: KBeautyTheme.primary),
      ),
      title: Text(
        '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}'.trim(),
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
      subtitle: Text(
        '${user['email'] ?? ''} • ${user['status'] ?? ''}',
      ),
      trailing: role == 'admin'
          ? const KBeautyStatusChip(
              label: 'admin',
              color: KBeautyTheme.danger,
            )
          : PopupMenuButton<String>(
              tooltip: 'Gérer le compte',
              onSelected: (action) {
                final id = user['id']?.toString() ?? '';
                switch (action) {
                  case 'active':
                  case 'suspended':
                    _manager.updateUserStatus(id, action);
                  case 'client':
                  case 'partner':
                    _manager.updateUserRole(id, action);
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'active', child: Text('Activer')),
                PopupMenuItem(value: 'suspended', child: Text('Suspendre')),
                PopupMenuDivider(),
                PopupMenuItem(value: 'client', child: Text('Passer client')),
                PopupMenuItem(
                  value: 'partner',
                  child: Text('Passer partenaire'),
                ),
              ],
              child: KBeautyStatusChip(
                label: role,
                color: role == 'beautician'
                    ? KBeautyTheme.primary
                    : KBeautyTheme.muted,
                icon: Icons.more_horiz_rounded,
              ),
            ),
    );
  }
}
