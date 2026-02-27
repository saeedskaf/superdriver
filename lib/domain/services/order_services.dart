import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:superdriver/data/env/environment.dart';
import 'package:superdriver/data/local_secure/secure_storage.dart';
import 'package:superdriver/domain/models/order_model.dart';

class OrderServices {
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await secureStorage.getAccessToken();
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  String _extractErrorMessage(dynamic responseBody) {
    if (responseBody is Map<String, dynamic>) {
      for (var value in responseBody.values) {
        if (value is List && value.isNotEmpty) {
          return value[0].toString();
        }
        if (value is String) {
          return value;
        }
      }
    }
    return 'Unexpected error';
  }

  /// Get all user orders
  Future<List<OrderListItem>> getOrders() async {
    final uri = Uri.parse(Environment.ordersEndpoint);
    final headers = await _getAuthHeaders();

    final response = await http.get(uri, headers: headers);

    log('Get Orders Response Status: ${response.statusCode}');
    log('Get Orders Response: ${response.body}');

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      if (responseBody is List) {
        return responseBody
            .map((item) => OrderListItem.fromJson(item))
            .toList();
      }
      return [];
    } else {
      final responseBody = jsonDecode(response.body);
      throw Exception(_extractErrorMessage(responseBody));
    }
  }

  /// Get active orders
  Future<List<Order>> getActiveOrders() async {
    final uri = Uri.parse(Environment.activeOrdersEndpoint);
    final headers = await _getAuthHeaders();

    final response = await http.get(uri, headers: headers);

    log('Get Active Orders Response Status: ${response.statusCode}');
    log('Get Active Orders Response: ${response.body}');

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      if (responseBody is List) {
        return responseBody.map((item) => Order.fromJson(item)).toList();
      } else if (responseBody is Map<String, dynamic>) {
        return [Order.fromJson(responseBody)];
      }
      return [];
    } else {
      final responseBody = jsonDecode(response.body);
      throw Exception(_extractErrorMessage(responseBody));
    }
  }

  /// Get orders history (completed + cancelled)
  Future<List<Order>> getOrdersHistory() async {
    final uri = Uri.parse(Environment.ordersHistoryEndpoint);
    final headers = await _getAuthHeaders();

    final response = await http.get(uri, headers: headers);

    log('Get Orders History Response Status: ${response.statusCode}');
    log('Get Orders History Response: ${response.body}');

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      if (responseBody is List) {
        return responseBody.map((item) => Order.fromJson(item)).toList();
      } else if (responseBody is Map<String, dynamic>) {
        return [Order.fromJson(responseBody)];
      }
      return [];
    } else {
      final responseBody = jsonDecode(response.body);
      throw Exception(_extractErrorMessage(responseBody));
    }
  }

  /// Get order details
  Future<Order> getOrderDetails(int orderId) async {
    final uri = Uri.parse(Environment.orderDetailsEndpoint(orderId));
    final headers = await _getAuthHeaders();

    final response = await http.get(uri, headers: headers);

    log('Get Order Details Response Status: ${response.statusCode}');
    log('Get Order Details Response: ${response.body}');

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      return Order.fromJson(responseBody);
    } else {
      final responseBody = jsonDecode(response.body);
      throw Exception(_extractErrorMessage(responseBody));
    }
  }

  /// Create order from cart
  Future<Order> createOrder(CreateOrderRequest request) async {
    final uri = Uri.parse(Environment.createOrderEndpoint);
    final headers = await _getAuthHeaders();

    log('Create Order Request: ${jsonEncode(request.toJson())}');

    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(request.toJson()),
    );

    log('Create Order Response Status: ${response.statusCode}');
    log('Create Order Response: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseBody = jsonDecode(response.body);
      return Order.fromJson(responseBody);
    } else {
      final responseBody = jsonDecode(response.body);
      throw Exception(_extractErrorMessage(responseBody));
    }
  }

  /// Place (confirm) order
  Future<Order> placeOrder(int orderId) async {
    final uri = Uri.parse(Environment.placeOrderEndpoint(orderId));
    final headers = await _getAuthHeaders();

    log('Place Order Request URL: $uri');

    final response = await http.post(uri, headers: headers);

    log('Place Order Response Status: ${response.statusCode}');
    log('Place Order Response Body: ${response.body}');

    if (response.headers['content-type']?.contains('text/html') ?? false) {
      log('ERROR: Received HTML instead of JSON');
      throw Exception('Server error');
    }

    if (response.statusCode == 200) {
      try {
        final responseBody = jsonDecode(response.body);
        return Order.fromJson(responseBody);
      } catch (e) {
        log('ERROR: Failed to parse JSON: $e');
        throw Exception('Failed to parse server response');
      }
    } else {
      try {
        final responseBody = jsonDecode(response.body);
        throw Exception(_extractErrorMessage(responseBody));
      } catch (e) {
        if (e is Exception && e.toString().contains('Exception:')) {
          rethrow;
        }
        throw Exception('Unexpected error (${response.statusCode})');
      }
    }
  }

  /// Cancel order
  Future<Order> cancelOrder({
    required int orderId,
    required String reason,
  }) async {
    final uri = Uri.parse(Environment.cancelOrderEndpoint(orderId));
    final headers = await _getAuthHeaders();

    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode({'reason': reason}),
    );

    log('Cancel Order Response Status: ${response.statusCode}');
    log('Cancel Order Response: ${response.body}');

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      return Order.fromJson(responseBody);
    } else {
      final responseBody = jsonDecode(response.body);
      throw Exception(_extractErrorMessage(responseBody));
    }
  }

  /// Reorder (create new order from old one)
  Future<Order> reorder(int orderId) async {
    final uri = Uri.parse(Environment.reorderEndpoint(orderId));
    final headers = await _getAuthHeaders();

    final response = await http.post(uri, headers: headers);

    log('Reorder Response Status: ${response.statusCode}');
    log('Reorder Response: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseBody = jsonDecode(response.body);
      return Order.fromJson(responseBody);
    } else {
      final responseBody = jsonDecode(response.body);
      throw Exception(_extractErrorMessage(responseBody));
    }
  }

  /// Track order
  Future<Order> trackOrder(int orderId) async {
    final uri = Uri.parse(Environment.trackOrderEndpoint(orderId));
    final headers = await _getAuthHeaders();

    final response = await http.get(uri, headers: headers);

    log('Track Order Response Status: ${response.statusCode}');
    log('Track Order Response: ${response.body}');

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      return Order.fromJson(responseBody);
    } else {
      final responseBody = jsonDecode(response.body);
      throw Exception(_extractErrorMessage(responseBody));
    }
  }
}

final orderServices = OrderServices();
