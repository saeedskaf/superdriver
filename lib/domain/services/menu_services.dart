import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:superdriver/data/env/environment.dart';
import 'package:superdriver/data/local_secure/secure_storage.dart';
import 'package:superdriver/domain/models/menu_model.dart';

class MenuServices {
  Future<Map<String, String>> _getHeaders() async {
    final token = await secureStorage.getAccessToken();
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  String _extractErrorMessage(Map<String, dynamic> responseBody) {
    if (responseBody['error'] != null) {
      return responseBody['error'].toString();
    }
    if (responseBody['errors'] != null) {
      final errors = responseBody['errors'];
      if (errors is Map<String, dynamic>) {
        final firstError = errors.values.first;
        if (firstError is List && firstError.isNotEmpty) {
          return firstError[0].toString();
        }
        return firstError.toString();
      }
      return errors.toString();
    }
    if (responseBody['message'] != null) {
      return responseBody['message'].toString();
    }
    if (responseBody['detail'] != null) {
      return responseBody['detail'].toString();
    }
    return 'حدث خطأ غير متوقع';
  }

  /// Get menu categories for a restaurant
  Future<List<MenuCategory>> getCategories({
    required int restaurantId,
    bool? isActive,
  }) async {
    final queryParams = <String, String>{
      'restaurant': restaurantId.toString(),
    };
    if (isActive != null) {
      queryParams['is_active'] = isActive.toString();
    }

    final uri = Uri.parse(Environment.menuCategoriesEndpoint)
        .replace(queryParameters: queryParams);
    final headers = await _getHeaders();

    final response = await http.get(uri, headers: headers);
    final responseBody = jsonDecode(response.body);
    print('Get Menu Categories Response: $responseBody');

    if (response.statusCode == 200) {
      if (responseBody is List) {
        return responseBody.map((e) => MenuCategory.fromJson(e)).toList();
      }
      return [];
    } else {
      throw Exception(_extractErrorMessage(responseBody));
    }
  }

  /// Get category details with products
  Future<MenuCategory> getCategoryDetails(int categoryId) async {
    final uri = Uri.parse(Environment.menuCategoryDetailsEndpoint(categoryId));
    final headers = await _getHeaders();

    final response = await http.get(uri, headers: headers);
    final responseBody = jsonDecode(response.body);
    print('Get Category Details Response: $responseBody');

    if (response.statusCode == 200) {
      return MenuCategory.fromJson(responseBody);
    } else {
      throw Exception(_extractErrorMessage(responseBody));
    }
  }

  /// Get products with filters
  Future<List<ProductSimpleMenu>> getProducts({
    int? restaurantId,
    int? categoryId,
    int? subcategoryId,
    String? search,
    String? ordering,
    bool? hasDiscount,
    bool? isAvailable,
    bool? isFeatured,
    bool? isPopular,
  }) async {
    final queryParams = <String, String>{};
    
    if (restaurantId != null) queryParams['restaurant'] = restaurantId.toString();
    if (categoryId != null) queryParams['category'] = categoryId.toString();
    if (subcategoryId != null) queryParams['subcategory'] = subcategoryId.toString();
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (ordering != null) queryParams['ordering'] = ordering;
    if (hasDiscount != null) queryParams['has_discount'] = hasDiscount.toString();
    if (isAvailable != null) queryParams['is_available'] = isAvailable.toString();
    if (isFeatured != null) queryParams['is_featured'] = isFeatured.toString();
    if (isPopular != null) queryParams['is_popular'] = isPopular.toString();

    final uri = Uri.parse(Environment.menuProductsEndpoint)
        .replace(queryParameters: queryParams.isEmpty ? null : queryParams);
    final headers = await _getHeaders();

    final response = await http.get(uri, headers: headers);
    final responseBody = jsonDecode(response.body);
    print('Get Products Response: $responseBody');

    if (response.statusCode == 200) {
      if (responseBody is List) {
        return responseBody.map((e) => ProductSimpleMenu.fromJson(e)).toList();
      }
      return [];
    } else {
      throw Exception(_extractErrorMessage(responseBody));
    }
  }

  /// Get product details by slug
  Future<ProductDetail> getProductDetails(String slug) async {
    final uri = Uri.parse(Environment.menuProductDetailsEndpoint(slug));
    final headers = await _getHeaders();

    final response = await http.get(uri, headers: headers);
    final responseBody = jsonDecode(response.body);
    print('Get Product Details Response: $responseBody');

    if (response.statusCode == 200) {
      return ProductDetail.fromJson(responseBody);
    } else {
      throw Exception(_extractErrorMessage(responseBody));
    }
  }

  /// Get deals (products with discounts)
  Future<List<ProductSimpleMenu>> getDeals() async {
    final uri = Uri.parse(Environment.menuDealsEndpoint);
    final headers = await _getHeaders();

    final response = await http.get(uri, headers: headers);
    final responseBody = jsonDecode(response.body);
    print('Get Deals Response: $responseBody');

    if (response.statusCode == 200) {
      if (responseBody is List) {
        return responseBody.map((e) => ProductSimpleMenu.fromJson(e)).toList();
      }
      return [];
    } else {
      throw Exception(_extractErrorMessage(responseBody));
    }
  }

  /// Get featured products
  Future<List<ProductSimpleMenu>> getFeaturedProducts() async {
    final uri = Uri.parse(Environment.menuFeaturedEndpoint);
    final headers = await _getHeaders();

    final response = await http.get(uri, headers: headers);
    final responseBody = jsonDecode(response.body);
    print('Get Featured Products Response: $responseBody');

    if (response.statusCode == 200) {
      if (responseBody is List) {
        return responseBody.map((e) => ProductSimpleMenu.fromJson(e)).toList();
      }
      return [];
    } else {
      throw Exception(_extractErrorMessage(responseBody));
    }
  }

  /// Get popular products
  Future<List<ProductSimpleMenu>> getPopularProducts() async {
    final uri = Uri.parse(Environment.menuPopularEndpoint);
    final headers = await _getHeaders();

    final response = await http.get(uri, headers: headers);
    final responseBody = jsonDecode(response.body);
    print('Get Popular Products Response: $responseBody');

    if (response.statusCode == 200) {
      if (responseBody is List) {
        return responseBody.map((e) => ProductSimpleMenu.fromJson(e)).toList();
      }
      return [];
    } else {
      throw Exception(_extractErrorMessage(responseBody));
    }
  }
}

final menuServices = MenuServices();
