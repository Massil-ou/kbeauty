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

  String? _accessToken = const String.fromEnvironment('ACCESS_TOKEN').trim();
  String? _deviceToken = const String.fromEnvironment('DEVICE_TOKEN').trim();
  String? _currentUserId = const String.fromEnvironment('USER_ID').trim();
  String? _currentUserRole = const String.fromEnvironment('USER_ROLE').trim();

  // =========================================================================
  // AUTHENTICATION STATE (from Cutoma)
  // =========================================================================

  bool get isAuthenticated =>
      _accessToken?.isNotEmpty == true && _deviceToken?.isNotEmpty == true;
  String? get currentUserId => _currentUserId;
  bool get isClientRole => _currentUserRole == 'client';
  bool get isBeauticianhRole => _currentUserRole == 'beautician';

  void configureAuth({
    required String accessToken,
    required String deviceToken,
    required String userId,
    required String role,
  }) {
    _accessToken = accessToken.trim();
    _deviceToken = deviceToken.trim();
    _currentUserId = userId.trim();
    _currentUserRole = role.trim();
    notifyListeners();
  }

  void clearAuth() {
    _accessToken = null;
    _deviceToken = null;
    _currentUserId = null;
    _currentUserRole = null;
    notifyListeners();
  }

  // =========================================================================
  // LAZY-INITIALIZED MANAGERS
  // =========================================================================

  ServiceManager? _serviceManager;
  ServiceManager get serviceManager => _serviceManager ??= ServiceManager(this);

  BookingManager? _bookingManager;
  BookingManager get bookingManager => _bookingManager ??= BookingManager(this);

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
  ReviewManager get reviewManager => _reviewManager ??= ReviewManager(this);

  // =========================================================================
  // NETWORK CONFIGURATION
  // =========================================================================

  late final Dio dio = _createDio();

  Dio _createDio() {
    const apiBaseUrl = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'https://api.winycar.fr',
    );
    final dio = Dio(BaseOptions(
      baseUrl: apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      contentType: 'application/json',
    ));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_accessToken?.isNotEmpty == true) {
            options.headers['Authorization'] = 'Bearer $_accessToken';
          }
          if (_deviceToken?.isNotEmpty == true) {
            options.headers['X-Device-Id'] = _deviceToken;
          }
          handler.next(options);
        },
      ),
    );
    return dio;
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
