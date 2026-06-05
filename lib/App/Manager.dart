import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../Appointments/AppointmentManager.dart';
import '../Account/AccountManager.dart';
import '../Admin/AdminManager.dart';
import '../Auth/AuthManager.dart';
import '../BeauticianhProfile/BeauticianhProfileManager.dart';
import '../Booking/AvailabilityManager.dart';
import '../Booking/BookingManager.dart';
import '../Dashboard/Services/ServiceManager.dart';
import '../Reviews/ReviewManager.dart';

class Manager extends ChangeNotifier {
  static Manager? _instance;

  factory Manager() => _instance ??= Manager._internal();

  Manager._internal();

  static const _deviceMacKeyB64 =
      'xK9mP2vQs7nL4wRj8tYu3oZeHgBf6cDi1aWx5kNpMqA=';

  static const _accessKey = 'kbeauty_access';
  static const _refreshKey = 'kbeauty_refresh';
  static const _userIdKey = 'kbeauty_user_id';
  static const _roleKey = 'kbeauty_user_role';
  static const _firstNameKey = 'kbeauty_first_name';
  static const _lastNameKey = 'kbeauty_last_name';
  static const _emailKey = 'kbeauty_email';
  static const _phoneKey = 'kbeauty_phone';
  static const _deviceIdKey = 'kbeauty_device_id';

  SharedPreferences? _preferences;
  String? _accessToken = const String.fromEnvironment('ACCESS_TOKEN').trim();
  String? _refreshToken;
  String? _deviceHeader = const String.fromEnvironment('DEVICE_TOKEN').trim();
  String? _rawDeviceId;
  String? _currentUserId = const String.fromEnvironment('USER_ID').trim();
  String? _currentUserRole = const String.fromEnvironment('USER_ROLE').trim();
  String _currentFirstName = '';
  String _currentLastName = '';
  String _currentEmail = '';
  String _currentPhone = '';

  bool get isAuthenticated =>
      _accessToken?.isNotEmpty == true && _deviceHeader?.isNotEmpty == true;
  String? get currentUserId => _currentUserId;
  String get currentUserRole => (_currentUserRole ?? '').toLowerCase().trim();
  String get currentUserEmail => _currentEmail;
  String get currentUserPhone => _currentPhone;
  String get currentUserName => '$_currentFirstName $_currentLastName'.trim();
  String? get refreshToken => _refreshToken;
  bool get isClientRole => currentUserRole == 'client';
  bool get isAdminRole => currentUserRole == 'admin';
  bool get isBeauticianhRole =>
      currentUserRole == 'beautician' ||
      currentUserRole == 'partner' ||
      currentUserRole == 'manager';
  bool get isManagerRole => currentUserRole == 'manager';

  Future<void> bootstrap() async {
    _preferences = await SharedPreferences.getInstance();
    _rawDeviceId = _preferences!.getString(_deviceIdKey);
    if (_rawDeviceId?.isNotEmpty != true) {
      _rawDeviceId = const Uuid().v4();
      await _preferences!.setString(_deviceIdKey, _rawDeviceId!);
    }
    _deviceHeader = _createDeviceHeader(_rawDeviceId!);

    _accessToken = _preferences!.getString(_accessKey) ?? _accessToken;
    _refreshToken = _preferences!.getString(_refreshKey);
    _currentUserId = _preferences!.getString(_userIdKey) ?? _currentUserId;
    _currentUserRole = _preferences!.getString(_roleKey) ?? _currentUserRole;
    _currentFirstName = _preferences!.getString(_firstNameKey) ?? '';
    _currentLastName = _preferences!.getString(_lastNameKey) ?? '';
    _currentEmail = _preferences!.getString(_emailKey) ?? '';
    _currentPhone = _preferences!.getString(_phoneKey) ?? '';

    if (_refreshToken?.isNotEmpty == true) {
      await authManager.autoLogin();
    }
    notifyListeners();
  }

  String _createDeviceHeader(String deviceId) {
    final now = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
    final exp = now + 86400;
    final payload = '$deviceId|$now|$exp';
    final key = base64Decode(_deviceMacKeyB64);
    final mac = Hmac(sha256, key).convert(utf8.encode(payload)).bytes;
    return base64Encode(
      utf8.encode(
        jsonEncode({
          'device_id': deviceId,
          'iat': now,
          'exp': exp,
          'mac': base64Encode(mac),
        }),
      ),
    );
  }

  String _readUserIdFromAccessToken(String accessToken) {
    try {
      final parts = accessToken.split('.');
      if (parts.length < 2) return '';
      final normalized = base64Url.normalize(parts[1]);
      final payload = jsonDecode(utf8.decode(base64Url.decode(normalized)));
      if (payload is Map) return payload['sub']?.toString() ?? '';
    } catch (_) {}
    return '';
  }

