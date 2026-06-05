import 'package:flutter/material.dart';

import '../Shared/Models.dart';
import '../App/Manager.dart';

/// BookingManager handles creating and managing bookings
class BookingManager extends ChangeNotifier {
  final Manager _manager;

  BookingManager(this._manager);

  // =========================================================================
  // STATE
  // =========================================================================

  BookingModel? currentBooking;
  List<AvailabilitySlotModel> availableSlots = [];
  bool isLoading = false;
  bool isSaving = false;
  String? lastError;

  // Selected values for current booking
  String? selectedServiceId;
  String? selectedBeauticianhId;
  String? selectedDate;
  String? selectedTime;
  String? clientNotes;

  // =========================================================================
  // AVAILABILITY
  // =========================================================================

  /// Get available time slots for a service and date
  Future<void> getAvailableSlots({
    required String beauticianhId,
    required String date,
    required int durationMinutes,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await _manager.dio.post(
        '/kbeauty/availability/get_slots',
        data: {
          'beautician_id': beauticianhId,
          'date': date,
          'service_id': selectedServiceId,
        },
      );

      if (response.data['success']) {
        final data = response.data['data'];
        availableSlots = (data['slots'] as List?)?.map((s) {
              return AvailabilitySlotModel.fromJson(s);
            }).toList() ??
            [];
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

  // =========================================================================
  // BOOKING CREATION
  // =========================================================================

  /// Create a new booking
  Future<BookingModel?> createBooking({
    required String serviceId,
    required String beauticianhId,
    required String scheduledDate,
    required String scheduledTime,
    required String locationAddress,
    String? locationCity,
    String? locationWilaya,
    String? locationCommune,
  }) async {
    isSaving = true;
    notifyListeners();

    try {
      final response = await _manager.dio.post(
        '/kbeauty/bookings/create',
        data: {
          'service_id': serviceId,
          'beautician_id': beauticianhId,
          'scheduled_date': scheduledDate,
          'scheduled_time': scheduledTime,
          'location_address': locationAddress,
          'location_city': locationCity,
          'location_wilaya': locationWilaya,
          'location_commune': locationCommune,
        },
      );

      if (response.data['success']) {
        currentBooking = BookingModel.fromJson(response.data['data']);
        lastError = null;
        isSaving = false;
        notifyListeners();
        return currentBooking;
      } else {
        lastError = response.data['message'];
      }
    } catch (e) {
      lastError = e.toString();
    }

    isSaving = false;
    notifyListeners();
    return null;
  }

  /// Reset booking form
  void resetBooking() {
    currentBooking = null;
    selectedServiceId = null;
    selectedBeauticianhId = null;
    selectedDate = null;
    selectedTime = null;
    clientNotes = null;
    availableSlots = [];
    lastError = null;
    notifyListeners();
  }
}
