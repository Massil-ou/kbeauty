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
        'phone': '0600000000',
        'profileImageUrl': 'https://example.com/profile.jpg',
      },
    });

    expect(service.price, 45);
    expect(service.durationMinutes, 60);
    expect(service.beautician.fullName, 'Nadia Test');
    expect(service.beautician.phone, '0600000000');
    expect(
      service.beautician.profileImageUrl,
      'https://example.com/profile.jpg',
    );
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
      'paymentStatus': 'paid',
      'canCancel': true,
      'canReschedule': true,
      'canEditDetails': true,
      'changeCutoffHours': 24,
      'serviceId': 'service-1',
      'beauticianhId': 'beautician-1',
      'client': {
        'firstName': 'Celia',
        'lastName': 'Test',
        'email': 'celia@example.com',
      },
    });

    expect(appointment.bookingId, 'booking-1');
    expect(appointment.client.fullName, 'Celia Test');
    expect(appointment.durationMinutes, 90);
    expect(appointment.canCancel, isTrue);
    expect(appointment.changeCutoffHours, 24);
  });

  test('parses Stripe checkout payload', () {
    final checkout = StripeCheckoutModel.fromJson({
      'bookingId': 'booking-1',
      'checkoutId': 'cs_test_1',
      'checkoutUrl': 'https://checkout.stripe.com/test',
      'status': 'open',
      'amount': 75.50,
      'currency': 'eur',
    });

    expect(checkout.checkoutId, 'cs_test_1');
    expect(checkout.amount, 75.50);
  });
}
