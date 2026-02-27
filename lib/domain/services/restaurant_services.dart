import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:superdriver/data/env/environment.dart';
import 'package:superdriver/data/local_secure/secure_storage.dart';
import 'package:superdriver/domain/models/restaurant_model.dart';

class RestaurantServices {
  // ============================================================
  // HELPERS
  // ============================================================

  Future<Map<String, String>> _getHeaders({bool requiresAuth = false}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
    };
    if (requiresAuth) {
      final token = await secureStorage.getAccessToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  /// Generic GET → decoded JSON (throws on non-200)
  Future<dynamic> _get(
    String url, {
    Map<String, String>? queryParams,
    bool requiresAuth = false,
  }) async {
    final uri = Uri.parse(url).replace(
      queryParameters: queryParams?.isNotEmpty == true ? queryParams : null,
    );
    final headers = await _getHeaders(requiresAuth: requiresAuth);
    final response = await http.get(uri, headers: headers);
    log('GET $uri → ${response.statusCode}: ${response.body}');

    if (response.statusCode == 200) return jsonDecode(response.body);

    final body = _tryDecodeJson(response.body);
    throw Exception(_extractErrorMessage(body));
  }

  /// Parse JSON into List<RestaurantListItem>.
  /// Handles: raw List, { "results": [...] }, { "restaurants": [...] },
  /// and single-object { "id": ... }.
  List<RestaurantListItem> _parseRestaurantList(dynamic json) {
    if (json is List) {
      return json.map((e) => RestaurantListItem.fromJson(e)).toList();
    }
    if (json is Map<String, dynamic>) {
      for (final key in ['results', 'restaurants']) {
        if (json[key] is List) {
          return (json[key] as List)
              .map((e) => RestaurantListItem.fromJson(e))
              .toList();
        }
      }
      if (json['id'] != null) {
        return [RestaurantListItem.fromJson(json)];
      }
    }
    return [];
  }

  /// Parse JSON into List<RestaurantCategory>.
  List<RestaurantCategory> _parseCategoryList(dynamic json) {
    if (json is List) {
      return json.map((e) => RestaurantCategory.fromJson(e)).toList();
    }
    if (json is Map<String, dynamic> && json['results'] is List) {
      return (json['results'] as List)
          .map((e) => RestaurantCategory.fromJson(e))
          .toList();
    }
    return [];
  }

  String _extractErrorMessage(dynamic body) {
    if (body is Map<String, dynamic>) {
      for (final value in body.values) {
        if (value is List && value.isNotEmpty) return value[0].toString();
        if (value is String) return value;
      }
    }
    return 'حدث خطأ غير متوقع';
  }

  dynamic _tryDecodeJson(String body) {
    try {
      return jsonDecode(body);
    } catch (_) {
      return {'message': body};
    }
  }

  // ============================================================
  // RESTAURANTS
  // ============================================================

  Future<List<RestaurantListItem>> getRestaurants({
    RestaurantFilterParams? filters,
  }) async {
    final json = await _get(
      Environment.restaurantsEndpoint,
      queryParams: filters?.toQueryParams(),
    );
    return _parseRestaurantList(json);
  }

  Future<RestaurantDetail> getRestaurantDetails(
    String slug, {
    double? lat,
    double? lng,
  }) async {
    final params = <String, String>{};
    if (lat != null && lng != null) {
      params['lat'] = '$lat';
      params['lng'] = '$lng';
    }
    final json = await _get(
      Environment.restaurantDetailsEndpoint(slug),
      queryParams: params.isNotEmpty ? params : null,
    );
    return RestaurantDetail.fromJson(json);
  }

  Future<Map<String, dynamic>> getRestaurantMenu(String slug) async {
    return await _get(Environment.restaurantMenuEndpoint(slug));
  }

  Future<Map<String, dynamic>> getRestaurantReviews(String slug) async {
    return await _get(Environment.restaurantReviewsEndpoint(slug));
  }

  // ============================================================
  // CATEGORIES
  // ============================================================

  Future<List<RestaurantCategory>> getCategories() async {
    final json = await _get(Environment.restaurantCategoriesEndpoint);
    return _parseCategoryList(json);
  }

  Future<RestaurantCategory> getCategoryDetails(String slug) async {
    final json = await _get(
      Environment.restaurantCategoryDetailsEndpoint(slug),
    );
    return RestaurantCategory.fromJson(json);
  }

  Future<List<RestaurantListItem>> getCategoryRestaurants(String slug) async {
    final json = await _get(
      Environment.restaurantCategoryRestaurantsEndpoint(slug),
    );
    return _parseRestaurantList(json);
  }

  // ============================================================
  // LOCATION & SEARCH
  // ============================================================

  Future<List<RestaurantListItem>> getNearbyRestaurants({
    required double lat,
    required double lng,
    double? radius,
  }) async {
    final params = <String, String>{'lat': '$lat', 'lng': '$lng'};
    if (radius != null) params['radius'] = '$radius';

    final json = await _get(
      Environment.restaurantsNearbyEndpoint,
      queryParams: params,
      requiresAuth: true,
    );
    return _parseRestaurantList(json);
  }

  Future<List<RestaurantListItem>> searchRestaurants(String query) async {
    final json = await _get(
      Environment.restaurantsSearchEndpoint,
      queryParams: {'q': query},
    );
    return _parseRestaurantList(json);
  }
}

final restaurantServices = RestaurantServices();
