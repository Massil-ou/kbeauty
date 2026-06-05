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
  List<BookingModel> pendingBookings = [];
  List<AvailabilitySlotModel> availableSlots = [];
  bool isLoading = false;
  bool isSaving = false;
  String? lastError;
  StripeCheckoutModel? checkout;
  bool isVerifying = false;

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
          'client_notes': clientNotes,
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

  Future<BookingModel?> getBooking(String bookingId) async {
    isLoading = true;
    lastError = null;
    notifyListeners();
    try {
      final response = await _manager.dio.post(
        '/kbeauty/bookings/get',
        data: {'booking_id': bookingId},
      );
      if (response.data['success'] == true) {
        currentBooking = BookingModel.fromJson(response.data['data']);
        return currentBooking;
      }
      lastError = response.data['message']?.toString();
    } catch (e) {
      lastError = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
    return null;
  }

  Future<void> listPendingBookings() async {
    isLoading = true;
    lastError = null;
    notifyListeners();
    try {
      final response = await _manager.dio.post('/kbeauty/bookings/list');
      if (response.data['success'] == true) {
        pendingBookings = (response.data['data']['bookings'] as List? ?? [])
            .whereType<Map>()
            .map((item) =>
                BookingModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      } else {
        lastError = response.data['message']?.toString();
      }
    } catch (e) {
      lastError = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<StripeCheckoutModel?> createStripeCheckout(String bookingId) async {
    isSaving = true;
    lastError = null;
    notifyListeners();
    try {
      final response = await _manager.dio.post(
        '/kbeauty/stripe/create_checkout',
        data: {'booking_id': bookingId},
      );
      if (response.data['success'] == true) {
        checkout = StripeCheckoutModel.fromJson(response.data['data']);
        return checkout;
      }
      lastError = response.data['message']?.toString();
    } catch (e) {
      lastError = e.toString();
    } finally {
      isSaving = false;
      notifyListeners();
    }
    return null;
  }

  Future<bool> verifyPayment(String bookingId) async {
    isVerifying = true;
    lastError = null;
    notifyListeners();
    try {
      final response = await _manager.dio.post(
        '/kbeauty/stripe/verify_payment',
        data: {'booking_id': bookingId},
      );
      if (response.data['success'] == true) {
        final status = response.data['data']['paymentStatus']?.toString();
        if (status == 'paid') {
          await getBooking(bookingId);
          return true;
        }
        lastError =
            response.data['message']?.toString() ?? 'Paiement en cours.';
      } else {
        lastError = response.data['message']?.toString();
      }
    } catch (e) {
      lastError = e.toString();
    } finally {
      isVerifying = false;
      notifyListeners();
    }
    return false;
  }

  Future<bool> cancelUnpaidBooking(String bookingId) async {
    isSaving = true;
    lastError = null;
    notifyListeners();
    try {
      final response = await _manager.dio.post(
        '/kbeauty/bookings/cancel',
        data: {'booking_id': bookingId},
      );
      if (response.data['success'] == true) {
        pendingBookings.removeWhere((item) => item.id == bookingId);
        return true;
      }
      lastError = response.data['message']?.toString();
    } catch (e) {
      lastError = e.toString();
    } finally {
      isSaving = false;
      notifyListeners();
    }
    return false;
  }

  /// Reset booking form
  void resetBooking() {
    currentBooking = null;
    checkout = null;
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
