import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../App/Manager.dart';
import '../Shared/KBeautyTheme.dart';
import '../Shared/KBeautyWidgets.dart';

class TimeSlotPickerView extends StatefulWidget {
  const TimeSlotPickerView({
    super.key,
    required this.manager,
    required this.serviceId,
    required this.beauticianhId,
  });

  final Manager manager;
  final String serviceId;
  final String beauticianhId;

  @override
  State<TimeSlotPickerView> createState() => _TimeSlotPickerViewState();
}

class _TimeSlotPickerViewState extends State<TimeSlotPickerView> {
  late final _bookingManager = widget.manager.bookingManager;
  late final _availabilityManager = widget.manager.availabilityManager;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String? _selectedTime;

  @override
  void initState() {
    super.initState();
    _bookingManager.selectedServiceId = widget.serviceId;
    _bookingManager.selectedBeauticianhId = widget.beauticianhId;
    _loadSlots();
  }

  String get _dateValue =>
      '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

  void _loadSlots() {
    _availabilityManager.getSlots(widget.beauticianhId, _dateValue, 60);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked == null) return;
    setState(() {
      _selectedDate = picked;
      _selectedTime = null;
    });
    _loadSlots();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([_bookingManager, _availabilityManager]),
      builder: (context, _) => KBeautyPage(
        manager: widget.manager,
        title: 'Choisir un créneau',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const KBeautySectionTitle(
              title: 'Planifiez votre rendez-vous',
              subtitle:
                  'Choisissez une date puis un créneau encore disponible.',
            ),
            const SizedBox(height: 18),
            KBeautyCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                onTap: _pickDate,
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: KBeautyTheme.primarySoft,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.calendar_month_outlined,
                    color: KBeautyTheme.primary,
                  ),
                ),
                title: const Text(
                  'Date du rendez-vous',
                  style: TextStyle(
                    color: KBeautyTheme.muted,
                    fontSize: 12,
                  ),
                ),
                subtitle: Text(
                  '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                  style: const TextStyle(
                    color: KBeautyTheme.text,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                trailing: const Icon(
                  Icons.edit_calendar_outlined,
                  color: KBeautyTheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 18),
            KBeautyCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const KBeautySectionTitle(
                    title: 'Créneaux disponibles',
                    subtitle: 'Les horaires grisés ne sont plus disponibles.',
                  ),
                  const SizedBox(height: 18),
                  if (_availabilityManager.isLoading)
                    const KBeautySkeletonSlots()
                  else if (_availabilityManager.slots.isEmpty)
                    KBeautyEmptyState(
                      icon: Icons.event_busy_outlined,
                      title: 'Aucun créneau ce jour',
                      message: _availabilityManager.lastError ??
                          'Sélectionnez une autre date pour continuer.',
                      action: OutlinedButton(
                        onPressed: _pickDate,
                        child: const Text('Changer de date'),
                      ),
                    )
                  else
                    Wrap(
                      spacing: 9,
                      runSpacing: 9,
                      children: _availabilityManager.slots.map((slot) {
                        final selected = _selectedTime == slot.time;
                        return ChoiceChip(
                          selected: selected,
                          label: Text(slot.time),
                          onSelected: slot.available
                              ? (_) => setState(() => _selectedTime = slot.time)
                              : null,
                          selectedColor: KBeautyTheme.primary,
                          backgroundColor: KBeautyTheme.primarySoft,
                          disabledColor: KBeautyTheme.divider,
                          labelStyle: TextStyle(
                            color: selected
                                ? Colors.white
                                : slot.available
                                    ? KBeautyTheme.primaryDark
                                    : KBeautyTheme.muted,
                            fontWeight: FontWeight.w800,
                          ),
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _selectedTime == null
                    ? null
                    : () {
                        _bookingManager.selectedDate = _dateValue;
                        _bookingManager.selectedTime = _selectedTime;
                        context.pushNamed('confirm_booking');
                      },
                icon: const Icon(Icons.arrow_forward_rounded),
                label: const Text('Continuer vers la réservation'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
