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
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      durationMinutes: json['durationMinutes'] as int? ?? 60,
      category: json['category'] ?? '',
      subcategory: json['subcategory'],
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: json['reviewCount'] as int? ?? 0,
      images: List<String>.from(json['images'] ?? []),
      beautician: BeauticianhProfileModel.fromJson(json['beautician'] ?? {}),
    );
  }
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
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['bookingId'] ?? '',
      serviceId: json['serviceId'] ?? '',
      beauticianhId: json['beauticianhId'] ?? '',
      scheduledDateTime: DateTime.parse(json['scheduledDateTime'] ?? DateTime.now().toString()),
      locationAddress: json['locationAddress'] ?? '',
      locationCity: json['locationCity'],
      locationWilaya: json['locationWilaya'],
      locationCommune: json['locationCommune'],
      status: json['status'] ?? 'pending_payment',
      totalAmount: (json['amount'] as num?)?.toDouble() ?? 0,
      paymentStatus: json['paymentStatus'] ?? 'pending',
      stripeSessionId: json['stripeSessionId'],
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
  };
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
    this.completedAt,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] ?? '',
      bookingId: json['bookingId'] ?? '',
      serviceTitle: json['serviceTitle'] ?? '',
      servicePrice: (json['price'] as num?)?.toDouble() ?? 0,
      scheduledDateTime: DateTime.parse(json['scheduledDateTime'] ?? DateTime.now().toString()),
      durationMinutes: json['durationMinutes'] as int? ?? 60,
      locationAddress: json['location'] ?? '',
      status: json['status'] ?? 'pending_confirmation',
      beauticianhStatus: json['beauticianhStatus'] ?? 'pending_confirmation',
      clientNotes: json['clientNotes'],
      client: ClientProfileModel.fromJson(json['client'] ?? {}),
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
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
      experienceYears: json['experienceYears'] as int? ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      appointmentCount: json['appointmentCount'] as int? ?? 0,
      isVerified: json['isVerified'] as bool? ?? false,
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
