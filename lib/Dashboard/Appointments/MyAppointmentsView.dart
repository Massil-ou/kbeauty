import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../App/Manager.dart';
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
    return Scaffold(
      appBar: AppBar(title: const Text('Mes rendez-vous')),
      body: ListenableBuilder(
        listenable: _appointmentManager,
        builder: (context, _) => Column(
          children: [
            // Tabs
            Container(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  _TabButton(
                    label: 'À venir',
                    isActive: _activeTab == 'upcoming',
                    onTap: () => setState(() => _activeTab = 'upcoming'),
                  ),
                  const SizedBox(width: 8),
                  _TabButton(
                    label: 'Complétés',
                    isActive: _activeTab == 'completed',
                    onTap: () => setState(() => _activeTab = 'completed'),
                  ),
                ],
              ),
            ),

            Expanded(
              child: _appointmentManager.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _appointmentManager.appointments.isEmpty
                      ? Center(
                          child: Text(
                            _appointmentManager.lastError ??
                                'Aucun rendez-vous',
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _appointmentManager.appointments.length,
                          itemBuilder: (_, idx) {
                            final apt = _appointmentManager.appointments[idx];
                            return _AppointmentCard(
                              appointment: apt,
                              onCancel: apt.status == 'pending_confirmation'
                                  ? () {
                                      // Show cancel dialog
                                    }
                                  : null,
                              onReview: apt.status == 'completed'
                                  ? () {
                                      context.pushNamed(
                                        'write_review',
                                        pathParameters: {
                                          'appointment_id': apt.id,
                                        },
                                      );
                                    }
                                  : null,
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF7C3AED) : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  final VoidCallback? onCancel;
  final VoidCallback? onReview;

  const _AppointmentCard({
    required this.appointment,
    this.onCancel,
    this.onReview,
  });

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pending_confirmation':
        return 'En attente de confirmation';
      case 'confirmed':
        return 'Confirmé';
      case 'completed':
        return 'Complété';
      case 'cancelled':
        return 'Annulé';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending_confirmation':
        return Colors.orange;
      case 'confirmed':
        return Colors.green;
      case 'completed':
        return Colors.grey;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.serviceTitle,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      appointment.client.fullName,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(appointment.status)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _getStatusLabel(appointment.status),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(appointment.status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                '${appointment.scheduledDateTime.day}/${appointment.scheduledDateTime.month}/${appointment.scheduledDateTime.year} à ${appointment.scheduledDateTime.hour.toString().padLeft(2, '0')}:${appointment.scheduledDateTime.minute.toString().padLeft(2, '0')}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  appointment.locationAddress,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (onCancel != null || onReview != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (onCancel != null)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onCancel,
                      child: const Text('Annuler'),
                    ),
                  ),
                if (onReview != null) ...[
                  if (onCancel != null) const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onReview,
                      child: const Text('Évaluer'),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}
