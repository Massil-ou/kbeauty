import 'package:flutter/foundation.dart';

import '../App/Manager.dart';

class AuthResult {
  const AuthResult({
    required this.success,
    this.message = '',
    this.data = const {},
  });

  final bool success;
  final String message;
  final Map<String, dynamic> data;
}

class AuthManager extends ChangeNotifier {
  static const String _projectCode = 'kbeauty';
  AuthManager(this.manager);

  final Manager manager;

  bool isLoading = false;
  String? lastError;

  void clearError() {
    lastError = null;
    notifyListeners();
  }

  Future<AuthResult> _post(
    String path,
    Map<String, dynamic> data, {
    bool saveSession = false,
  }) async {
    isLoading = true;
    lastError = null;
    notifyListeners();
    try {
      final response = await manager.dio.post(path, data: data);
      final json = response.data is Map
          ? Map<String, dynamic>.from(response.data as Map)
          : <String, dynamic>{};
      final payload = json['data'] is Map
          ? Map<String, dynamic>.from(json['data'] as Map)
          : <String, dynamic>{};
      final result = AuthResult(
        success: json['success'] == true,
        message: json['message']?.toString() ?? '',
        data: payload,
      );
      if (!result.success) {
        lastError = result.message.isEmpty
            ? 'Une erreur est survenue. Réessayez.'
            : result.message;
      } else if (saveSession) {
        await manager.saveSession(payload);
      }
      return result;
    } catch (_) {
      lastError = 'Impossible de joindre le serveur.';
      return AuthResult(success: false, message: lastError!);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<AuthResult> requestLogin({
    required String email,
    required String password,
  }) =>
      _post('/auth/login', {
        'project_code': _projectCode,
        'email': email.trim().toLowerCase(),
        'password': password,
      });

  Future<AuthResult> verifyLogin({
    required String email,
    required String password,
    required String otp,
  }) =>
      _post(
        '/auth/login/verify-otp',
        {
          'project_code': _projectCode,
          'email': email.trim().toLowerCase(),
          'password': password,
          'otp': otp.trim().toUpperCase(),
        },
        saveSession: true,
      );

  Future<AuthResult> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phone,
  }) =>
      _post('/auth/register', {
        'first_name': firstName.trim(),
        'last_name': lastName.trim(),
        'project_code': _projectCode,
        'email': email.trim().toLowerCase(),
        'password': password,
        'number': phone.trim(),
      });

  Future<AuthResult> verifyRegistration({
    required String email,
    required String password,
    required String otp,
  }) =>
      _post(
        '/auth/register/verify-otp',
        {
          'project_code': _projectCode,
          'email': email.trim().toLowerCase(),
          'password': password,
          'otp': otp.trim().toUpperCase(),
        },
        saveSession: true,
      );

  Future<AuthResult> resendRegistrationOtp(String email) =>
      _post('/auth/register/resend-otp', {
        'project_code': _projectCode,
        'email': email.trim().toLowerCase(),
      });

  Future<AuthResult> forgotPassword(String email) =>
      _post('/auth/password/forgot', {
        'project_code': _projectCode,
        'email': email.trim().toLowerCase(),
      });

  Future<void> autoLogin() async {
    final refresh = manager.refreshToken;
    if (refresh?.isNotEmpty != true) return;
    final result = await _post(
      '/auth/refresh',
      {'refresh_token': refresh},
      saveSession: true,
    );
    if (!result.success) await manager.clearAuth();
  }

  Future<void> logout() async {
    final refresh = manager.refreshToken;
    if (refresh?.isNotEmpty == true) {
      try {
        await manager.dio.post('/auth/logout', data: {
          'project_code': _projectCode,
          'refresh_token': refresh,
        });
      } catch (_) {}
    }
    await manager.clearAuth();
    lastError = null;
    notifyListeners();
  }
}
