import 'package:flutter_test/flutter_test.dart';
import 'package:kbeauty/Shared/Models.dart';

void main() {
  test('parses service search payload', () {
    final service = ServiceModel.fromJson({
      'id': 'service-1',
      'title': 'Brushing',
      'description': 'Description',
      'price': 45,
      'durationMinutes': 60,
      'category': 'Coiffure',
      'subcategory': 'Brushing',
      'rating': 4.5,
      'reviewCount': 8,
      'images': ['https://example.com/image.jpg'],
      'beautician': {
        'id': 'beautician-1',
        'firstName': 'Nadia',
        'lastName': 'Test',
        'rating': 4.8,
        'appointmentCount': 12,
        'isVerified': true,
      },
    });

    expect(service.price, 45);
    expect(service.durationMinutes, 60);
    expect(service.beautician.fullName, 'Nadia Test');
  });

  test('parses appointment list payload', () {
    final appointment = AppointmentModel.fromJson({
      'id': 'appointment-1',
      'bookingId': 'booking-1',
      'serviceTitle': 'Maquillage',
      'price': 70,
      'scheduledDateTime': '2026-06-06T14:00:00',
      'durationMinutes': 90,
      'location': '12 rue Test',
      'status': 'confirmed',
      'beauticianhStatus': 'confirmed',
      'client': {
        'firstName': 'Celia',
        'lastName': 'Test',
        'email': 'celia@example.com',
      },
    });

    expect(appointment.bookingId, 'booking-1');
    expect(appointment.client.fullName, 'Celia Test');
    expect(appointment.durationMinutes, 90);
  });
}
