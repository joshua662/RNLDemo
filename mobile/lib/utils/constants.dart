import 'package:flutter/material.dart';

const businessName = 'MD & V Laundry Shop';
const businessTagline =
    'Professional laundry pickup and delivery in Luyahan, Simpas.';

class AppColors {
  static const navy = Color(0xFF0C2D6B);
  static const navyDark = Color(0xFF071D47);
  static const navyMid = Color(0xFF1E5A9E);
  static const sky = Color(0xFF38BDF8);
  static const skyLight = Color(0xFFE0F2FE);
  static const surface = Color(0xFFF8FAFC);
  static const surfaceCard = Color(0xFFFFFFFF);
  static const muted = Color(0xFF64748B);
  static const border = Color(0xFFE2E8F0);
  static const textPrimary = Color(0xFF1E293B);
  static const green = Color(0xFF22C55E);
}

Color statusColor(String status) {
  switch (status) {
    case 'pending':
      return const Color(0xFF475569);
    case 'washing':
      return const Color(0xFF155E75);
    case 'drying':
      return const Color(0xFF0369A1);
    case 'folding':
      return const Color(0xFF115E59);
    case 'out_for_delivery':
      return const Color(0xFFB45309);
    case 'done':
    case 'delivered':
      return const Color(0xFF15803D);
    case 'cancelled':
      return const Color(0xFFDC2626);
    case 'picked_up':
      return const Color(0xFF4338CA);
    default:
      return AppColors.navy;
  }
}

const pickupTimeSlots = [
  '08:00',
  '09:00',
  '10:00',
  '11:00',
  '12:00',
  '13:00',
  '14:00',
  '15:00',
  '16:00',
  '17:00',
  '18:00',
];

const statusLabels = <String, String>{
  'pending': 'Pending',
  'confirmed': 'Confirmed',
  'pickup_scheduled': 'Pickup Scheduled',
  'picked_up': 'Picked Up',
  'washing': 'Washing',
  'drying': 'Drying',
  'folding': 'Folding',
  'out_for_delivery': 'Out for Delivery',
  'delivered': 'Delivered',
  'done': 'Finished',
  'cancelled': 'Cancelled',
};

String statusLabel(String status) =>
    statusLabels[status] ?? status.replaceAll('_', ' ');

double calculatePrice(double weight) {
  if (weight <= 0) return 0;
  const baseWeight = 8.0;
  const basePrice = 99.0;
  const extraPerKg = 12.0;
  if (weight <= baseWeight) return basePrice;
  return basePrice + (weight - baseWeight) * extraPerKg;
}

String formatPickupTime12h(String time24) {
  final parts = time24.split(':');
  if (parts.isEmpty) return time24;
  var hour = int.tryParse(parts[0]) ?? 0;
  final minute = parts.length > 1 ? parts[1] : '00';
  final period = hour >= 12 ? 'PM' : 'AM';
  if (hour == 0) {
    hour = 12;
  } else if (hour > 12) {
    hour -= 12;
  }
  return '$hour:$minute $period';
}
