import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:superdriver/data/env/environment.dart';
import 'package:superdriver/data/local_secure/secure_storage.dart';
import 'package:superdriver/domain/models/order_model.dart';

class OrderServices {
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await secureStorage.getAccessToken();
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
  }

  String _extractErrorMessage(Map<String, dynamic> responseBody) {
    if (responseBody['errors'] != null) {
      final errors = responseBody['errors'] as Map<String, dynamic>;
      final firstError = errors.values.first;
      if (firstError is List && firstError.isNotEmpty) {
        return firstError[0].toString();
      }
    }
    if (responseBody['message'] != null) {
      return responseBody['message'].toString();
    }
    if (responseBody['detail'] != null) {
      return responseBody['detail'].toString();
    }
    return 'حدث خطأ غير متوقع';
  }

  /// Get all user orders
  Future<List<OrderListItem>> getOrders() async {
    final uri = Uri.parse(Environment.ordersEndpoint);
    final headers = await _getAuthHeaders();

    final response = await http.get(uri, headers: headers);
    final responseBody = jsonDecode(response.body);
    print('Get Orders Response: $responseBody');

    if (response.statusCode == 200) {
      if (responseBody is List) {
        return responseBody
            .map((item) => OrderListItem.fromJson(item))
            .toList();
      }
      return [];
    } else {
      throw Exception(_extractErrorMessage(responseBody));
    }
  }

  /// Get active orders
  Future<List<Order>> getActiveOrders() async {
    final uri = Uri.parse(Environment.activeOrdersEndpoint);
    final headers = await _getAuthHeaders();

    final response = await http.get(uri, headers: headers);
    final responseBody = jsonDecode(response.body);
    print('Get Active Orders Response: $responseBody');

    if (response.statusCode == 200) {
      if (responseBody is List) {
        return responseBody.map((item) => Order.fromJson(item)).toList();
      } else if (responseBody is Map<String, dynamic>) {
        return [Order.fromJson(responseBody)];
      }
      return [];
    } else {
      throw Exception(_extractErrorMessage(responseBody));
    }
  }

  /// Get orders history (completed + cancelled)
  Future<List<Order>> getOrdersHistory() async {
    final uri = Uri.parse(Environment.ordersHistoryEndpoint);
    final headers = await _getAuthHeaders();

    final response = await http.get(uri, headers: headers);
    final responseBody = jsonDecode(response.body);
    print('Get Orders History Response: $responseBody');

    if (response.statusCode == 200) {
      if (responseBody is List) {
        return responseBody.map((item) => Order.fromJson(item)).toList();
      } else if (responseBody is Map<String, dynamic>) {
        return [Order.fromJson(responseBody)];
      }
      return [];
    } else {
      throw Exception(_extractErrorMessage(responseBody));
    }
  }

  /// Get order details
  Future<Order> getOrderDetails(int orderId) async {
    final uri = Uri.parse(Environment.orderDetailsEndpoint(orderId));
    final headers = await _getAuthHeaders();

    final response = await http.get(uri, headers: headers);
    final responseBody = jsonDecode(response.body);
    print('Get Order Details Response: $responseBody');

    if (response.statusCode == 200) {
      return Order.fromJson(responseBody);
    } else {
      throw Exception(_extractErrorMessage(responseBody));
    }
  }

  /// Create order from cart
  Future<Order> createOrder(CreateOrderRequest request) async {
    final uri = Uri.parse(Environment.createOrderEndpoint);
    final headers = await _getAuthHeaders();

    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(request.toJson()),
    );

    final responseBody = jsonDecode(response.body);
    print('Create Order Response: $responseBody');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Order.fromJson(responseBody);
    } else {
      throw Exception(_extractErrorMessage(responseBody));
    }
  }

  /// Place (confirm) order
  Future<Order> placeOrder(int orderId) async {
    final uri = Uri.parse(Environment.placeOrderEndpoint(orderId));
    final headers = await _getAuthHeaders();

    final response = await http.post(uri, headers: headers);

    final responseBody = jsonDecode(response.body);
    print('Place Order Response: $responseBody');

    if (response.statusCode == 200) {
      return Order.fromJson(responseBody);
    } else {
      throw Exception(_extractErrorMessage(responseBody));
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

    final responseBody = jsonDecode(response.body);
    print('Cancel Order Response: $responseBody');

    if (response.statusCode == 200) {
      return Order.fromJson(responseBody);
    } else {
      throw Exception(_extractErrorMessage(responseBody));
    }
  }

  /// Reorder (create new order from old one)
  Future<Order> reorder(int orderId) async {
    final uri = Uri.parse(Environment.reorderEndpoint(orderId));
    final headers = await _getAuthHeaders();

    final response = await http.post(uri, headers: headers);

    final responseBody = jsonDecode(response.body);
    print('Reorder Response: $responseBody');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Order.fromJson(responseBody);
    } else {
      throw Exception(_extractErrorMessage(responseBody));
    }
  }

  /// Track order
  Future<Order> trackOrder(int orderId) async {
    final uri = Uri.parse(Environment.trackOrderEndpoint(orderId));
    final headers = await _getAuthHeaders();

    final response = await http.get(uri, headers: headers);
    final responseBody = jsonDecode(response.body);
    print('Track Order Response: $responseBody');

    if (response.statusCode == 200) {
      return Order.fromJson(responseBody);
    } else {
      throw Exception(_extractErrorMessage(responseBody));
    }
  }
}

final orderServices = OrderServices();
