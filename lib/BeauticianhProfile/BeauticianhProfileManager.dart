import 'package:flutter/material.dart';

import '../Shared/Models.dart';
import '../App/Manager.dart';

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
      final response = await _manager.dio.post('/kbeauty/beauticians/profile');
      if (response.data['success'] == true) {
        profile = BeauticianhProfileModel.fromJson(response.data['data']);
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

  Future<bool> updateProfile({
    required String bio,
    required List<String> specializations,
    required int experienceYears,
    required String phone,
    required String profileImageUrl,
  }) async {
    isSaving = true;
    lastError = null;
    notifyListeners();
    try {
      final response = await _manager.dio.post(
        '/kbeauty/beauticians/profile/update',
        data: {
          'bio': bio,
          'specializations': specializations,
          'experience_years': experienceYears,
          'phone': phone,
          'profile_image_url': profileImageUrl,
        },
      );
      if (response.data['success'] == true) {
        await getProfile();
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
}
