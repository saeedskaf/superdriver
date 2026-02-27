import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:superdriver/data/env/environment.dart';
import 'package:superdriver/data/local_secure/secure_storage.dart';
import 'package:superdriver/domain/models/home_model.dart';
import 'package:superdriver/domain/models/restaurant_model.dart';

class HomeServices {
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

  Future<bool> isAuthenticated() async {
    final token = await secureStorage.getAccessToken();
    return token != null && token.isNotEmpty;
  }

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

  /// Build location query params (only if lat/lng are provided)
  Map<String, String>? _locationParams(double? lat, double? lng) {
    if (lat == null || lng == null) return null;
    return {'lat': '$lat', 'lng': '$lng'};
  }

  List<RestaurantListItem> _parseRestaurantList(dynamic json) {
    if (json is List) {
      return json.map((e) => RestaurantListItem.fromJson(e)).toList();
    }
    if (json is Map<String, dynamic>) {
      for (final key in ['results', 'restaurants', 'recommendations']) {
        if (json[key] is List) {
          return (json[key] as List)
              .map((e) => RestaurantListItem.fromJson(e))
              .toList();
        }
      }
      if (json['id'] != null) return [RestaurantListItem.fromJson(json)];
    }
    return [];
  }

  List<ReorderItem> _parseReorderList(dynamic json) {
    if (json is List) {
      return json.map((e) => ReorderItem.fromJson(e)).toList();
    }
    if (json is Map<String, dynamic> && json['reorder_suggestions'] is List) {
      return (json['reorder_suggestions'] as List)
          .map((e) => ReorderItem.fromJson(e))
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
  // ENDPOINTS
  // ============================================================

  /// Main home data: banners, categories, featured restaurants
  Future<HomeData> getHomeData({double? lat, double? lng}) async {
    final json = await _get(
      Environment.homeEndpoint,
      queryParams: _locationParams(lat, lng),
    );
    return HomeData.fromJson(json);
  }

  /// Nearby restaurants (needs lat/lng)
  Future<List<RestaurantListItem>?> getNearbyRestaurants({
    required double lat,
    required double lng,
  }) async {
    try {
      final json = await _get(
        Environment.nearbyRestaurantsEndpoint,
        queryParams: {'lat': '$lat', 'lng': '$lng'},
      );
      return _parseRestaurantList(json);
    } catch (e) {
      log('Error fetching nearby: $e');
      return null;
    }
  }

  /// Recommended restaurants (auth required)
  Future<List<RestaurantListItem>?> getRecommendedRestaurants({
    double? lat,
    double? lng,
  }) async {
    if (!await isAuthenticated()) return null;
    try {
      final json = await _get(
        Environment.recommendedRestaurantsEndpoint,
        queryParams: _locationParams(lat, lng),
        requiresAuth: true,
      );
      return _parseRestaurantList(json);
    } catch (e) {
      log('Error fetching recommended: $e');
      return null;
    }
  }

  /// Reorder suggestions (auth required)
  Future<List<ReorderItem>?> getReorderSuggestions() async {
    if (!await isAuthenticated()) return null;

    final uri = Uri.parse(Environment.reorderSuggestionsEndpoint);
    final headers = await _getHeaders(requiresAuth: true);

    try {
      final response = await http.get(uri, headers: headers);
      log('GET reorder → ${response.statusCode}: ${response.body}');

      if ((response.headers['content-type'] ?? '').contains('text/html') ||
          response.body.trim().startsWith('<')) {
        return null;
      }
      if (response.statusCode == 200) {
        return _parseReorderList(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      log('Error fetching reorder suggestions: $e');
      return null;
    }
  }
}

final homeServices = HomeServices();
