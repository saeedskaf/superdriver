import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:superdriver/data/env/environment.dart';
import 'package:superdriver/data/local_secure/secure_storage.dart';
import 'package:superdriver/domain/models/restaurant_model.dart';

class RestaurantServices {
  Future<Map<String, String>> _getHeaders({bool requiresAuth = false}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    };

    if (requiresAuth) {
      final token = await secureStorage.getAccessToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
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

  /// Get list of restaurants with filters
  Future<List<RestaurantListItem>> getRestaurants({
    RestaurantFilterParams? filters,
  }) async {
    final queryParams = filters?.toQueryParams();
    final uri = Uri.parse(Environment.restaurantsEndpoint).replace(
      queryParameters: queryParams?.isNotEmpty == true ? queryParams : null,
    );
    final headers = await _getHeaders();

    final response = await http.get(uri, headers: headers);
    final responseBody = jsonDecode(response.body);
    print('Get Restaurants Response: $responseBody');

    if (response.statusCode == 200) {
      if (responseBody is List) {
        return responseBody.map((e) => RestaurantListItem.fromJson(e)).toList();
      }
      return [];
    } else {
      throw Exception(_extractErrorMessage(responseBody));
    }
  }

  /// Get restaurant details by slug
  Future<RestaurantDetail> getRestaurantDetails(String slug) async {
    final uri = Uri.parse(Environment.restaurantDetailsEndpoint(slug));
    final headers = await _getHeaders();

    final response = await http.get(uri, headers: headers);
    final responseBody = jsonDecode(response.body);
    print('Get Restaurant Details Response: $responseBody');

    if (response.statusCode == 200) {
      return RestaurantDetail.fromJson(responseBody);
    } else {
      throw Exception(_extractErrorMessage(responseBody));
    }
  }

  /// Get restaurant menu
  Future<Map<String, dynamic>> getRestaurantMenu(String slug) async {
    final uri = Uri.parse(Environment.restaurantMenuEndpoint(slug));
    final headers = await _getHeaders();

    final response = await http.get(uri, headers: headers);
    final responseBody = jsonDecode(response.body);
    print('Get Restaurant Menu Response: $responseBody');

    if (response.statusCode == 200) {
      return responseBody;
    } else {
      throw Exception(_extractErrorMessage(responseBody));
    }
  }

  /// Get restaurant reviews
  Future<Map<String, dynamic>> getRestaurantReviews(String slug) async {
    final uri = Uri.parse(Environment.restaurantReviewsEndpoint(slug));
    final headers = await _getHeaders();

    final response = await http.get(uri, headers: headers);
    final responseBody = jsonDecode(response.body);
    print('Get Restaurant Reviews Response: $responseBody');

    if (response.statusCode == 200) {
      return responseBody;
    } else {
      throw Exception(_extractErrorMessage(responseBody));
    }
  }

  /// Get all restaurant categories
  Future<List<RestaurantCategory>> getCategories() async {
    final uri = Uri.parse(Environment.restaurantCategoriesEndpoint);
    final headers = await _getHeaders();

    final response = await http.get(uri, headers: headers);
    final responseBody = jsonDecode(response.body);
    print('Get Restaurant Categories Response: $responseBody');

    if (response.statusCode == 200) {
      if (responseBody is List) {
        return responseBody.map((e) => RestaurantCategory.fromJson(e)).toList();
      }
      return [];
    } else {
      throw Exception(_extractErrorMessage(responseBody));
    }
  }

  /// Get category details by slug
  Future<RestaurantCategory> getCategoryDetails(String slug) async {
    final uri = Uri.parse(Environment.restaurantCategoryDetailsEndpoint(slug));
    final headers = await _getHeaders();

    final response = await http.get(uri, headers: headers);
    final responseBody = jsonDecode(response.body);
    print('Get Category Details Response: $responseBody');

    if (response.statusCode == 200) {
      return RestaurantCategory.fromJson(responseBody);
    } else {
      throw Exception(_extractErrorMessage(responseBody));
    }
  }

  /// Get restaurants in a category
  Future<List<RestaurantListItem>> getCategoryRestaurants(String slug) async {
    final uri =
        Uri.parse(Environment.restaurantCategoryRestaurantsEndpoint(slug));
    final headers = await _getHeaders();

    final response = await http.get(uri, headers: headers);
    final responseBody = jsonDecode(response.body);
    print('Get Category Restaurants Response: $responseBody');

    if (response.statusCode == 200) {
      if (responseBody is List) {
        return responseBody.map((e) => RestaurantListItem.fromJson(e)).toList();
      }
      // Handle case where API returns object instead of list
      return [];
    } else {
      throw Exception(_extractErrorMessage(responseBody));
    }
  }

  /// Get nearby restaurants
  Future<List<RestaurantListItem>> getNearbyRestaurants({
    required double lat,
    required double lng,
    double? radius,
  }) async {
    final queryParams = <String, String>{
      'lat': lat.toString(),
      'lng': lng.toString(),
    };
    if (radius != null) {
      queryParams['radius'] = radius.toString();
    }

    final uri = Uri.parse(Environment.restaurantsNearbyEndpoint)
        .replace(queryParameters: queryParams);
    final headers = await _getHeaders(requiresAuth: true);

    final response = await http.get(uri, headers: headers);
    final responseBody = jsonDecode(response.body);
    print('Get Nearby Restaurants Response: $responseBody');

    if (response.statusCode == 200) {
      if (responseBody is List) {
        return responseBody.map((e) => RestaurantListItem.fromJson(e)).toList();
      }
      // Handle case where API returns single object
      if (responseBody is Map<String, dynamic> && responseBody['id'] != null) {
        return [RestaurantListItem.fromJson(responseBody)];
      }
      return [];
    } else {
      throw Exception(_extractErrorMessage(responseBody));
    }
  }

  /// Search restaurants (and products)
  Future<List<RestaurantListItem>> searchRestaurants(String query) async {
    final uri = Uri.parse(Environment.restaurantsSearchEndpoint).replace(
      queryParameters: {'q': query},
    );
    final headers = await _getHeaders();

    final response = await http.get(uri, headers: headers);
    final responseBody = jsonDecode(response.body);
    print('Search Restaurants Response: $responseBody');

    if (response.statusCode == 200) {
      if (responseBody is List) {
        return responseBody.map((e) => RestaurantListItem.fromJson(e)).toList();
      }
      return [];
    } else {
      throw Exception(_extractErrorMessage(responseBody));
    }
  }
}

final restaurantServices = RestaurantServices();
