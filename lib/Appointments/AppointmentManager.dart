import 'package:flutter/material.dart';

import '../Shared/Models.dart';
import '../App/Manager.dart';

/// AppointmentManager handles appointment lifecycle for both clients and beauticians
class AppointmentManager extends ChangeNotifier {
  final Manager _manager;
  AppointmentManager(this._manager);

  List<AppointmentModel> appointments = [];
  List<AppointmentModel> pendingConfirmations = [];
  bool isLoading = false;
  String? lastError;

  Future<void> listAppointments({String? status}) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await _manager.dio.post(
        '/kbeauty/appointments/list',
        data: {'status': status, 'page': 1, 'limit': 50},
      );

      if (response.data['success']) {
        final data = response.data['data'];
        final allAppointments = (data['appointments'] as List?)?.map((a) {
              return AppointmentModel.fromJson(a);
            }).toList() ??
            [];

        if (status == 'pending') {
          pendingConfirmations = allAppointments;
        } else {
          appointments = allAppointments;
        }
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

  Future<void> confirmAppointment(String appointmentId) async {
    try {
      final response = await _manager.dio.post(
        '/kbeauty/appointments/confirm',
        data: {'appointment_id': appointmentId},
      );

      if (response.data['success']) {
        pendingConfirmations.removeWhere((a) => a.id == appointmentId);
        await listAppointments();
      } else {
        lastError = response.data['message'];
      }
    } catch (e) {
      lastError = e.toString();
    }

    notifyListeners();
  }

  Future<void> declineAppointment(String appointmentId, String reason) async {
    try {
      final response = await _manager.dio.post(
        '/kbeauty/appointments/decline',
        data: {'appointment_id': appointmentId, 'reason': reason},
      );

      if (response.data['success']) {
        pendingConfirmations.removeWhere((a) => a.id == appointmentId);
      } else {
        lastError = response.data['message'];
      }
    } catch (e) {
      lastError = e.toString();
    }

    notifyListeners();
  }
}
