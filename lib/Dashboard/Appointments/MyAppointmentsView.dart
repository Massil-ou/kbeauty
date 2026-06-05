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
  late final _bookingManager = widget.manager.bookingManager;
  String _activeTab = 'upcoming';

  @override
  void initState() {
    super.initState();
    _appointmentManager.listAppointments();
    _bookingManager.listPendingBookings();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([_appointmentManager, _bookingManager]),
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
              if (_activeTab == 'upcoming' &&
                  _bookingManager.pendingBookings.isNotEmpty) ...[
                KBeautySectionTitle(
                  title: 'Paiements en attente',
                  subtitle:
                      '${_bookingManager.pendingBookings.length} réservation(s) à finaliser.',
                ),
                const SizedBox(height: 12),
                ..._bookingManager.pendingBookings.map(_pendingBookingCard),
                const SizedBox(height: 18),
              ],
              if (_appointmentManager.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 80),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (appointments.isEmpty &&
                  !(_activeTab == 'upcoming' &&
                      _bookingManager.pendingBookings.isNotEmpty))
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
                    onEdit: appointment.canEditDetails
                        ? () =>
                            context.go('/appointments/${appointment.id}/edit')
                        : null,
                    onCancel: appointment.canCancel
                        ? () => _cancel(appointment)
                        : null,
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

  Widget _pendingBookingCard(BookingModel booking) => KBeautyCard(
        margin: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: KBeautyTheme.goldSoft,
                  child: Icon(
                    Icons.credit_card_outlined,
                    color: KBeautyTheme.gold,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.serviceTitle,
                        style: const TextStyle(
                          color: KBeautyTheme.text,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        '${booking.beauticianName} • ${booking.totalAmount.toStringAsFixed(2)} €',
                        style: const TextStyle(
                          color: KBeautyTheme.muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const KBeautyStatusChip(
                  label: 'À payer',
                  color: KBeautyTheme.gold,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      await _bookingManager.cancelUnpaidBooking(booking.id);
                      await _bookingManager.listPendingBookings();
                    },
                    child: const Text('Supprimer'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => context.go('/checkout/${booking.id}'),
                    icon: const Icon(Icons.lock_outline_rounded),
                    label: const Text('Payer'),
                  ),
                ),
              ],
            ),
          ],
        ),
      );

  Future<void> _cancel(AppointmentModel appointment) async {
    final reason = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annuler le rendez-vous ?'),
        content: TextField(
          controller: reason,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Motif de l’annulation',
            alignLabelWithHint: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Retour'),
          ),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: KBeautyTheme.danger),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Annuler le rendez-vous'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _appointmentManager.cancelAppointment(
        appointment.id,
        reason.text.trim(),
      );
    }
    reason.dispose();
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
  const _AppointmentCard({
    required this.appointment,
    this.onReview,
    this.onCancel,
    this.onEdit,
  });

  final AppointmentModel appointment;
  final VoidCallback? onReview;
  final VoidCallback? onCancel;
  final VoidCallback? onEdit;

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
                      appointment.beauticianName.isEmpty
                          ? appointment.client.fullName
                          : appointment.beauticianName,
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
          if (onCancel != null) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onCancel,
                style: OutlinedButton.styleFrom(
                  foregroundColor: KBeautyTheme.danger,
                ),
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('Annuler le rendez-vous'),
              ),
            ),
          ],
          if (onEdit != null) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_calendar_outlined),
                label: const Text('Modifier ou replanifier'),
              ),
            ),
          ],
          if (!appointment.canCancel &&
              (appointment.status == 'confirmed' ||
                  appointment.status == 'pending_confirmation')) ...[
            const SizedBox(height: 12),
            Text(
              'Le créneau payé n’est plus replanifiable ni annulable à moins de ${appointment.changeCutoffHours} heures. Les instructions restent modifiables.',
              style: const TextStyle(
                color: KBeautyTheme.muted,
                fontSize: 11,
                height: 1.4,
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
