class BookingApartment {
  final int id;
  final String title;
  final String mainImage;
  final String city;
  final double price;
  final String rentType;

  BookingApartment({
    required this.id,
    required this.title,
    required this.mainImage,
    required this.city,
    required this.price,
    required this.rentType,
  });

  factory BookingApartment.fromJson(Map<String, dynamic> json) {
    return BookingApartment(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      mainImage: json['main_image'] ?? '',
      city: json['city'] ?? '',
      price: (json['price'] as num).toDouble(),
      rentType: json['rent_type'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'main_image': mainImage,
      'city': city,
      'price': price,
      'rent_type': rentType,
    };
  }
}

class BookingModel {
  final int id;
  final BookingApartment apartment;
  final String startDate;
  final String endDate;
  final double totalAmount;
  final String status; // canceled, completed, reject, pending, rented
  final String paymentStatus;
  final String? stripePaymentIntentId;
  final double? cancellationFee;
  final int numberOfGuests;
  final String? specialRequests;
  final String? cancelledAt;
  final String? completedAt;
  final List<dynamic> paymentTransactions;
  final List<dynamic> bookingTimeSlots;
  final String createdAt;
  final String updatedAt;

  BookingModel({
    required this.id,
    required this.apartment,
    required this.startDate,
    required this.endDate,
    required this.totalAmount,
    required this.status,
    required this.paymentStatus,
    this.stripePaymentIntentId,
    this.cancellationFee,
    required this.numberOfGuests,
    this.specialRequests,
    this.cancelledAt,
    this.completedAt,
    required this.paymentTransactions,
    required this.bookingTimeSlots,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] ?? 0,
      apartment: BookingApartment.fromJson(json['apartment'] ?? {}),
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? '',
      paymentStatus: json['payment_status'] ?? '',
      stripePaymentIntentId: json['stripe_payment_intent_id'],
      cancellationFee: (json['cancellation_fee'] as num?)?.toDouble(),
      numberOfGuests: json['number_of_guests'] ?? 0,
      specialRequests: json['special_requests'],
      cancelledAt: json['cancelled_at'],
      completedAt: json['completed_at'],
      paymentTransactions: json['payment_transactions'] ?? [],
      bookingTimeSlots: json['booking_time_slots'] ?? [],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'apartment': apartment.toJson(),
      'start_date': startDate,
      'end_date': endDate,
      'total_amount': totalAmount,
      'status': status,
      'payment_status': paymentStatus,
      'stripe_payment_intent_id': stripePaymentIntentId,
      'cancellation_fee': cancellationFee,
      'number_of_guests': numberOfGuests,
      'special_requests': specialRequests,
      'cancelled_at': cancelledAt,
      'completed_at': completedAt,
      'payment_transactions': paymentTransactions,
      'booking_time_slots': bookingTimeSlots,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
