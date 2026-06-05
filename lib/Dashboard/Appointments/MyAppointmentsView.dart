import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../App/Manager.dart';
import '../../Shared/KBeautyTheme.dart';
import '../../Shared/KBeautyWidgets.dart';
import '../../Shared/Models.dart';

class MyAppointmentsView extends StatefulWidget {
  const MyAppointmentsView({super.key, required this.manager});

  final Manager manager;

  @override
  State<MyAppointmentsView> createState() => _MyAppointmentsViewState();
}

class _MyAppointmentsViewState extends State<MyAppointmentsView> {
  late final _appointmentManager = widget.manager.appointmentManager;
  String _activeTab = 'upcoming';

  @override
  void initState() {
    super.initState();
    _appointmentManager.listAppointments();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _appointmentManager,
      builder: (context, _) {
        final appointments = _appointmentManager.appointments.where((item) {
          if (_activeTab == 'completed') {
            return item.status == 'completed' || item.status == 'cancelled';
          }
          return item.status != 'completed' && item.status != 'cancelled';
        }).toList();

        return KBeautyPage(
          manager: widget.manager,
          title: 'Mes rendez-vous',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const KBeautySectionTitle(
                title: 'Mes rendez-vous',
                subtitle:
                    'Suivez vos demandes et retrouvez vos prestations passées.',
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(5),
                decoration: KBeautyTheme.softDecoration(radius: 16),
                child: Row(
                  children: [
                    _TabButton(
                      label: 'À venir',
                      active: _activeTab == 'upcoming',
                      onTap: () => setState(() => _activeTab = 'upcoming'),
                    ),
                    _TabButton(
                      label: 'Historique',
                      active: _activeTab == 'completed',
                      onTap: () => setState(() => _activeTab = 'completed'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              if (_appointmentManager.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 80),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (appointments.isEmpty)
                KBeautyEmptyState(
                  icon: Icons.calendar_today_outlined,
                  title: 'Aucun rendez-vous',
                  message: _appointmentManager.lastError ??
                      'Vos rendez-vous apparaîtront ici après réservation.',
                  action: ElevatedButton(
                    onPressed: () => context.go('/'),
                    child: const Text('Découvrir les prestations'),
                  ),
                )
              else
                ...appointments.map(
                  (appointment) => _AppointmentCard(
                    appointment: appointment,
                    onReview: appointment.status == 'completed'
                        ? () => context.pushNamed(
                              'write_review',
                              pathParameters: {
                                'appointment_id': appointment.id,
                              },
                            )
                        : null,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: KBeautyTheme.primaryDark.withValues(alpha: 0.08),
                      blurRadius: 10,
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: active ? KBeautyTheme.primary : KBeautyTheme.muted,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({required this.appointment, this.onReview});

  final AppointmentModel appointment;
  final VoidCallback? onReview;

  @override
  Widget build(BuildContext context) {
    final color = switch (appointment.status) {
      'confirmed' => KBeautyTheme.success,
      'completed' => KBeautyTheme.lilac,
      'cancelled' => KBeautyTheme.danger,
      _ => KBeautyTheme.gold,
    };
    final label = switch (appointment.status) {
      'confirmed' => 'Confirmé',
      'completed' => 'Complété',
      'cancelled' => 'Annulé',
      _ => 'En attente',
    };
    final date = appointment.scheduledDateTime;

    return KBeautyCard(
      margin: const EdgeInsets.only(bottom: 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.spa_outlined, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.serviceTitle,
                      style: const TextStyle(
                        color: KBeautyTheme.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      appointment.client.fullName,
                      style: const TextStyle(
                        color: KBeautyTheme.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              KBeautyStatusChip(label: label, color: color),
            ],
          ),
          const Divider(height: 26),
          Wrap(
            spacing: 18,
            runSpacing: 9,
            children: [
              _Info(
                icon: Icons.calendar_month_outlined,
                label:
                    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
              ),
              _Info(
                icon: Icons.schedule_outlined,
                label: '${appointment.durationMinutes} min',
              ),
              _Info(
                icon: Icons.location_on_outlined,
                label: appointment.locationAddress,
              ),
            ],
          ),
          if (onReview != null) ...[
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onReview,
                icon: const Icon(Icons.star_outline_rounded),
                label: const Text('Évaluer la prestation'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Info extends StatelessWidget {
  const _Info({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: KBeautyTheme.primary, size: 17),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(color: KBeautyTheme.muted, fontSize: 12),
        ),
      ],
    );
  }
}
