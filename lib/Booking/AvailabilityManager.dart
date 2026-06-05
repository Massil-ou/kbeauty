import 'package:flutter/material.dart';

import '../Shared/Models.dart';
import 'Manager.dart';

/// AvailabilityManager handles time slot management
class AvailabilityManager extends ChangeNotifier {
  final Manager _manager;
  AvailabilityManager(this._manager);

  List<AvailabilitySlotModel> slots = [];
  bool isLoading = false;
  String? lastError;

  Future<void> getSlots(String beauticianhId, String date, int duration) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await _manager.dio.post(
        '/kbeauty/availability/get_slots',
        data: {
          'beautician_id': beauticianhId,
          'date': date,
          'duration_minutes': duration,
        },
      );

      if (response.data['success']) {
        final data = response.data['data'];
        slots = (data['slots'] as List?)?.map((s) {
          return AvailabilitySlotModel.fromJson(s);
        }).toList() ?? [];
        lastError = null;
      } else {
        lastError = response.data['message'];
      }
    } catch (e) {
      lastError = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }
}
