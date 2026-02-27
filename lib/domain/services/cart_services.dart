import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:superdriver/data/env/environment.dart';
import 'package:superdriver/data/local_secure/secure_storage.dart';
import 'package:superdriver/domain/models/cart_model.dart';

class CartServices {
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await secureStorage.getAccessToken();
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
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
    return 'حدث خطأ غير متوقع';
  }

  /// Get cart by cart_id or restaurant_id
  Future<Cart> getCart({int? cartId, int? restaurantId}) async {
    final queryParams = <String, String>{};
    if (cartId != null) {
      queryParams['cart_id'] = cartId.toString();
    }
    if (restaurantId != null) {
      queryParams['restaurant_id'] = restaurantId.toString();
    }

    final uri = Uri.parse(
      Environment.cartEndpoint,
    ).replace(queryParameters: queryParams);
    final headers = await _getAuthHeaders();

    final response = await http.get(uri, headers: headers);
    final responseBody = jsonDecode(response.body);
    log('Get Cart Response: $responseBody');

    if (response.statusCode == 200) {
      return Cart.fromJson(responseBody);
    } else {
      throw Exception(_extractErrorMessage(responseBody));
    }
  }

  /// Get all active carts for the user
  Future<AllCartsResponse> getAllCarts() async {
    final uri = Uri.parse(Environment.allCartsEndpoint);
    final headers = await _getAuthHeaders();

    final response = await http.get(uri, headers: headers);
    final responseBody = jsonDecode(response.body);
    log('Get All Carts Response: $responseBody');

    if (response.statusCode == 200) {
      return AllCartsResponse.fromJson(responseBody);
    } else {
      throw Exception(_extractErrorMessage(responseBody));
    }
  }

  /// Add item to cart
  Future<Cart> addToCart(AddToCartRequest request) async {
    final uri = Uri.parse(Environment.addToCartEndpoint);
    final headers = await _getAuthHeaders();

    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(request.toJson()),
    );

    final responseBody = jsonDecode(response.body);
    log('Add to Cart Response: $responseBody');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Cart.fromJson(responseBody);
    } else {
      throw Exception(_extractErrorMessage(responseBody));
    }
  }

  /// Update cart item quantity
  Future<Cart> updateCartItem({
    required int itemId,
    required int quantity,
    String? specialInstructions,
  }) async {
    final uri = Uri.parse(Environment.cartItemEndpoint(itemId));
    final headers = await _getAuthHeaders();

    final body = <String, dynamic>{'quantity': quantity};
    if (specialInstructions != null) {
      body['special_instructions'] = specialInstructions;
    }

    final response = await http.patch(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );

    final responseBody = jsonDecode(response.body);
    log('Update Cart Item Response: $responseBody');

    if (response.statusCode == 200) {
      return Cart.fromJson(responseBody);
    } else {
      throw Exception(_extractErrorMessage(responseBody));
    }
  }

  /// Delete cart item
  Future<Cart> deleteCartItem(int itemId) async {
    final uri = Uri.parse(Environment.cartItemEndpoint(itemId));
    final headers = await _getAuthHeaders();

    final response = await http.delete(uri, headers: headers);

    final responseBody = jsonDecode(response.body);
    log('Delete Cart Item Response: $responseBody');

    if (response.statusCode == 200) {
      return Cart.fromJson(responseBody);
    } else {
      throw Exception(_extractErrorMessage(responseBody));
    }
  }

  /// Clear entire cart (removes all items but keeps the cart)
  Future<void> clearCart(int cartId) async {
    final uri = Uri.parse(Environment.clearCartEndpoint(cartId));
    final headers = await _getAuthHeaders();

    final response = await http.delete(uri, headers: headers);
    log('Clear Cart Status: ${response.statusCode}');

    if (response.statusCode != 204 && response.statusCode != 200) {
      final responseBody = jsonDecode(response.body);
      throw Exception(_extractErrorMessage(responseBody));
    }
  }

  /// Delete cart completely
  Future<void> deleteCart(int cartId) async {
    final uri = Uri.parse(
      Environment.deleteCartEndpoint,
    ).replace(queryParameters: {'cart_id': cartId.toString()});
    final headers = await _getAuthHeaders();

    final response = await http.delete(uri, headers: headers);
    log('Delete Cart Status: ${response.statusCode}');

    if (response.statusCode != 204 && response.statusCode != 200) {
      if (response.body.isNotEmpty) {
        final responseBody = jsonDecode(response.body);
        throw Exception(_extractErrorMessage(responseBody));
      }
      throw Exception('Failed to delete cart');
    }
  }

  /// Apply coupon to cart
  Future<Cart> applyCoupon({required int cartId, required String code}) async {
    final uri = Uri.parse(Environment.applyCouponEndpoint(cartId));
    final headers = await _getAuthHeaders();

    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode({'code': code}),
    );

    final responseBody = jsonDecode(response.body);
    log('Apply Coupon Response: $responseBody');

    if (response.statusCode == 200) {
      return Cart.fromJson(responseBody);
    } else {
      throw Exception(_extractErrorMessage(responseBody));
    }
  }

  /// Remove coupon from cart
  Future<Cart> removeCoupon(int cartId) async {
    final uri = Uri.parse(Environment.removeCouponEndpoint(cartId));
    final headers = await _getAuthHeaders();

    final response = await http.delete(uri, headers: headers);

    final responseBody = jsonDecode(response.body);
    log('Remove Coupon Response: $responseBody');

    if (response.statusCode == 200) {
      return Cart.fromJson(responseBody);
    } else {
      throw Exception(_extractErrorMessage(responseBody));
    }
  }

  /// Validate cart for checkout
  Future<bool> validateCart(int cartId) async {
    final uri = Uri.parse(
      Environment.validateCartEndpoint,
    ).replace(queryParameters: {'cart_id': cartId.toString()});
    final headers = await _getAuthHeaders();

    final response = await http.get(uri, headers: headers);
    log('Validate Cart Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      return true;
    } else {
      if (response.body.isNotEmpty) {
        final responseBody = jsonDecode(response.body);
        throw Exception(_extractErrorMessage(responseBody));
      }
      throw Exception('Cart validation failed');
    }
  }
}

final cartServices = CartServices();
