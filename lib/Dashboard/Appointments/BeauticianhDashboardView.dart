import 'package:flutter/material.dart';
import '../App/Manager.dart';
import '../Shared/Models.dart';

class BeauticianhDashboardView extends StatefulWidget {
  const BeauticianhDashboardView({super.key, required this.manager});
  final Manager manager;

  @override
  State<BeauticianhDashboardView> createState() => _BeauticianhDashboardViewState();
}

class _BeauticianhDashboardViewState extends State<BeauticianhDashboardView> {
  late final _appointmentManager = widget.manager.appointmentManager;
  late final _profileManager = widget.manager.beauticianhProfileManager;

  @override
  void initState() {
    super.initState();
    _appointmentManager.listAppointments(status: 'pending');
    _profileManager.getProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mon dashboard')),
      body: ListenableBuilder(
        listenable: Listenable.merge([_appointmentManager, _profileManager]),
        builder: (context, _) => SingleChildScrollView(
          child: Column(
            children: [
              // Stats
              Container(
                padding: const EdgeInsets.all(16),
                color: const Color(0xFF7C3AED),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Aperçu',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _StatBox(
                            title: 'En attente',
                            value: '${_appointmentManager.pendingConfirmations.length}',
                            icon: Icons.hourglass_top,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatBox(
                            title: 'Confirmés',
                            value: '${_appointmentManager.appointments.where((a) => a.status == 'confirmed').length}',
                            icon: Icons.check_circle,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Pending Confirmations
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'En attente de confirmation',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_appointmentManager.pendingConfirmations.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_appointmentManager.pendingConfirmations.isEmpty)
                      Text(
                        'Aucune demande en attente',
                        style: TextStyle(color: Colors.grey[600]),
                      )
                    else
                      Column(
                        children: _appointmentManager.pendingConfirmations
                            .map((apt) => _PendingAppointmentCard(
                              appointment: apt,
                              onConfirm: () async {
                                await _appointmentManager.confirmAppointment(apt.id);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Rendez-vous confirmé!'),
                                    ),
                                  );
                                }
                              },
                              onDecline: () {
                                _showDeclineDialog(context, apt.id);
                              },
                            ))
                            .toList(),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Upcoming Appointments
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rendez-vous confirmés',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_appointmentManager.appointments.isEmpty)
                      Text(
                        'Aucun rendez-vous confirmé',
                        style: TextStyle(color: Colors.grey[600]),
                      )
                    else
                      Column(
                        children: _appointmentManager.appointments
                            .where((a) => a.status == 'confirmed')
                            .map((apt) => _UpcomingAppointmentCard(appointment: apt))
                            .toList(),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeclineDialog(BuildContext context, String appointmentId) {
    final reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Décliner le rendez-vous'),
        content: TextField(
          controller: reasonCtrl,
          decoration: const InputDecoration(
            labelText: 'Raison (optionnel)',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _appointmentManager.declineAppointment(
                appointmentId,
                reasonCtrl.text,
              );
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Rendez-vous décliné')),
                );
              }
            },
            child: const Text('Décliner'),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatBox({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingAppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  final VoidCallback onConfirm;
  final VoidCallback onDecline;

  const _PendingAppointmentCard({
    required this.appointment,
    required this.onConfirm,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.orange,
                ),
                child: const Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.client.fullName,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      appointment.serviceTitle,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${appointment.scheduledDateTime.day}/${appointment.scheduledDateTime.month} à ${appointment.scheduledDateTime.hour.toString().padLeft(2, '0')}:${appointment.scheduledDateTime.minute.toString().padLeft(2, '0')} - ${appointment.durationMinutes} min',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onDecline,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                  ),
                  child: const Text(
                    'Décliner',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
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

class _UpcomingAppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;

  const _UpcomingAppointmentCard({required this.appointment});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green,
            ),
            child: const Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.client.fullName,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(
                  appointment.serviceTitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  '${appointment.scheduledDateTime.day}/${appointment.scheduledDateTime.month} à ${appointment.scheduledDateTime.hour.toString().padLeft(2, '0')}:${appointment.scheduledDateTime.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Icon(Icons.check_circle, color: Colors.green, size: 24),
        ],
      ),
    );
  }
}
