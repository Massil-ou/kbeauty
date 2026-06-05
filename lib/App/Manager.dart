import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

// Managers (lazy-initialized)
import '../Dashboard/Services/ServiceManager.dart';
import '../Booking/BookingManager.dart';
import '../Booking/AvailabilityManager.dart';
import '../Appointments/AppointmentManager.dart';
import '../BeauticianhProfile/BeauticianhProfileManager.dart';
import '../Reviews/ReviewManager.dart';

/// Central Manager for kBeauty app
/// Reuses authentication from Cutoma via shared HelperService
class Manager extends ChangeNotifier {
  static Manager? _instance;

  /// Singleton factory
  factory Manager() {
    _instance ??= Manager._internal();
    return _instance!;
  }

  Manager._internal();

  // =========================================================================
  // AUTHENTICATION STATE (from Cutoma)
  // =========================================================================

  bool get isAuthenticated => false; // TODO: check if tokens exist
  String? get currentUserId => null; // TODO: get from HelperService
  bool get isClientRole => false; // TODO: check user role
  bool get isBeauticianhRole => false; // TODO: check user role

  // =========================================================================
  // LAZY-INITIALIZED MANAGERS
  // =========================================================================

  ServiceManager? _serviceManager;
  ServiceManager get serviceManager =>
      _serviceManager ??= ServiceManager(this);

  BookingManager? _bookingManager;
  BookingManager get bookingManager =>
      _bookingManager ??= BookingManager(this);

  AvailabilityManager? _availabilityManager;
  AvailabilityManager get availabilityManager =>
      _availabilityManager ??= AvailabilityManager(this);

  AppointmentManager? _appointmentManager;
  AppointmentManager get appointmentManager =>
      _appointmentManager ??= AppointmentManager(this);

  BeauticianhProfileManager? _beauticianhProfileManager;
  BeauticianhProfileManager get beauticianhProfileManager =>
      _beauticianhProfileManager ??= BeauticianhProfileManager(this);

  ReviewManager? _reviewManager;
  ReviewManager get reviewManager =>
      _reviewManager ??= ReviewManager(this);

  // =========================================================================
  // NETWORK CONFIGURATION
  // =========================================================================

  late final Dio dio = _createDio();

  Dio _createDio() {
    return Dio(BaseOptions(
      baseUrl: 'https://api.kbeauty.fr', // TODO: use env variable
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      contentType: 'application/json',
    ));
  }

  // =========================================================================
  // API RESPONSE MODELS
  // =========================================================================

  Future<T> apiCall<T>(
    String endpoint, {
    required T Function(Map<String, dynamic>) parser,
    Map<String, dynamic>? data,
    String method = 'POST',
  }) async {
    try {
      Response response;

      if (method == 'POST') {
        response = await dio.post(endpoint, data: data);
      } else if (method == 'GET') {
        response = await dio.get(endpoint);
      } else {
        throw Exception('Unsupported method: $method');
      }

      final json = response.data as Map<String, dynamic>;
      if (json['success'] != true) {
        throw Exception(json['message'] ?? 'API Error');
      }

      return parser(json['data'] ?? {});
    } catch (e) {
      rethrow;
    }
  }
}
