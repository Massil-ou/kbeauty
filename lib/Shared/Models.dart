// kBeauty Data Models

// ============================================================================
// SERVICE MODELS
// ============================================================================

class ServiceModel {
  final String id;
  final String title;
  final String description;
  final double price;
  final int durationMinutes;
  final String category;
  final String? subcategory;
  final double rating;
  final int reviewCount;
  final List<String> images;
  final BeauticianhProfileModel beautician;
  final String status;

  ServiceModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.durationMinutes,
    required this.category,
    this.subcategory,
    required this.rating,
    required this.reviewCount,
    required this.images,
    required this.beautician,
    this.status = 'active',
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 60,
      category: json['category'] ?? '',
      subcategory: json['subcategory'],
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      images: List<String>.from(json['images'] ?? []),
      beautician: BeauticianhProfileModel.fromJson(json['beautician'] ?? {}),
      status: json['status']?.toString() ?? 'active',
    );
  }

  bool get isVisible => status == 'active';
}

// ============================================================================
// BOOKING & APPOINTMENT MODELS
// ============================================================================

class BookingModel {
  final String id;
  final String serviceId;
  final String beauticianhId;
  final DateTime scheduledDateTime;
  final String locationAddress;
  final String? locationCity;
  final String? locationWilaya;
  final String? locationCommune;
  final String status;
  final double totalAmount;
  final String paymentStatus;
  final String? stripeSessionId;
  final String serviceTitle;
  final String serviceCategory;
  final String beauticianName;

  BookingModel({
    required this.id,
    required this.serviceId,
    required this.beauticianhId,
    required this.scheduledDateTime,
    required this.locationAddress,
    this.locationCity,
    this.locationWilaya,
    this.locationCommune,
    required this.status,
    required this.totalAmount,
    required this.paymentStatus,
    this.stripeSessionId,
    this.serviceTitle = '',
    this.serviceCategory = '',
    this.beauticianName = '',
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['bookingId'] ?? '',
      serviceId: json['serviceId'] ?? '',
      beauticianhId: json['beauticianhId'] ?? '',
      scheduledDateTime: DateTime.parse(
          json['scheduledDateTime'] ?? DateTime.now().toString()),
      locationAddress: json['locationAddress'] ?? '',
      locationCity: json['locationCity'],
      locationWilaya: json['locationWilaya'],
      locationCommune: json['locationCommune'],
      status: json['status'] ?? 'pending_payment',
      totalAmount: (json['amount'] as num?)?.toDouble() ?? 0,
      paymentStatus: json['paymentStatus'] ?? 'pending',
      stripeSessionId: json['stripeSessionId'],
      serviceTitle: json['serviceTitle']?.toString() ?? '',
      serviceCategory: json['serviceCategory']?.toString() ?? '',
      beauticianName: json['beauticianName']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'bookingId': id,
        'serviceId': serviceId,
        'beauticianhId': beauticianhId,
        'scheduledDateTime': scheduledDateTime.toIso8601String(),
        'locationAddress': locationAddress,
        'locationCity': locationCity,
        'locationWilaya': locationWilaya,
        'locationCommune': locationCommune,
        'status': status,
        'amount': totalAmount,
        'paymentStatus': paymentStatus,
        'stripeSessionId': stripeSessionId,
        'serviceTitle': serviceTitle,
        'serviceCategory': serviceCategory,
        'beauticianName': beauticianName,
      };
}

class StripeCheckoutModel {
  const StripeCheckoutModel({
    required this.bookingId,
    required this.checkoutId,
    required this.checkoutUrl,
    required this.status,
    required this.amount,
    required this.currency,
  });

  final String bookingId;
  final String checkoutId;
  final String checkoutUrl;
  final String status;
  final double amount;
  final String currency;

  factory StripeCheckoutModel.fromJson(Map<String, dynamic> json) =>
      StripeCheckoutModel(
        bookingId: json['bookingId']?.toString() ?? '',
        checkoutId: json['checkoutId']?.toString() ?? '',
        checkoutUrl: json['checkoutUrl']?.toString() ?? '',
        status: json['status']?.toString() ?? 'open',
        amount: (json['amount'] as num?)?.toDouble() ?? 0,
        currency: json['currency']?.toString() ?? 'eur',
      );
}

class AppointmentModel {
  final String id;
  final String bookingId;
  final String serviceTitle;
  final double servicePrice;
  final DateTime scheduledDateTime;
  final int durationMinutes;
  final String locationAddress;
  final String status;
  final String beauticianhStatus;
  final String? clientNotes;
  final ClientProfileModel client;
  final String beauticianName;
  final String serviceId;
  final String beauticianhId;
  final String paymentStatus;
  final String? locationCity;
  final String? locationWilaya;
  final String? locationCommune;
  final String? beauticianNotes;
  final String? cancellationReason;
  final String? cancelledBy;
  final bool canCancel;
  final bool canReschedule;
  final bool canEditDetails;
  final int changeCutoffHours;
  final DateTime? completedAt;

