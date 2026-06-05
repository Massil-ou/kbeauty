import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../App/Manager.dart';

class ConfirmBookingView extends StatefulWidget {
  const ConfirmBookingView({super.key, required this.manager});
  final Manager manager;

  @override
  State<ConfirmBookingView> createState() => _ConfirmBookingViewState();
}

class _ConfirmBookingViewState extends State<ConfirmBookingView> {
  late final _bookingManager = widget.manager.bookingManager;
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _wilayaCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confirmer la réservation')),
      body: ListenableBuilder(
        listenable: _bookingManager,
        builder: (context, _) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Résumé',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Date & Heure:'),
                        Text(
                          '${_bookingManager.selectedDate} ${_bookingManager.selectedTime}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Durée:'),
                        Text('60 min', style: const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Montant:'),
                        Text(
                          '€0.00',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF7C3AED),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Location Form
              const Text(
                'Lieu du rendez-vous',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _addressCtrl,
                decoration: InputDecoration(
                  labelText: 'Adresse *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _cityCtrl,
                      decoration: InputDecoration(
                        labelText: 'Ville',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _wilayaCtrl,
                      decoration: InputDecoration(
                        labelText: 'Wilaya',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Notes
              const Text(
                'Notes (optionnel)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _notesCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Ajouter une note...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: 'Ex: Préférence de coiffure, allergies, etc.',
                ),
              ),

              const SizedBox(height: 32),

              // Error
              if (_bookingManager.lastError != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Text(
                    _bookingManager.lastError!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),

              const SizedBox(height: 16),

              // Book Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _bookingManager.isSaving
                      ? null
                      : () async {
                          if (_addressCtrl.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('L\'adresse est requise'),
                              ),
                            );
                            return;
                          }

                          _bookingManager.clientNotes = _notesCtrl.text;
                          final booking = await _bookingManager.createBooking(
                            serviceId: _bookingManager.selectedServiceId!,
                            beauticianhId: _bookingManager.selectedBeauticianhId!,
                            scheduledDate: _bookingManager.selectedDate!,
                            scheduledTime: _bookingManager.selectedTime!,
                            locationAddress: _addressCtrl.text,
                            locationCity: _cityCtrl.text.isEmpty ? null : _cityCtrl.text,
                            locationWilaya: _wilayaCtrl.text.isEmpty ? null : _wilayaCtrl.text,
                          );

                          if (booking != null) {
                            if (mounted) {
                              // Go to payment
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Réservation créée! Procédez au paiement.'),
                                ),
                              );
                              // TODO: Navigate to payment
                            }
                          }
                        },
                  child: _bookingManager.isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Procéder au paiement'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _wilayaCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }
}
