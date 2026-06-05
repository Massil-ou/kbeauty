import 'package:flutter/material.dart';

import '../../Shared/Models.dart';
import '../../App/Manager.dart';

/// ServiceManager handles searching and browsing beauty services
class ServiceManager extends ChangeNotifier {
  final Manager _manager;

  ServiceManager(this._manager);

  // =========================================================================
  // STATE
  // =========================================================================

  List<ServiceModel> services = [];
  bool isLoading = false;
  bool isSaving = false;
  bool hasMore = false;
  String? lastError;

  ServiceModel? selectedService;
  int _currentPage = 1;

  // =========================================================================
  // SEARCH & BROWSE
  // =========================================================================

  /// Search services by query, category, location
  Future<void> searchServices({
    String? query,
    String? category,
    double? clientLat,
    double? clientLon,
    int radiusKm = 10,
    int page = 1,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await _manager.dio.post(
        '/kbeauty/services/search',
        data: {
          'query': query,
          'category': category,
          'client_lat': clientLat,
          'client_lon': clientLon,
          'radius_km': radiusKm,
          'page': page,
          'limit': 20,
        },
      );

      if (response.data['success']) {
        final data = response.data['data'];
        _currentPage = page;

        // Parse services
        final serviceList = (data['services'] as List?)?.map((s) {
              return ServiceModel.fromJson(s);
            }).toList() ??
            [];

        if (page == 1) {
          services = serviceList;
        } else {
          services.addAll(serviceList);
        }

        hasMore = data['hasMore'] ?? false;
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

  /// Get detailed service information by ID
  Future<void> getServiceDetail(String serviceId) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await _manager.dio.post(
        '/kbeauty/services/getbyid',
        data: {'service_id': serviceId},
      );

      if (response.data['success']) {
        final data = response.data['data'];
        selectedService = ServiceModel.fromJson({
          ...data['service'],
          'beautician': data['beautician'],
        });
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

  /// Load next page of results
  Future<void> loadMore({
    String? query,
    String? category,
  }) async {
    if (!hasMore || isLoading) return;
    await searchServices(
      query: query,
      category: category,
      page: _currentPage + 1,
    );
  }

  /// Clear search results
  void clearSearch() {
    services = [];
    hasMore = false;
    lastError = null;
    _currentPage = 1;
    selectedService = null;
    notifyListeners();
  }

  Future<String?> createService({
    required String title,
    required String description,
    required String category,
    String? subcategory,
    required double price,
    required int durationMinutes,
    List<String> images = const [],
  }) async {
    isSaving = true;
    lastError = null;
    notifyListeners();
    try {
      final response = await _manager.dio.post(
        '/kbeauty/services/create',
        data: {
          'title': title,
          'description': description,
          'category': category,
          'subcategory': subcategory,
          'price': price,
          'duration_minutes': durationMinutes,
          'images': images,
        },
      );
      if (response.data['success'] == true) {
        await searchServices();
        return response.data['data']['serviceId']?.toString();
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
}
