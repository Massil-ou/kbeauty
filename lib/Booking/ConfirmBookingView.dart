import 'package:flutter/material.dart';

import '../App/Manager.dart';
import '../Shared/KBeautyTheme.dart';
import '../Shared/KBeautyWidgets.dart';

class ConfirmBookingView extends StatefulWidget {
  const ConfirmBookingView({super.key, required this.manager});

  final Manager manager;

  @override
  State<ConfirmBookingView> createState() => _ConfirmBookingViewState();
}

class _ConfirmBookingViewState extends State<ConfirmBookingView> {
  final _formKey = GlobalKey<FormState>();
  late final _bookingManager = widget.manager.bookingManager;
  final _address = TextEditingController();
  final _city = TextEditingController();
  final _wilaya = TextEditingController();
  final _notes = TextEditingController();

  @override
  void dispose() {
    _address.dispose();
    _city.dispose();
    _wilaya.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final service = widget.manager.serviceManager.selectedService;
    return ListenableBuilder(
      listenable: _bookingManager,
      builder: (context, _) => KBeautyPage(
        manager: widget.manager,
        title: 'Confirmer la réservation',
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const KBeautySectionTitle(
                title: 'Dernière étape',
                subtitle:
                    'Vérifiez le rendez-vous et indiquez l’adresse de la prestation.',
              ),
              const SizedBox(height: 18),
              LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 800;
                  final summary = _summaryCard(service?.title, service?.price);
                  final form = _addressCard();
                  if (wide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 4, child: summary),
                        const SizedBox(width: 18),
                        Expanded(flex: 6, child: form),
                      ],
                    );
                  }
                  return Column(
                    children: [summary, const SizedBox(height: 16), form],
                  );
                },
              ),
              if (_bookingManager.lastError != null) ...[
                const SizedBox(height: 16),
                KBeautyErrorBanner(message: _bookingManager.lastError!),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _bookingManager.isSaving ? null : _submit,
                  icon: _bookingManager.isSaving
                      ? const SizedBox(
                          width: 19,
                          height: 19,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.lock_outline_rounded),
                  label: Text(
                    _bookingManager.isSaving
                        ? 'Création en cours...'
                        : 'Créer la réservation',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryCard(String? title, double? price) {
    return KBeautyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const KBeautySectionTitle(title: 'Votre rendez-vous'),
          const SizedBox(height: 18),
          _line(Icons.spa_outlined, title ?? 'Prestation sélectionnée'),
          _line(
            Icons.calendar_month_outlined,
            '${_bookingManager.selectedDate ?? '-'} à ${_bookingManager.selectedTime ?? '-'}',
          ),
          _line(Icons.schedule_outlined, 'Durée estimée : 60 min'),
          const Divider(height: 28),
          Row(
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  color: KBeautyTheme.text,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Text(
                '${(price ?? 0).toStringAsFixed(0)} €',
                style: const TextStyle(
                  color: KBeautyTheme.primary,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _line(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: KBeautyTheme.primary, size: 18),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: KBeautyTheme.muted,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _addressCard() {
    return KBeautyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const KBeautySectionTitle(
            title: 'Lieu de la prestation',
            subtitle:
                'Ces informations seront partagées avec la professionnelle.',
          ),
          const SizedBox(height: 18),
          TextFormField(
            controller: _address,
            validator: (value) =>
                (value ?? '').trim().isEmpty ? 'L’adresse est requise.' : null,
            decoration: const InputDecoration(
              labelText: 'Adresse complète',
              prefixIcon: Icon(Icons.location_on_outlined),
            ),
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _city,
                  decoration: const InputDecoration(labelText: 'Ville'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: _wilaya,
                  decoration: const InputDecoration(labelText: 'Wilaya'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          TextFormField(
            controller: _notes,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Notes pour la professionnelle',
              hintText: 'Allergies, accès, préférences...',
              alignLabelWithHint: true,
              prefixIcon: Icon(Icons.notes_outlined),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    _bookingManager.clientNotes = _notes.text.trim();
    final booking = await _bookingManager.createBooking(
      serviceId: _bookingManager.selectedServiceId!,
      beauticianhId: _bookingManager.selectedBeauticianhId!,
      scheduledDate: _bookingManager.selectedDate!,
      scheduledTime: _bookingManager.selectedTime!,
      locationAddress: _address.text.trim(),
      locationCity: _city.text.trim().isEmpty ? null : _city.text.trim(),
      locationWilaya: _wilaya.text.trim().isEmpty ? null : _wilaya.text.trim(),
    );
    if (booking != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Réservation créée. Vous pouvez procéder au paiement.'),
        ),
      );
    }
  }
}
