import 'package:flutter/foundation.dart';

import '../App/Manager.dart';

class AccountManager extends ChangeNotifier {
  AccountManager(this._manager);

  final Manager _manager;
  bool isLoading = false;
  bool isSaving = false;
  String? lastError;
  Map<String, dynamic>? proProfile;

  String get proStatus =>
      proProfile?['status_pro']?.toString().trim().toLowerCase() ?? '';
  bool get hasProProfile => proProfile != null;
  bool get isProPending => proStatus == 'pending';
  bool get isProApproved => proStatus == 'approved' || proStatus == 'verified';
  bool get isProRejected => proStatus == 'rejected';
  bool get canEditProProfile => !isProPending;

  Future<bool> updatePersonalProfile({
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    isSaving = true;
    lastError = null;
    notifyListeners();
    try {
      final response = await _manager.dio.post(
        '/cutoma/client/profile/update',
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'number': phone,
        },
      );
      if (response.data['success'] == true) {
        await _manager.updateLocalProfile(
          firstName: firstName,
          lastName: lastName,
          phone: phone,
        );
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

  Future<void> loadProProfile() async {
    isLoading = true;
    lastError = null;
    notifyListeners();
    try {
      final response = await _manager.dio.post(
        '/kbeauty/partners/application/get',
        data: const {},
      );
      if (response.data['success'] == true) {
        final data = response.data['data'];
        proProfile = data is Map && data['profile'] is Map
            ? Map<String, dynamic>.from(data['profile'] as Map)
            : null;
        if (data is Map &&
            data['isPartner'] == true &&
            !_manager.isBeauticianhRole) {
          await _manager
              .updateLocalRole(data['role']?.toString() ?? 'beautician');
        }
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

  Future<bool> saveProProfile(Map<String, dynamic> data) async {
    isSaving = true;
    lastError = null;
    notifyListeners();
    try {
      final response = await _manager.dio.post(
        '/kbeauty/partners/application/save',
        data: data,
      );
      if (response.data['success'] == true) {
        final payload = response.data['data'];
        proProfile = payload is Map && payload['profile'] is Map
            ? Map<String, dynamic>.from(payload['profile'] as Map)
            : proProfile;
        if (payload is Map &&
            payload['isPartner'] == true &&
            !_manager.isBeauticianhRole) {
          await _manager
              .updateLocalRole(payload['role']?.toString() ?? 'beautician');
        }
        notifyListeners();
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