  Future<void> saveSession(Map<String, dynamic> data) async {
    final access = data['access_token']?.toString() ?? '';
    final refresh = data['refresh_token']?.toString() ?? '';
    final user = data['user'] is Map
        ? Map<String, dynamic>.from(data['user'] as Map)
        : <String, dynamic>{};

    _accessToken = access;
    _refreshToken = refresh;
    _currentUserId = _readUserIdFromAccessToken(access);
    _currentUserRole = user['role']?.toString() ?? 'client';
    _currentFirstName = user['first_name']?.toString() ?? '';
    _currentLastName = user['last_name']?.toString() ?? '';
    _currentEmail = user['email']?.toString() ?? '';
    _currentPhone = user['number']?.toString() ?? '';

    final prefs = _preferences ?? await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setString(_accessKey, _accessToken ?? ''),
      prefs.setString(_refreshKey, _refreshToken ?? ''),
      prefs.setString(_userIdKey, _currentUserId ?? ''),
      prefs.setString(_roleKey, _currentUserRole ?? ''),
      prefs.setString(_firstNameKey, _currentFirstName),
      prefs.setString(_lastNameKey, _currentLastName),
      prefs.setString(_emailKey, _currentEmail),
      prefs.setString(_phoneKey, _currentPhone),
    ]);
    notifyListeners();
  }

  void configureAuth({
    required String accessToken,
    required String deviceToken,
    required String userId,
    required String role,
  }) {
    _accessToken = accessToken.trim();
    _deviceHeader = deviceToken.trim();
    _currentUserId = userId.trim();
    _currentUserRole = role.trim();
    notifyListeners();
  }

  Future<void> clearAuth() async {
    _accessToken = null;
    _refreshToken = null;
    _currentUserId = null;
    _currentUserRole = null;
    _currentFirstName = '';
    _currentLastName = '';
    _currentEmail = '';
    _currentPhone = '';

    final prefs = _preferences ?? await SharedPreferences.getInstance();
    await Future.wait([
      prefs.remove(_accessKey),
      prefs.remove(_refreshKey),
      prefs.remove(_userIdKey),
      prefs.remove(_roleKey),
      prefs.remove(_firstNameKey),
      prefs.remove(_lastNameKey),
      prefs.remove(_emailKey),
      prefs.remove(_phoneKey),
    ]);
    notifyListeners();
  }

  Future<void> updateLocalProfile({
    required String firstName,
    required String lastName,
    String? phone,
  }) async {
    _currentFirstName = firstName.trim();
    _currentLastName = lastName.trim();
    if (phone != null) _currentPhone = phone.trim();
    final prefs = _preferences ?? await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setString(_firstNameKey, _currentFirstName),
      prefs.setString(_lastNameKey, _currentLastName),
      prefs.setString(_phoneKey, _currentPhone),
    ]);
    notifyListeners();
  }

  AccountManager? _accountManager;
  AccountManager get accountManager => _accountManager ??= AccountManager(this);

  AdminManager? _adminManager;
  AdminManager get adminManager => _adminManager ??= AdminManager(this);

  AuthManager? _authManager;
  AuthManager get authManager => _authManager ??= AuthManager(this);

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

  late final Dio dio = _createDio();

  Dio _createDio() {
    const apiBaseUrl = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'https://api.winycar.fr',
    );
    final instance = Dio(
      BaseOptions(
        baseUrl: apiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        contentType: 'application/json',
        validateStatus: (status) =>
            status != null && status >= 200 && status < 600,
      ),
    );
    instance.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: (options, handler) async {
          if (_deviceHeader?.isNotEmpty != true) {
            _preferences ??= await SharedPreferences.getInstance();
            _rawDeviceId = _preferences!.getString(_deviceIdKey);
            if (_rawDeviceId?.isNotEmpty != true) {
              _rawDeviceId = const Uuid().v4();
              await _preferences!.setString(_deviceIdKey, _rawDeviceId!);
            }
            _deviceHeader = _createDeviceHeader(_rawDeviceId!);
          }
          options.headers['X-Device-Id'] = _deviceHeader;
          if (_accessToken?.isNotEmpty == true) {
            options.headers['Authorization'] = 'Bearer $_accessToken';
          }
          handler.next(options);
        },
      ),
    );
    return instance;
  }

  Future<T> apiCall<T>(
    String endpoint, {
    required T Function(Map<String, dynamic>) parser,
    Map<String, dynamic>? data,
    String method = 'POST',
  }) async {
    final Response response = method == 'GET'
        ? await dio.get(endpoint)
        : await dio.post(endpoint, data: data);
    final json = response.data is Map
        ? Map<String, dynamic>.from(response.data as Map)
        : <String, dynamic>{};
    if (json['success'] != true) {
      throw Exception(json['message'] ?? 'Erreur API');
    }
    final payload = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : <String, dynamic>{};
    return parser(payload);
  }
}
