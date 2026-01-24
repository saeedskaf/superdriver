import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:superdriver/data/env/environment.dart';
import 'package:superdriver/data/local_secure/secure_storage.dart';
import 'package:superdriver/domain/models/cart_model.dart';

class CartServices {
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await secureStorage.getAccessToken();
    print(token);
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
    if (responseBody['error'] != null) {
      return responseBody['error'].toString();
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
    print('Get Cart Response: $responseBody');

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
    print('Get All Carts Response: $responseBody');

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
    print('Add to Cart Response: $responseBody');

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
    print('Update Cart Item Response: $responseBody');

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
    print('Delete Cart Item Response: $responseBody');

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
    print('Clear Cart Status: ${response.statusCode}');

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
    print('Delete Cart Status: ${response.statusCode}');

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
    print('Apply Coupon Response: $responseBody');

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
    print('Remove Coupon Response: $responseBody');

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
    print('Validate Cart Status: ${response.statusCode}');

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
