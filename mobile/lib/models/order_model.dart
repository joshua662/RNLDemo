import 'payment_model.dart';

class Booking {
  final int id;
  final int? userId;
  final String bookingNumber;
  final String fullName;
  final String phone;
  final String? email;
  final String? customerType;
  final String address;
  final String? pickupDate;
  final String? pickupTime;
  final double weight;
  final String? notes;
  final String status;
  final String trackingCode;
  final double totalPrice;
  final bool isDone;
  final String? deliveryRider;
  final String? paymentMethod;
  final bool canEdit;
  final bool canCancel;
  final bool canDelete;
  final Payment? payment;
  final String? createdAt;
  final String? updatedAt;

  const Booking({
    required this.id,
    this.userId,
    required this.bookingNumber,
    required this.fullName,
    required this.phone,
    this.email,
    this.customerType,
    required this.address,
    this.pickupDate,
    this.pickupTime,
    required this.weight,
    this.notes,
    required this.status,
    required this.trackingCode,
    required this.totalPrice,
    required this.isDone,
    this.deliveryRider,
    this.paymentMethod,
    this.canEdit = false,
    this.canCancel = false,
    this.canDelete = false,
    this.payment,
    this.createdAt,
    this.updatedAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as int,
      userId: json['user_id'] as int?,
      bookingNumber: json['booking_number'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String?,
      customerType: json['customer_type'] as String?,
      address: json['address'] as String? ?? '',
      pickupDate: json['pickup_date'] as String?,
      pickupTime: json['pickup_time'] as String?,
      weight: _toDouble(json['weight']),
      notes: json['notes'] as String?,
      status: json['status'] as String? ?? 'pending',
      trackingCode: json['tracking_code'] as String? ?? '',
      totalPrice: _toDouble(json['total_price']),
      isDone: json['is_done'] == true,
      deliveryRider: json['delivery_rider'] as String?,
      paymentMethod: json['payment_method'] as String?,
      canEdit: json['can_edit'] == true,
      canCancel: json['can_cancel'] == true,
      canDelete: json['can_delete'] == true,
      payment: json['payment'] is Map<String, dynamic>
          ? Payment.fromJson(json['payment'] as Map<String, dynamic>)
          : null,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
