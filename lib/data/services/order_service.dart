import 'dart:async';
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

  // all orders
  Future<List<OrderListItem>> getOrders() async {
    final uri = Uri.parse(Environment.ordersEndpoint);
    final headers = await _getAuthHeaders();

    final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 30));

    log('Get Orders Response Status: ${response.statusCode}');
    log('Get Orders Response: ${response.body}');

    if (response.statusCode == 200) {
      late final dynamic responseBody;
      try {
        responseBody = jsonDecode(response.body);
      } on FormatException {
        throw Exception('Invalid server response');
      }
      if (responseBody is List) {
        return responseBody
            .map((item) => OrderListItem.fromJson(item))
            .toList();
      }
      return [];
    } else {
      late final dynamic responseBody;
      try {
        responseBody = jsonDecode(response.body);
      } on FormatException {
        throw Exception('Invalid server response');
      }
      throw Exception(_extractErrorMessage(responseBody));
    }
  }

  // active orders
  Future<List<Order>> getActiveOrders() async {
    final uri = Uri.parse(Environment.activeOrdersEndpoint);
    final headers = await _getAuthHeaders();

    final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 30));

    log('Get Active Orders Response Status: ${response.statusCode}');
    log('Get Active Orders Response: ${response.body}');

    if (response.statusCode == 200) {
      late final dynamic responseBody;
      try {
        responseBody = jsonDecode(response.body);
      } on FormatException {
        throw Exception('Invalid server response');
      }
      if (responseBody is List) {
        return responseBody.map((item) => Order.fromJson(item)).toList();
      } else if (responseBody is Map<String, dynamic>) {
        return [Order.fromJson(responseBody)];
      }
      return [];
    } else {
      late final dynamic responseBody;
      try {
        responseBody = jsonDecode(response.body);
      } on FormatException {
        throw Exception('Invalid server response');
      }
      throw Exception(_extractErrorMessage(responseBody));
    }
  }

  // history (completed + cancelled)
  Future<List<Order>> getOrdersHistory() async {
    final uri = Uri.parse(Environment.ordersHistoryEndpoint);
    final headers = await _getAuthHeaders();

    final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 30));

    log('Get Orders History Response Status: ${response.statusCode}');
    log('Get Orders History Response: ${response.body}');

    if (response.statusCode == 200) {
      late final dynamic responseBody;
      try {
        responseBody = jsonDecode(response.body);
      } on FormatException {
        throw Exception('Invalid server response');
      }
      if (responseBody is List) {
        return responseBody.map((item) => Order.fromJson(item)).toList();
      } else if (responseBody is Map<String, dynamic>) {
        return [Order.fromJson(responseBody)];
      }
      return [];
    } else {
      late final dynamic responseBody;
      try {
        responseBody = jsonDecode(response.body);
      } on FormatException {
        throw Exception('Invalid server response');
      }
      throw Exception(_extractErrorMessage(responseBody));
    }
  }

  // order details
  Future<Order> getOrderDetails(int orderId) async {
    final uri = Uri.parse(Environment.orderDetailsEndpoint(orderId));
    final headers = await _getAuthHeaders();

    final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 30));

    log('Get Order Details Response Status: ${response.statusCode}');
    log('Get Order Details Response: ${response.body}');

    if (response.statusCode == 200) {
      late final dynamic responseBody;
      try {
        responseBody = jsonDecode(response.body);
      } on FormatException {
        throw Exception('Invalid server response');
      }
      return Order.fromJson(responseBody);
    } else {
      late final dynamic responseBody;
      try {
        responseBody = jsonDecode(response.body);
      } on FormatException {
        throw Exception('Invalid server response');
      }
      throw Exception(_extractErrorMessage(responseBody));
    }
  }

  // create order
  Future<Order> createOrder(CreateOrderRequest request) async {
    final uri = Uri.parse(Environment.createOrderEndpoint);
    final headers = await _getAuthHeaders();

    log('Create Order Request: ${jsonEncode(request.toJson())}');

    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(request.toJson()),
    ).timeout(const Duration(seconds: 30));

    log('Create Order Response Status: ${response.statusCode}');
    log('Create Order Response: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      late final dynamic responseBody;
      try {
        responseBody = jsonDecode(response.body);
      } on FormatException {
        throw Exception('Invalid server response');
      }
      return Order.fromJson(responseBody);
    } else {
      late final dynamic responseBody;
      try {
        responseBody = jsonDecode(response.body);
      } on FormatException {
        throw Exception('Invalid server response');
      }
      throw Exception(_extractErrorMessage(responseBody));
    }
  }

  // place (confirm)
  Future<Order> placeOrder(int orderId) async {
    final uri = Uri.parse(Environment.placeOrderEndpoint(orderId));
    final headers = await _getAuthHeaders();

    log('Place Order Request URL: $uri');

    final response = await http.post(uri, headers: headers).timeout(const Duration(seconds: 30));

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

  // cancel
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
    ).timeout(const Duration(seconds: 30));

    log('Cancel Order Response Status: ${response.statusCode}');
    log('Cancel Order Response: ${response.body}');

    if (response.statusCode == 200) {
      late final dynamic responseBody;
      try {
        responseBody = jsonDecode(response.body);
      } on FormatException {
        throw Exception('Invalid server response');
      }
      return Order.fromJson(responseBody);
    } else {
      late final dynamic responseBody;
      try {
        responseBody = jsonDecode(response.body);
      } on FormatException {
        throw Exception('Invalid server response');
      }
      throw Exception(_extractErrorMessage(responseBody));
    }
  }

  // reorder
  Future<Order> reorder(int orderId) async {
    final uri = Uri.parse(Environment.reorderEndpoint(orderId));
    final headers = await _getAuthHeaders();

    final response = await http.post(uri, headers: headers).timeout(const Duration(seconds: 30));

    log('Reorder Response Status: ${response.statusCode}');
    log('Reorder Response: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      late final dynamic responseBody;
      try {
        responseBody = jsonDecode(response.body);
      } on FormatException {
        throw Exception('Invalid server response');
      }
      return Order.fromJson(responseBody);
    } else {
      late final dynamic responseBody;
      try {
        responseBody = jsonDecode(response.body);
      } on FormatException {
        throw Exception('Invalid server response');
      }
      throw Exception(_extractErrorMessage(responseBody));
    }
  }

  // track
  Future<Order> trackOrder(int orderId) async {
    final uri = Uri.parse(Environment.trackOrderEndpoint(orderId));
    final headers = await _getAuthHeaders();

    final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 30));

    log('Track Order Response Status: ${response.statusCode}');
    log('Track Order Response: ${response.body}');

    if (response.statusCode == 200) {
      late final dynamic responseBody;
      try {
        responseBody = jsonDecode(response.body);
      } on FormatException {
        throw Exception('Invalid server response');
      }
      return Order.fromJson(responseBody);
    } else {
      late final dynamic responseBody;
      try {
        responseBody = jsonDecode(response.body);
      } on FormatException {
        throw Exception('Invalid server response');
      }
      throw Exception(_extractErrorMessage(responseBody));
    }
  }
}

final orderServices = OrderServices();
