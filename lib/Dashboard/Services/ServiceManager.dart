import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../Shared/Models.dart';
import '../../App/Manager.dart';

/// ServiceManager handles searching and browsing beauty services
class ServiceManager extends ChangeNotifier {
  static const int maxImageBytes = 40 * 1024 * 1024;

  final Manager _manager;

  ServiceManager(this._manager);

  // =========================================================================
  // STATE
  // =========================================================================

  List<ServiceModel> services = [];
  List<ServiceModel> featuredServices = [];
  List<ServiceModel> ownServices = [];
  List<ServiceCategoryModel> categories = [];
  bool isLoading = false;
  bool isLoadingFeatured = false;
  bool isLoadingCategories = false;
  bool isSaving = false;
  bool hasMore = false;
  String? lastError;

  ServiceModel? selectedService;
  String? activeSearchCity;
  int _currentPage = 1;

  // =========================================================================
  // SEARCH & BROWSE
  // =========================================================================

  Future<void> loadCategories() async {
    if (isLoadingCategories) return;
    isLoadingCategories = true;
    notifyListeners();
    try {
      final response = await _manager.dio.post('/kbeauty/categories/list');
      if (response.data['success'] == true) {
        categories = (response.data['data']['categories'] as List? ?? [])
            .whereType<Map>()
            .map((item) => ServiceCategoryModel.fromJson(
                  Map<String, dynamic>.from(item),
                ))
            .where((item) => item.name.trim().isNotEmpty)
            .toList();
        lastError = null;
      } else {
        lastError = response.data['message']?.toString();
      }
    } catch (e) {
      lastError = e.toString();
    } finally {
      isLoadingCategories = false;
      notifyListeners();
    }
  }

  Future<void> loadFeaturedServices() async {
    if (isLoadingFeatured) return;
    isLoadingFeatured = true;
    notifyListeners();
    try {
      final response = await _manager.dio.post(
        '/kbeauty/services/featured',
        data: {'limit': 8},
      );
      if (response.data['success'] == true) {
        featuredServices = (response.data['data']['services'] as List? ?? [])
            .whereType<Map>()
            .map((item) =>
                ServiceModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
        lastError = null;
      } else {
        lastError = response.data['message']?.toString();
      }
    } catch (e) {
      lastError = e.toString();
    } finally {
      isLoadingFeatured = false;
      notifyListeners();
    }
  }

  /// Search services by query, category, location
  Future<void> searchServices({
    String? query,
    String? category,
    String? city,
    double? clientLat,
    double? clientLon,
    int radiusKm = 10,
    int page = 1,
  }) async {
    isLoading = true;
    if (city?.trim().isNotEmpty == true) {
      activeSearchCity = city!.trim();
    }
    notifyListeners();

    try {
      final response = await _manager.dio.post(
        '/kbeauty/services/search',
        data: {
          'query': query,
          'category': category,
          'city': activeSearchCity,
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
    String? city,
  }) async {
    if (!hasMore || isLoading) return;
    await searchServices(
      query: query,
      category: category,
      city: city ?? activeSearchCity,
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
    activeSearchCity = null;
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
        await listMine();
        if (activeSearchCity?.isNotEmpty == true) {
          await searchServices(city: activeSearchCity);
        }
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

  Future<String?> uploadImage({
    required Uint8List bytes,
    required String filename,
    required String purpose,
  }) async {
    lastError = null;
    if (bytes.length > maxImageBytes) {
      lastError = 'Image trop volumineuse. Taille maximale : 40 Mo par image.';
      notifyListeners();
      return null;
    }
    try {
      final response = await _manager.dio.post(
        '/kbeauty/uploads/image',
        data: FormData.fromMap({
          'purpose': purpose,
          'image': MultipartFile.fromBytes(bytes, filename: filename),
        }),
      );
      if (response.data['success'] == true) {
        final data = response.data['data'] is Map
            ? Map<String, dynamic>.from(response.data['data'] as Map)
            : <String, dynamic>{};
        return data['url']?.toString();
      }
      lastError = response.data['message']?.toString();
    } catch (e) {
      lastError = e.toString();
    } finally {
      notifyListeners();
    }
    return null;
  }

  Future<void> listMine() async {
    isLoading = true;
    lastError = null;
    notifyListeners();
    try {
      final response = await _manager.dio.post('/kbeauty/services/mine');
      if (response.data['success'] == true) {
        ownServices = (response.data['data']['services'] as List? ?? [])
            .whereType<Map>()
            .map((item) =>
                ServiceModel.fromJson(Map<String, dynamic>.from(item)))
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

  Future<bool> updateService({
    required String id,
    required String title,
    required String description,
    required String category,
    String? subcategory,
    required double price,
    required int durationMinutes,
    List<String> images = const [],
  }) async {
    return _saveAction('/kbeauty/services/update', {
      'service_id': id,
      'title': title,
      'description': description,
      'category': category,
      'subcategory': subcategory,
      'price': price,
      'duration_minutes': durationMinutes,
      'images': images,
    });
  }

  Future<bool> toggleVisibility(ServiceModel service) =>
      _saveAction('/kbeauty/services/toggle_visibility', {
        'service_id': service.id,
        'visible': !service.isVisible,
      });

  Future<bool> deleteService(String id) =>
      _saveAction('/kbeauty/services/delete', {'service_id': id});

  Future<bool> _saveAction(String endpoint, Map<String, dynamic> data) async {
    isSaving = true;
    lastError = null;
    notifyListeners();
    try {
      final response = await _manager.dio.post(endpoint, data: data);
      if (response.data['success'] == true) {
        await listMine();
        if (activeSearchCity?.isNotEmpty == true) {
          await searchServices(city: activeSearchCity);
        }
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
