import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../App/Manager.dart';
import '../../Shared/KBeautyTheme.dart';
import '../../Shared/KBeautyWidgets.dart';
import '../../Shared/Models.dart';

class BeauticianhDashboardView extends StatefulWidget {
  const BeauticianhDashboardView({super.key, required this.manager});

  final Manager manager;

  @override
  State<BeauticianhDashboardView> createState() =>
      _BeauticianhDashboardViewState();
}

class _BeauticianhDashboardViewState extends State<BeauticianhDashboardView> {
  late final _appointmentManager = widget.manager.appointmentManager;
  late final _profileManager = widget.manager.beauticianhProfileManager;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await _profileManager.getProfile();
    await _appointmentManager.listAppointments(status: 'pending');
    await _appointmentManager.listAppointments();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([_appointmentManager, _profileManager]),
      builder: (context, _) {
        final profile = _profileManager.profile;
        final confirmed = _appointmentManager.appointments
            .where((item) => item.status == 'confirmed')
            .toList();
        final history = _appointmentManager.appointments
            .where(
              (item) =>
                  item.status == 'completed' || item.status == 'cancelled',
            )
            .toList();
        return KBeautyPage(
          manager: widget.manager,
          title: 'Espace professionnelle',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _welcome(profile?.fullName),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerRight,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => context.go('/beautician/services'),
                      icon: const Icon(Icons.list_alt_outlined),
                      label: const Text('Mes prestations'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => context.go('/beautician/services/new'),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Publier une prestation'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              LayoutBuilder(
                builder: (context, constraints) {
                  final narrow = constraints.maxWidth < 650;
                  final stats = [
                    _StatCard(
                      label: 'En attente',
                      value:
                          '${_appointmentManager.pendingConfirmations.length}',
                      icon: Icons.hourglass_top_rounded,
                      color: KBeautyTheme.gold,
                    ),
                    _StatCard(
                      label: 'Confirmés',
                      value: '${confirmed.length}',
                      icon: Icons.event_available_outlined,
                      color: KBeautyTheme.success,
                    ),
                    _StatCard(
                      label: 'Note moyenne',
                      value: (profile?.rating ?? 0).toStringAsFixed(1),
                      icon: Icons.star_outline_rounded,
                      color: KBeautyTheme.lilac,
                    ),
                  ];
                  return narrow
                      ? Column(
                          children: [
                            for (final stat in stats) ...[
                              stat,
                              const SizedBox(height: 10),
                            ],
                          ],
                        )
                      : Row(
                          children: [
                            for (var i = 0; i < stats.length; i++) ...[
                              Expanded(child: stats[i]),
                              if (i < stats.length - 1)
                                const SizedBox(width: 12),
                            ],
                          ],
                        );
                },
              ),
              const SizedBox(height: 26),
              KBeautySectionTitle(
                title: 'Demandes à confirmer',
                subtitle:
                    '${_appointmentManager.pendingConfirmations.length} demande(s) en attente de votre réponse.',
              ),
              const SizedBox(height: 14),
              if (_appointmentManager.pendingConfirmations.isEmpty)
                const KBeautyEmptyState(
                  icon: Icons.inbox_outlined,
                  title: 'Aucune demande en attente',
                  message: 'Les nouvelles réservations apparaîtront ici.',
                )
              else
                ..._appointmentManager.pendingConfirmations.map(
                  (appointment) => _RequestCard(
                    appointment: appointment,
                    onConfirm: () => _confirm(appointment.id),
                    onDecline: () => _decline(appointment.id),
                  ),
                ),
              const SizedBox(height: 26),
              KBeautySectionTitle(
                title: 'Prochains rendez-vous',
                subtitle: '${confirmed.length} rendez-vous confirmé(s).',
              ),
              const SizedBox(height: 14),
              if (confirmed.isEmpty)
                const KBeautyEmptyState(
                  icon: Icons.calendar_today_outlined,
                  title: 'Aucun rendez-vous confirmé',
                  message: 'Les rendez-vous acceptés seront affichés ici.',
                )
              else
                ...confirmed.map(
                  (appointment) => _ConfirmedCard(
                    appointment,
                    onComplete: () => _complete(appointment.id),
                    onNotes: () => _editNotes(appointment),
                  ),
                ),
              const SizedBox(height: 26),
              KBeautySectionTitle(
                title: 'Historique',
                subtitle:
                    '${history.length} rendez-vous terminé(s) ou annulé(s).',
              ),
              const SizedBox(height: 14),
              if (history.isEmpty)
                const KBeautyEmptyState(
                  icon: Icons.history_rounded,
                  title: 'Historique vide',
                  message: 'Les rendez-vous terminés apparaîtront ici.',
                )
              else
                ...history.take(20).map(_HistoryCard.new),
            ],
          ),
        );
      },
    );
  }

  Widget _welcome(String? name) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [KBeautyTheme.primaryDark, KBeautyTheme.primary],
        ),
        borderRadius: BorderRadius.circular(24),
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
            label: 'Espace professionnelle',
            color: Colors.white,
            icon: Icons.verified_outlined,
          ),
          const SizedBox(height: 15),
          Text(
            name?.trim().isNotEmpty == true
                ? 'Bonjour $name'
                : 'Bonjour ${widget.manager.currentUserName}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Gérez vos demandes et préparez sereinement vos prochains rendez-vous.',
            style: TextStyle(color: Colors.white70, height: 1.45),
          ),
        ],
      ),
    );
  }

  Future<void> _confirm(String appointmentId) async {
    await _appointmentManager.confirmAppointment(appointmentId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rendez-vous confirmé.')),
      );
    }
  }

  Future<void> _decline(String appointmentId) async {
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Décliner le rendez-vous'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Motif',
            alignLabelWithHint: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            style: ElevatedButton.styleFrom(
              backgroundColor: KBeautyTheme.danger,
            ),
            child: const Text('Décliner'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (reason == null) return;
    await _appointmentManager.declineAppointment(appointmentId, reason);
  }

  Future<void> _complete(String appointmentId) async {
    final ok = await _appointmentManager.completeAppointment(appointmentId);
    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rendez-vous marqué comme terminé.')),
      );
    }
  }

  Future<void> _editNotes(AppointmentModel appointment) async {
    final controller = TextEditingController(
      text: appointment.beauticianNotes ?? '',
    );
    final notes = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notes professionnelles'),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: const InputDecoration(
            labelText: 'Notes privées sur le rendez-vous',
            alignLabelWithHint: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (notes == null) return;
    await _appointmentManager.updateAppointment(
      appointment.id,
      beauticianNotes: notes,
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return KBeautyCard(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: KBeautyTheme.text,
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  color: KBeautyTheme.muted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({
    required this.appointment,
    required this.onConfirm,
    required this.onDecline,
  });

  final AppointmentModel appointment;
  final VoidCallback onConfirm;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    return KBeautyCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AppointmentHeader(
            appointment: appointment,
            status: const KBeautyStatusChip(
              label: 'À confirmer',
              color: KBeautyTheme.gold,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onDecline,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: KBeautyTheme.danger,
                  ),
                  child: const Text('Décliner'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: KBeautyTheme.success,
                  ),
                  child: const Text('Confirmer'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ConfirmedCard extends StatelessWidget {
  const _ConfirmedCard(
    this.appointment, {
    required this.onComplete,
    required this.onNotes,
  });

  final AppointmentModel appointment;
  final VoidCallback onComplete;
  final VoidCallback onNotes;

  @override
  Widget build(BuildContext context) {
    return KBeautyCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          _AppointmentHeader(
            appointment: appointment,
            status: const KBeautyStatusChip(
              label: 'Confirmé',
              color: KBeautyTheme.success,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onNotes,
              icon: const Icon(Icons.notes_outlined),
              label: const Text('Ajouter des notes'),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onComplete,
              icon: const Icon(Icons.task_alt_rounded),
              label: const Text('Marquer comme terminé'),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppointmentHeader extends StatelessWidget {
  const _AppointmentHeader({required this.appointment, required this.status});

  final AppointmentModel appointment;
  final Widget status;

  @override
  Widget build(BuildContext context) {
    final date = appointment.scheduledDateTime;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
            color: KBeautyTheme.primarySoft,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.person_outline, color: KBeautyTheme.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                appointment.client.fullName,
                style: const TextStyle(
                  color: KBeautyTheme.text,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                appointment.serviceTitle,
                style: const TextStyle(
                  color: KBeautyTheme.muted,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')} à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} • ${appointment.durationMinutes} min',
                style: const TextStyle(
                  color: KBeautyTheme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        status,
      ],
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard(this.appointment);

  final AppointmentModel appointment;

  @override
  Widget build(BuildContext context) {
    final completed = appointment.status == 'completed';
    return KBeautyCard(
      margin: const EdgeInsets.only(bottom: 10),
      child: _AppointmentHeader(
        appointment: appointment,
        status: KBeautyStatusChip(
          label: completed ? 'Terminé' : 'Annulé',
          color: completed ? KBeautyTheme.lilac : KBeautyTheme.danger,
        ),
      ),
    );
  }
}
