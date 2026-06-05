import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../App/Manager.dart';

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

  DateTime? _selectedDate;
  String? _selectedTime;

  @override
  void initState() {
    super.initState();
    _bookingManager.selectedServiceId = widget.serviceId;
    _bookingManager.selectedBeauticianhId = widget.beauticianhId;
    _selectedDate = DateTime.now().add(const Duration(days: 1));
    _loadSlots();
  }

  void _loadSlots() {
    if (_selectedDate == null) return;
    _availabilityManager.getSlots(
      widget.beauticianhId,
      '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}',
      60,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choisir un créneau')),
      body: ListenableBuilder(
        listenable: Listenable.merge([_bookingManager, _availabilityManager]),
        builder: (context, _) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Picker
              const Text(
                'Sélectionner une date',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 90)),
                    );
                    if (picked != null) {
                      setState(() {
                        _selectedDate = picked;
                        _selectedTime = null;
                      });
                      _loadSlots();
                    }
                  },
                  title: Text(
                    _selectedDate != null
                        ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                        : 'Choisir une date',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                ),
              ),

              const SizedBox(height: 24),

              // Time Slots
              const Text(
                'Créneaux disponibles',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),

              if (_availabilityManager.isLoading)
                const Center(child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ))
              else if (_availabilityManager.slots.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      _availabilityManager.lastError ?? 'Aucun créneau disponible',
                    ),
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: _availabilityManager.slots.length,
                  itemBuilder: (_, idx) {
                    final slot = _availabilityManager.slots[idx];
                    final isSelected = _selectedTime == slot.time;
                    return GestureDetector(
                      onTap: slot.available
                          ? () => setState(() => _selectedTime = slot.time)
                          : null,
                      child: Container(
                        decoration: BoxDecoration(
                          color: slot.available
                              ? isSelected
                                  ? const Color(0xFF7C3AED)
                                  : Colors.grey[100]
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF7C3AED)
                                : Colors.transparent,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            slot.time,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: slot.available
                                  ? isSelected
                                      ? Colors.white
                                      : Colors.black
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

              const SizedBox(height: 32),

              // Next Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _selectedTime != null
                      ? () {
                          _bookingManager.selectedDate =
                              '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';
                          _bookingManager.selectedTime = _selectedTime;
                          context.pushNamed('confirm_booking');
                        }
                      : null,
                  child: const Text('Continuer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