  AppointmentModel({
    required this.id,
    required this.bookingId,
    required this.serviceTitle,
    required this.servicePrice,
    required this.scheduledDateTime,
    required this.durationMinutes,
    required this.locationAddress,
    required this.status,
    required this.beauticianhStatus,
    this.clientNotes,
    required this.client,
    this.beauticianName = '',
    this.serviceId = '',
    this.beauticianhId = '',
    this.paymentStatus = 'paid',
    this.locationCity,
    this.locationWilaya,
    this.locationCommune,
    this.beauticianNotes,
    this.cancellationReason,
    this.cancelledBy,
    this.canCancel = false,
    this.canReschedule = false,
    this.canEditDetails = false,
    this.changeCutoffHours = 24,
    this.completedAt,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] ?? '',
      bookingId: json['bookingId'] ?? '',
      serviceTitle: json['serviceTitle'] ?? '',
      servicePrice: (json['price'] as num?)?.toDouble() ?? 0,
      scheduledDateTime: DateTime.parse(
          json['scheduledDateTime'] ?? DateTime.now().toString()),
      durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 60,
      locationAddress: json['location'] ?? '',
      status: json['status'] ?? 'pending_confirmation',
      beauticianhStatus: json['beauticianhStatus'] ?? 'pending_confirmation',
      clientNotes: json['clientNotes'],
      client: ClientProfileModel.fromJson(json['client'] ?? {}),
      beauticianName: json['beauticianName']?.toString() ?? '',
      serviceId: json['serviceId']?.toString() ?? '',
      beauticianhId: json['beauticianhId']?.toString() ?? '',
      paymentStatus: json['paymentStatus']?.toString() ?? 'paid',
      locationCity: json['locationCity']?.toString(),
      locationWilaya: json['locationWilaya']?.toString(),
      locationCommune: json['locationCommune']?.toString(),
      beauticianNotes: json['beauticianNotes']?.toString(),
      cancellationReason: json['cancellationReason']?.toString(),
      cancelledBy: json['cancelledBy']?.toString(),
      canCancel: json['canCancel'] == true,
      canReschedule: json['canReschedule'] == true,
      canEditDetails: json['canEditDetails'] == true,
      changeCutoffHours: (json['changeCutoffHours'] as num?)?.toInt() ?? 24,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
    );
  }
}

// ============================================================================
// BEAUTICIAN MODELS
// ============================================================================

class BeauticianhProfileModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? bio;
  final List<String> specializations;
  final int experienceYears;
  final double rating;
  final int appointmentCount;
  final bool isVerified;
  final String? phone;
  final String? profileImageUrl;

  BeauticianhProfileModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.bio,
    required this.specializations,
    required this.experienceYears,
    required this.rating,
    required this.appointmentCount,
    required this.isVerified,
    this.phone,
    this.profileImageUrl,
  });

  String get fullName => '$firstName $lastName';

  factory BeauticianhProfileModel.fromJson(Map<String, dynamic> json) {
    return BeauticianhProfileModel(
      id: json['id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      bio: json['bio'],
      specializations: List<String>.from(json['specializations'] ?? []),
      experienceYears: (json['experienceYears'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      appointmentCount: (json['appointmentCount'] as num?)?.toInt() ?? 0,
      isVerified: json['isVerified'] as bool? ?? false,
      phone: json['phone']?.toString(),
      profileImageUrl: json['profileImageUrl']?.toString(),
    );
  }
}

// ============================================================================
// CLIENT MODELS
// ============================================================================

class ClientProfileModel {
  final String firstName;
  final String lastName;
  final String email;

  ClientProfileModel({
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  String get fullName => '$firstName $lastName';

  factory ClientProfileModel.fromJson(Map<String, dynamic> json) {
    return ClientProfileModel(
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
    );
  }
}

// ============================================================================
// AVAILABILITY MODELS
// ============================================================================

class AvailabilitySlotModel {
  final String time; // HH:MM format
  final bool available;

  AvailabilitySlotModel({
    required this.time,
    required this.available,
  });

  factory AvailabilitySlotModel.fromJson(Map<String, dynamic> json) {
    return AvailabilitySlotModel(
      time: json['time'] ?? '',
      available: json['available'] as bool? ?? false,
    );
  }
}

// ============================================================================
// REVIEW MODELS
// ============================================================================

class ReviewModel {
  final String id;
  final int rating;
  final String? comment;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] ?? '',
      rating: json['rating'] as int? ?? 0,
      comment: json['comment'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
    );
  }
}
