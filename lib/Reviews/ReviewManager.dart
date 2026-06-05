import 'package:flutter/material.dart';

import '../Shared/Models.dart';
import 'Manager.dart';

/// ReviewManager for service reviews and ratings
class ReviewManager extends ChangeNotifier {
  final Manager _manager;
  ReviewManager(this._manager);

  List<ReviewModel> reviews = [];
  bool isLoading = false;
  String? lastError;

  Future<void> submitReview(
    String appointmentId,
    int rating,
    String? comment,
  ) async {
    try {
      final response = await _manager.dio.post(
        '/kbeauty/reviews/add',
        data: {
          'appointment_id': appointmentId,
          'rating': rating,
          'comment': comment,
        },
      );

      if (response.data['success']) {
        lastError = null;
      } else {
        lastError = response.data['message'];
      }
    } catch (e) {
      lastError = e.toString();
    }

    notifyListeners();
  }

  Future<void> listReviews(String beauticianhId) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await _manager.dio.post(
        '/kbeauty/reviews/list',
        data: {'beautician_id': beauticianhId},
      );

      if (response.data['success']) {
        final data = response.data['data'];
        reviews = (data['reviews'] as List?)?.map((r) {
          return ReviewModel.fromJson(r);
        }).toList() ?? [];
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
