import 'package:flutter/material.dart';

import '../App/Manager.dart';
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
              title: 'Pilotage kBeauty',
              subtitle:
                  'Vue d’ensemble, utilisateurs et modération des prestations.',
            ),
            if (_manager.lastError != null) ...[
              const SizedBox(height: 14),
              KBeautyErrorBanner(message: _manager.lastError!),
            ],
            const SizedBox(height: 18),
            if (_manager.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(70),
                  child: CircularProgressIndicator(),
                ),
              )
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
        child: Row(
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
                    '${partner['prenom'] ?? ''} ${partner['nom'] ?? ''} • ${partner['email'] ?? ''}',
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
              onPressed: () => _manager.reviewPartner(
                partner['iduser']?.toString() ?? '',
                false,
              ),
              icon: const Icon(Icons.close_rounded),
            ),
            IconButton(
              tooltip: 'Accepter',
              color: KBeautyTheme.success,
              onPressed: () => _manager.reviewPartner(
                partner['iduser']?.toString() ?? '',
                true,
              ),
              icon: const Icon(Icons.check_rounded),
            ),
          ],
        ),
      );

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
