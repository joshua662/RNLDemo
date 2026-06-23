import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/order_model.dart';
import '../models/service_model.dart';
import '../models/user_model.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiService {
  static String get baseUrl => ApiConfig.baseUrl;

  static Map<String, String> _jsonHeaders({String? token}) {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static dynamic _decodeBody(http.Response response) {
    if (response.body.isEmpty) return null;
    return jsonDecode(response.body);
  }

  static Never _throwFromResponse(http.Response response) {
    final decoded = _decodeBody(response);
    if (decoded is Map<String, dynamic>) {
      final errors = decoded['errors'];
      if (errors is Map) {
        final first = errors.values.first;
        if (first is List && first.isNotEmpty) {
          throw ApiException(first.first.toString(), statusCode: response.statusCode);
        }
      }
      throw ApiException(
        decoded['message']?.toString() ?? 'Request failed',
        statusCode: response.statusCode,
      );
    }
    throw ApiException('Request failed (${response.statusCode})',
        statusCode: response.statusCode);
  }

  // --- Auth (matches client/src/services/AuthService.ts) ---

  static Future<({User user, String token})> login(
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _jsonHeaders(),
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = _decodeBody(response) as Map<String, dynamic>;
      return (
        user: User.fromJson(data['user'] as Map<String, dynamic>),
        token: data['token'] as String,
      );
    }
    _throwFromResponse(response);
  }

  static Future<({User user, String token})> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: _jsonHeaders(),
      body: jsonEncode({
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'password_confirmation': passwordConfirmation,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = _decodeBody(response) as Map<String, dynamic>;
      return (
        user: User.fromJson(data['user'] as Map<String, dynamic>),
        token: data['token'] as String,
      );
    }
    _throwFromResponse(response);
  }

  static Future<User> me(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: _jsonHeaders(token: token),
    );

    if (response.statusCode == 200) {
      final data = _decodeBody(response) as Map<String, dynamic>;
      return User.fromJson(data['user'] as Map<String, dynamic>);
    }
    _throwFromResponse(response);
  }

  static Future<void> logout(String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/logout'),
      headers: _jsonHeaders(token: token),
    );

    if (response.statusCode != 200) {
      _throwFromResponse(response);
    }
  }

  // --- Admin workflow (shared with the React admin website) ---

  static List<dynamic> _paginatedData(dynamic decoded) {
    if (decoded is Map<String, dynamic> && decoded['data'] is List) {
      return decoded['data'] as List;
    }
    if (decoded is List) return decoded;
    throw ApiException('Unexpected list payload');
  }

  static Future<Map<String, dynamic>> getAdminDashboard(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/dashboard'),
      headers: _jsonHeaders(token: token),
    );

    if (response.statusCode == 200) {
      return _decodeBody(response) as Map<String, dynamic>;
    }
    _throwFromResponse(response);
  }

  static Future<List<Booking>> getAdminOrders(
    String token, {
    String? status,
    String? search,
  }) async {
    final uri = Uri.parse('$baseUrl/admin/bookings').replace(
      queryParameters: {
        'per_page': '50',
        if (status != null && status.isNotEmpty) 'status': status,
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );
    final response = await http.get(uri, headers: _jsonHeaders(token: token));

    if (response.statusCode == 200) {
      return _paginatedData(_decodeBody(response))
          .map((item) => Booking.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    _throwFromResponse(response);
  }

  static Future<Booking> updateAdminOrderStatus({
    required String token,
    required int id,
    required String status,
    String? deliveryRider,
  }) async {
    final payload = {
      'status': status,
      if (deliveryRider != null && deliveryRider.isNotEmpty)
        'delivery_rider': deliveryRider,
    };
    final response = await http.patch(
      Uri.parse('$baseUrl/admin/bookings/$id/status'),
      headers: _jsonHeaders(token: token),
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      final data = _decodeBody(response) as Map<String, dynamic>;
      return Booking.fromJson(data['booking'] as Map<String, dynamic>);
    }
    _throwFromResponse(response);
  }

  static Future<Booking> markAdminOrderDone(String token, int id) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/admin/bookings/$id/done'),
      headers: _jsonHeaders(token: token),
    );

    if (response.statusCode == 200) {
      final data = _decodeBody(response) as Map<String, dynamic>;
      return Booking.fromJson(data['booking'] as Map<String, dynamic>);
    }
    _throwFromResponse(response);
  }

  static Future<Booking> cancelAdminOrder(String token, int id) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin/bookings/$id/cancel'),
      headers: _jsonHeaders(token: token),
    );

    if (response.statusCode == 200) {
      final data = _decodeBody(response) as Map<String, dynamic>;
      return Booking.fromJson(data['booking'] as Map<String, dynamic>);
    }
    _throwFromResponse(response);
  }

  static Future<void> adminTrashOrder(String token, int id) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin/bookings/$id/admin-trash'),
      headers: _jsonHeaders(token: token),
    );
    if (response.statusCode != 200) _throwFromResponse(response);
  }

  static Future<List<Booking>> getAdminTrashedOrders(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/bookings-trashed'),
      headers: _jsonHeaders(token: token),
    );
    if (response.statusCode == 200) {
      final decoded = _decodeBody(response);
      final list = decoded is Map<String, dynamic> && decoded['bookings'] is List
          ? decoded['bookings'] as List
          : decoded is List
              ? decoded
              : null;
      if (list == null) {
        throw ApiException('Unexpected trashed orders payload');
      }
      return list
          .map((item) => Booking.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    _throwFromResponse(response);
  }

  static Future<Booking> adminRestoreOrder(String token, int id) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin/bookings/$id/admin-restore'),
      headers: _jsonHeaders(token: token),
    );
    if (response.statusCode == 200) {
      final data = _decodeBody(response) as Map<String, dynamic>;
      return Booking.fromJson(data['booking'] as Map<String, dynamic>);
    }
    _throwFromResponse(response);
  }

  static Future<void> adminPermanentDeleteOrder(String token, int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/admin/bookings/$id'),
      headers: _jsonHeaders(token: token),
    );
    if (response.statusCode != 200) _throwFromResponse(response);
  }

  static Future<void> adminBatchRestoreOrders(String token, List<int> ids) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin/bookings/batch-restore'),
      headers: _jsonHeaders(token: token),
      body: jsonEncode({'ids': ids}),
    );
    if (response.statusCode != 200) _throwFromResponse(response);
  }

  static Future<void> adminBatchPermanentDeleteOrders(String token, List<int> ids) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin/bookings/batch-delete-permanent'),
      headers: _jsonHeaders(token: token),
      body: jsonEncode({'ids': ids}),
    );
    if (response.statusCode != 200) _throwFromResponse(response);
  }

  static Future<List<User>> getAdminCustomers(
    String token, {
    String? search,
  }) async {
    final uri = Uri.parse('$baseUrl/admin/customers').replace(
      queryParameters: {
        'per_page': '50',
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );
    final response = await http.get(uri, headers: _jsonHeaders(token: token));

    if (response.statusCode == 200) {
      return _paginatedData(_decodeBody(response))
          .map((item) => User.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    _throwFromResponse(response);
  }

  static Future<({String message, Booking booking})> createAdminOrder({
    required String token,
    required String fullName,
    required String phone,
    required String address,
    required String pickupDate,
    required String pickupTime,
    required double weight,
    String? notes,
    String? email,
    String customerType = 'pick_up',
    String paymentMethod = 'cash',
  }) async {
    final payload = <String, dynamic>{
      'full_name': fullName,
      'phone': phone,
      'email': email,
      'address': address,
      'pickup_date': pickupDate,
      'pickup_time': pickupTime,
      'weight': weight,
      'notes': notes,
      'customer_type': customerType,
      'payment_method': paymentMethod,
    }..removeWhere((key, value) => value == null || value == '');

    final response = await http.post(
      Uri.parse('$baseUrl/admin/bookings'),
      headers: _jsonHeaders(token: token),
      body: jsonEncode(payload),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = _decodeBody(response) as Map<String, dynamic>;
      return (
        message: data['message'] as String? ?? 'Order created successfully.',
        booking: Booking.fromJson(data['booking'] as Map<String, dynamic>),
      );
    }
    _throwFromResponse(response);
  }

  // --- Bookings (matches client/src/services/BookingService.ts) ---

  static Future<List<Booking>> getOrders(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/my-orders'),
      headers: _jsonHeaders(token: token),
    );

    if (response.statusCode == 200) {
      final decoded = _decodeBody(response);
      final list = decoded is Map<String, dynamic> && decoded['bookings'] is List
          ? decoded['bookings'] as List
          : decoded is List
              ? decoded
              : null;
      if (list == null) {
        throw ApiException('Unexpected orders payload');
      }
      return list
          .map((item) => Booking.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    _throwFromResponse(response);
  }

  static Future<Booking> getOrder(String token, int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/bookings/$id'),
      headers: _jsonHeaders(token: token),
    );

    if (response.statusCode == 200) {
      final data = _decodeBody(response) as Map<String, dynamic>;
      return Booking.fromJson(data['booking'] as Map<String, dynamic>);
    }
    _throwFromResponse(response);
  }

  static Future<Booking> trackOrder(String trackingCode) async {
    final response = await http.post(
      Uri.parse('$baseUrl/bookings/track'),
      headers: _jsonHeaders(),
      body: jsonEncode({'tracking_code': trackingCode}),
    );

    if (response.statusCode == 200) {
      final data = _decodeBody(response) as Map<String, dynamic>;
      return Booking.fromJson(data['booking'] as Map<String, dynamic>);
    }
    _throwFromResponse(response);
  }

  static Future<({String message, Booking booking, String? trackingMessage})>
      createOrder({
    required String token,
    required String fullName,
    required String phone,
    required String address,
    required String pickupDate,
    required String pickupTime,
    required double weight,
    String? notes,
    String? email,
    String customerType = 'pick_up',
    String paymentMethod = 'cash',
  }) async {
    final payload = <String, dynamic>{
      'full_name': fullName,
      'phone': phone,
      'address': address,
      'pickup_date': pickupDate,
      'pickup_time': pickupTime,
      'weight': weight,
      'notes': notes,
      'email': email,
      'customer_type': customerType,
      'payment_method': paymentMethod,
    }..removeWhere((key, value) => value == null);

    final response = await http.post(
      Uri.parse('$baseUrl/bookings'),
      headers: _jsonHeaders(token: token),
      body: jsonEncode(payload),
    );

    if (response.statusCode == 201) {
      final data = _decodeBody(response) as Map<String, dynamic>;
      final notification = data['notification'];
      return (
        message: data['message'] as String? ?? 'Order created successfully.',
        booking: Booking.fromJson(data['booking'] as Map<String, dynamic>),
        trackingMessage: notification is Map<String, dynamic>
            ? notification['message'] as String?
            : null,
      );
    }
    _throwFromResponse(response);
  }

  static Future<Booking> updateOrder({
    required String token,
    required int id,
    required String fullName,
    required String phone,
    required String address,
    required String pickupDate,
    required String pickupTime,
    required double weight,
    String? notes,
    String customerType = 'pick_up',
  }) async {
    final payload = <String, dynamic>{
      'full_name': fullName,
      'phone': phone,
      'address': address,
      'pickup_date': pickupDate,
      'pickup_time': pickupTime,
      'weight': weight,
      'notes': notes,
      'customer_type': customerType,
      'payment_method': 'cash',
    }..removeWhere((key, value) => value == null);

    final response = await http.put(
      Uri.parse('$baseUrl/bookings/$id'),
      headers: _jsonHeaders(token: token),
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      final data = _decodeBody(response) as Map<String, dynamic>;
      return Booking.fromJson(data['booking'] as Map<String, dynamic>);
    }
    _throwFromResponse(response);
  }

  static Future<Booking> cancelOrder(String token, int id) async {
    final response = await http.post(
      Uri.parse('$baseUrl/bookings/$id/cancel'),
      headers: _jsonHeaders(token: token),
    );

    if (response.statusCode == 200) {
      final data = _decodeBody(response) as Map<String, dynamic>;
      return Booking.fromJson(data['booking'] as Map<String, dynamic>);
    }
    _throwFromResponse(response);
  }

  static Future<void> deleteCancelledOrder(String token, int id) async {
    final trashResponse = await http.post(
      Uri.parse('$baseUrl/bookings/$id/trash'),
      headers: _jsonHeaders(token: token),
    );

    if (trashResponse.statusCode != 200) {
      _throwFromResponse(trashResponse);
    }

    final deleteResponse = await http.delete(
      Uri.parse('$baseUrl/bookings/$id/force'),
      headers: _jsonHeaders(token: token),
    );

    if (deleteResponse.statusCode != 200) {
      _throwFromResponse(deleteResponse);
    }
  }

  // --- Public services (matches client/src/services/PublicService.ts) ---

  static Future<List<Service>> getServices() async {
    final response = await http.get(
      Uri.parse('$baseUrl/services'),
      headers: _jsonHeaders(),
    );

    if (response.statusCode == 200) {
      final data = _decodeBody(response) as Map<String, dynamic>;
      final list = data['services'] as List;
      return list
          .map((item) => Service.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    _throwFromResponse(response);
  }
}
