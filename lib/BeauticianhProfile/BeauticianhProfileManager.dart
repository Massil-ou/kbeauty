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
}
