import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:superdriver/data/env/environment.dart';
import 'package:superdriver/domain/models/menu_model.dart';

class MenuServices {
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

  /// Get menu categories for a restaurant
  Future<List<MenuCategory>> getCategories({required int restaurantId}) async {
    final uri = Uri.parse(Environment.menuCategoriesEndpoint).replace(
      queryParameters: {
        'restaurant': restaurantId.toString(),
        'is_active': 'true',
      },
    );

    try {
      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      final responseBody = jsonDecode(response.body);
      log('Get Menu Categories Response: $responseBody');

      if (response.statusCode == 200) {
        if (responseBody is List) {
          return responseBody.map((e) => MenuCategory.fromJson(e)).toList();
        }
        if (responseBody is Map<String, dynamic> &&
            responseBody['id'] != null) {
          return [MenuCategory.fromJson(responseBody)];
        }
        return [];
      } else {
        throw Exception(_extractErrorMessage(responseBody));
      }
    } catch (e) {
      log('Error loading categories: $e');
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('فشل تحميل القائمة');
    }
  }

  /// Get products for a specific restaurant and category
  Future<List<ProductSimpleMenu>> getProducts({
    required int restaurantId,
    int? categoryId,
    String? search,
  }) async {
    final queryParams = <String, String>{
      'restaurant': restaurantId.toString(),
      'is_available': 'true',
    };

    if (categoryId != null) {
      queryParams['category'] = categoryId.toString();
    }

    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }

    final uri = Uri.parse(
      Environment.menuProductsEndpoint,
    ).replace(queryParameters: queryParams);

    try {
      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      final responseBody = jsonDecode(response.body);
      log('Get Products Response: $responseBody');

      if (response.statusCode == 200) {
        if (responseBody is List) {
          return responseBody
              .map((e) => ProductSimpleMenu.fromJson(e))
              .toList();
        }
        return [];
      } else {
        throw Exception(_extractErrorMessage(responseBody));
      }
    } catch (e) {
      log('Error loading products: $e');
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('فشل تحميل المنتجات');
    }
  }

  /// Get product details by slug
  Future<ProductDetail> getProductDetails(String slug) async {
    final uri = Uri.parse(Environment.menuProductDetailsEndpoint(slug));

    try {
      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      final responseBody = jsonDecode(response.body);
      log('Get Product Details Response: $responseBody');

      if (response.statusCode == 200) {
        return ProductDetail.fromJson(responseBody);
      } else {
        throw Exception(_extractErrorMessage(responseBody));
      }
    } catch (e) {
      log('Error loading product details: $e');
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('فشل تحميل تفاصيل المنتج');
    }
  }

  /// Get deals (products with discounts)
  Future<List<ProductSimpleMenu>> getDeals() async {
    final uri = Uri.parse(Environment.menuDealsEndpoint);

    try {
      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      final responseBody = jsonDecode(response.body);
      log('Get Deals Response: $responseBody');

      if (response.statusCode == 200) {
        if (responseBody is List) {
          return responseBody
              .map((e) => ProductSimpleMenu.fromJson(e))
              .toList();
        }
        return [];
      } else {
        throw Exception(_extractErrorMessage(responseBody));
      }
    } catch (e) {
      log('Error loading deals: $e');
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('فشل تحميل العروض');
    }
  }

  /// Get featured products
  Future<List<ProductSimpleMenu>> getFeaturedProducts() async {
    final uri = Uri.parse(Environment.menuFeaturedEndpoint);

    try {
      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      final responseBody = jsonDecode(response.body);
      log('Get Featured Products Response: $responseBody');

      if (response.statusCode == 200) {
        if (responseBody is List) {
          return responseBody
              .map((e) => ProductSimpleMenu.fromJson(e))
              .toList();
        }
        return [];
      } else {
        throw Exception(_extractErrorMessage(responseBody));
      }
    } catch (e) {
      log('Error loading featured products: $e');
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('فشل تحميل المنتجات المميزة');
    }
  }

  /// Get popular products
  Future<List<ProductSimpleMenu>> getPopularProducts() async {
    final uri = Uri.parse(Environment.menuPopularEndpoint);

    try {
      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      final responseBody = jsonDecode(response.body);
      log('Get Popular Products Response: $responseBody');

      if (response.statusCode == 200) {
        if (responseBody is List) {
          return responseBody
              .map((e) => ProductSimpleMenu.fromJson(e))
              .toList();
        }
        return [];
      } else {
        throw Exception(_extractErrorMessage(responseBody));
      }
    } catch (e) {
      log('Error loading popular products: $e');
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('فشل تحميل المنتجات الشائعة');
    }
  }
}

final menuServices = MenuServices();
