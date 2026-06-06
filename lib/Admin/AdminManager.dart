import 'package:flutter/foundation.dart';

import '../App/Manager.dart';

class AdminManager extends ChangeNotifier {
  AdminManager(this._manager);

  final Manager _manager;
  bool isLoading = false;
  String? lastError;
  Map<String, dynamic> summary = {};
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> services = [];
  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> pendingPartners = [];

  Future<void> loadAll() async {
    isLoading = true;
    lastError = null;
    notifyListeners();
    try {
      final responses = await Future.wait([
        _manager.dio.post('/kbeauty/admin/summary'),
        _manager.dio.post('/kbeauty/admin/users/list'),
        _manager.dio.post('/kbeauty/admin/services/list'),
        _manager.dio.post('/kbeauty/admin/categories/list'),
        _manager.dio.post('/kbeauty/admin/partners/list'),
      ]);
      for (final response in responses) {
        if (response.data['success'] != true) {
          throw Exception(response.data['message'] ?? 'Erreur administration');
        }
      }
      summary = Map<String, dynamic>.from(responses[0].data['data'] as Map);
      users = _maps(responses[1].data['data']['users']);
      services = _maps(responses[2].data['data']['services']);
      categories = _maps(responses[3].data['data']['categories']);
      pendingPartners = _maps(responses[4].data['data']['items']);
    } catch (e) {
      lastError = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> reviewPartner(String userId, bool accept) async {
    try {
      final response = await _manager.dio.post(
        '/kbeauty/admin/partners/review',
        data: {'user_id': userId, 'action': accept ? 'approve' : 'reject'},
      );
      if (response.data['success'] == true) {
        await loadAll();
      } else {
        lastError = response.data['message']?.toString();
        notifyListeners();
      }
    } catch (e) {
      lastError = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateUserStatus(String userId, String status) =>
      _updateCutomaUser(
        '/cutoma/admin/users/update_status',
        {'iduser': userId, 'status_user': status},
      );

  Future<void> updateUserRole(String userId, String role) => _updateCutomaUser(
        '/cutoma/admin/users/update_role',
        {'iduser': userId, 'role_user': role},
      );

  Future<void> _updateCutomaUser(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _manager.dio.post(endpoint, data: data);
      if (response.data['success'] == true) {
        await loadAll();
      } else {
        lastError = response.data['message']?.toString();
        notifyListeners();
      }
    } catch (e) {
      lastError = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateServiceStatus(String id, bool active) async {
    try {
      final response = await _manager.dio.post(
        '/kbeauty/admin/services/update_status',
        data: {'service_id': id, 'status': active ? 'active' : 'inactive'},
      );
      if (response.data['success'] == true) {
        await loadAll();
      } else {
        lastError = response.data['message']?.toString();
        notifyListeners();
      }
    } catch (e) {
      lastError = e.toString();
      notifyListeners();
    }
  }

  Future<void> createCategory({
    required String name,
    required String icon,
    String? description,
    int sortOrder = 0,
  }) async {
    await _categoryAction('/kbeauty/admin/categories/create', {
      'name': name,
      'icon': icon,
      'description': description,
      'sortOrder': sortOrder,
    });
  }

  Future<void> updateCategory({
    required String id,
    required String name,
    required String icon,
    String? description,
    int sortOrder = 0,
    bool isActive = true,
  }) async {
    await _categoryAction('/kbeauty/admin/categories/update', {
      'id': id,
      'name': name,
      'icon': icon,
      'description': description,
      'sortOrder': sortOrder,
      'isActive': isActive,
    });
  }

  Future<void> _categoryAction(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _manager.dio.post(endpoint, data: data);
      if (response.data['success'] == true) {
        await loadAll();
      } else {
        lastError = response.data['message']?.toString();
        notifyListeners();
      }
    } catch (e) {
      lastError = e.toString();
      notifyListeners();
    }
  }

  List<Map<String, dynamic>> _maps(dynamic value) => value is List
      ? value
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList()
      : [];
}
