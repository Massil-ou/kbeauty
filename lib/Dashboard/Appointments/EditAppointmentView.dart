import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../App/Manager.dart';
import '../../Shared/KBeautyTheme.dart';
import '../../Shared/KBeautyWidgets.dart';
import '../../Shared/Models.dart';

class EditAppointmentView extends StatefulWidget {
  const EditAppointmentView({
    super.key,
    required this.manager,
    required this.appointmentId,
  });

  final Manager manager;
  final String appointmentId;

  @override
  State<EditAppointmentView> createState() => _EditAppointmentViewState();
}

class _EditAppointmentViewState extends State<EditAppointmentView> {
  final _formKey = GlobalKey<FormState>();
  late final _appointments = widget.manager.appointmentManager;
  late final _availability = widget.manager.availabilityManager;
  final _address = TextEditingController();
  final _city = TextEditingController();
  final _wilaya = TextEditingController();
  final _commune = TextEditingController();
  final _notes = TextEditingController();
  DateTime? _date;
  String? _time;
  bool _hydrated = false;
  bool _saving = false;

  AppointmentModel? get appointment {
    for (final item in _appointments.appointments) {
      if (item.id == widget.appointmentId) return item;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (_appointments.appointments.isEmpty) {
      await _appointments.listAppointments();
    }
    if (mounted) setState(_hydrate);
  }

  void _hydrate() {
    final item = appointment;
    if (_hydrated || item == null) return;
    _date = item.scheduledDateTime;
    _time =
        '${item.scheduledDateTime.hour.toString().padLeft(2, '0')}:${item.scheduledDateTime.minute.toString().padLeft(2, '0')}';
    _address.text = item.locationAddress;
    _city.text = item.locationCity ?? '';
    _wilaya.text = item.locationWilaya ?? '';
    _commune.text = item.locationCommune ?? '';
    _notes.text = item.clientNotes ?? '';
    _hydrated = true;
    _loadSlots();
  }

  String get _dateValue =>
      '${_date!.year}-${_date!.month.toString().padLeft(2, '0')}-${_date!.day.toString().padLeft(2, '0')}';

  void _loadSlots() {
    final item = appointment;
    if (item == null || _date == null) return;
    _availability.getSlots(
      item.beauticianhId,
      _dateValue,
      item.durationMinutes,
    );
  }

  @override
  void dispose() {
    _address.dispose();
    _city.dispose();
    _wilaya.dispose();
    _commune.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([_appointments, _availability]),
      builder: (context, _) {
        _hydrate();
        final item = appointment;
        return KBeautyPage(
          manager: widget.manager,
          title: 'Modifier le rendez-vous',
          child: item == null
              ? const KBeautyEmptyState(
                  icon: Icons.event_busy_outlined,
                  title: 'Rendez-vous introuvable',
                  message: 'Ce rendez-vous n’est plus disponible.',
                )
              : Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      KBeautySectionTitle(
                        title: item.serviceTitle,
                        subtitle: item.canReschedule
                            ? 'Replanification possible jusqu’à ${item.changeCutoffHours} heures avant le rendez-vous.'
                            : 'Le créneau est verrouillé, mais vous pouvez encore modifier l’adresse et les instructions.',
                      ),
                      const SizedBox(height: 16),
                      KBeautyCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const KBeautySectionTitle(
                              title: 'Nouveau créneau',
                              subtitle:
                                  'Choisissez une date puis un horaire disponible.',
                            ),
                            const SizedBox(height: 14),
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const CircleAvatar(
                                backgroundColor: KBeautyTheme.primarySoft,
                                child: Icon(
                                  Icons.calendar_month_outlined,
                                  color: KBeautyTheme.primary,
                                ),
                              ),
                              title: Text(_dateValue),
                              trailing:
                                  const Icon(Icons.edit_calendar_outlined),
                              onTap: item.canReschedule ? _pickDate : null,
                            ),
                            const SizedBox(height: 12),
                            if (!item.canReschedule)
                              const KBeautyStatusChip(
                                label: 'Créneau verrouillé à moins de 24 h',
                                color: KBeautyTheme.gold,
                                icon: Icons.lock_clock_outlined,
                              )
                            else if (_availability.isLoading)
                              const KBeautySkeletonSlots(count: 8)
                            else
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _availability.slots.map((slot) {
                                  final selected = _time == slot.time;
                                  return ChoiceChip(
                                    selected: selected,
                                    label: Text(slot.time),
                                    onSelected: slot.available || selected
                                        ? (_) =>
                                            setState(() => _time = slot.time)
                                        : null,
                                  );
                                }).toList(),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      KBeautyCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const KBeautySectionTitle(
                              title: 'Adresse et instructions',
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _address,
                              validator: _required,
                              decoration:
                                  const InputDecoration(labelText: 'Adresse'),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _city,
                                    decoration: const InputDecoration(
                                        labelText: 'Ville'),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextFormField(
                                    controller: _wilaya,
                                    decoration: const InputDecoration(
                                      labelText: 'Wilaya',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _notes,
                              maxLines: 4,
                              decoration: const InputDecoration(
                                labelText: 'Notes pour la professionnelle',
                                alignLabelWithHint: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_appointments.lastError != null) ...[
                        const SizedBox(height: 14),
                        KBeautyErrorBanner(message: _appointments.lastError!),
                      ],
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _saving ? null : _save,
                          icon: const Icon(Icons.save_outlined),
                          label: const Text('Enregistrer les modifications'),
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _date!,
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (selected == null) return;
    setState(() {
      _date = selected;
      _time = null;
    });
    _loadSlots();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false) || _time == null) return;
    setState(() => _saving = true);
    final ok = await _appointments.updateAppointment(
      widget.appointmentId,
      scheduledDate: _dateValue,
      scheduledTime: _time,
      locationAddress: _address.text.trim(),
      locationCity: _city.text.trim(),
      locationWilaya: _wilaya.text.trim(),
      locationCommune: _commune.text.trim(),
      clientNotes: _notes.text.trim(),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) context.go('/appointments');
  }

  String? _required(String? value) =>
      (value ?? '').trim().isEmpty ? 'Ce champ est requis.' : null;
}
