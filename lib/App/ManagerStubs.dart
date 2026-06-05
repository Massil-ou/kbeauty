import 'package:flutter/material.dart';
import '../Shared/Models.dart';
import 'Manager.dart';

/// AvailabilityManager handles time slot fetching and filtering
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
      // API call
      isLoading = false;
      notifyListeners();
    } catch (e) {
      lastError = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }
}

/// AppointmentManager handles appointment lifecycle
class AppointmentManager extends ChangeNotifier {
  final Manager _manager;
  AppointmentManager(this._manager);

  List<AppointmentModel> appointments = [];
  List<AppointmentModel> pendingConfirmations = [];
  bool isLoading = false;
  String? lastError;

  Future<void> listAppointments({String? status}) async {
    isLoading = true;
    notifyListeners();
    try {
      // API call
      isLoading = false;
      notifyListeners();
    } catch (e) {
      lastError = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> confirmAppointment(String appointmentId) async {
    try {
      // API call to confirm
      notifyListeners();
    } catch (e) {
      lastError = e.toString();
    }
  }

  Future<void> declineAppointment(String appointmentId, String reason) async {
    try {
      // API call to decline
      notifyListeners();
    } catch (e) {
      lastError = e.toString();
    }
  }
}

/// BeauticianhProfileManager for beautician profile management
class BeauticianhProfileManager extends ChangeNotifier {
  final Manager _manager;
  BeauticianhProfileManager(this._manager);

  BeauticianhProfileModel? profile;
  bool isLoading = false;
  String? lastError;

  Future<void> getProfile() async {
    isLoading = true;
    notifyListeners();
    try {
      // API call
      isLoading = false;
      notifyListeners();
    } catch (e) {
      lastError = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }
}

/// ReviewManager for service reviews
class ReviewManager extends ChangeNotifier {
  final Manager _manager;
  ReviewManager(this._manager);

  List<ReviewModel> reviews = [];
  bool isLoading = false;
  String? lastError;

  Future<void> submitReview(String appointmentId, int rating, String? comment) async {
    try {
      // API call
      notifyListeners();
    } catch (e) {
      lastError = e.toString();
    }
  }
}
