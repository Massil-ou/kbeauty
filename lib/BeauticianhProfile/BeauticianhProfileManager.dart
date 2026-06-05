import 'package:flutter/material.dart';

import '../Shared/Models.dart';
import 'Manager.dart';

/// BeauticianhProfileManager for beautician profile management
class BeauticianhProfileManager extends ChangeNotifier {
  final Manager _manager;
  BeauticianhProfileManager(this._manager);

  BeauticianhProfileModel? profile;
  bool isLoading = false;
  bool isSaving = false;
  String? lastError;

  Future<void> getProfile() async {
    isLoading = true;
    notifyListeners();

    try {
      // Simulated profile - in production would fetch from API
      profile = BeauticianhProfileModel(
        id: 'beautician-1',
        firstName: 'Fatima',
        lastName: 'Ben',
        email: 'fatima@example.com',
        bio: 'Coiffeuse professionnelle avec 5 ans d\'expérience',
        specializations: ['haircut', 'coloring', 'styling'],
        experienceYears: 5,
        rating: 4.8,
        appointmentCount: 127,
        isVerified: true,
      );
      lastError = null;
    } catch (e) {
      lastError = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }
}
