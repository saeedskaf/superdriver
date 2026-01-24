import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:superdriver/data/env/environment.dart';
import 'package:superdriver/data/local_secure/secure_storage.dart';
import 'package:superdriver/domain/models/home_model.dart';

class HomeServices {
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

  /// Get home page data (banners, categories, restaurants, products)
  Future<HomeData> getHomeData() async {
    final uri = Uri.parse(Environment.homeEndpoint);
    final headers = await _getHeaders();

    final response = await http.get(uri, headers: headers);
    final responseBody = jsonDecode(response.body);
    print('Get Home Response: $responseBody');

    if (response.statusCode == 200) {
      return HomeData.fromJson(responseBody);
    } else {
      throw Exception(_extractErrorMessage(responseBody));
    }
  }

  /// Get nearby restaurants
  Future<List<Restaurant>> getNearbyRestaurants({
    required double lat,
    required double lng,
  }) async {
    final uri = Uri.parse(Environment.nearbyRestaurantsEndpoint).replace(
      queryParameters: {
        'lat': lat.toString(),
        'lng': lng.toString(),
      },
    );
    final headers = await _getHeaders(requiresAuth: true);

    final response = await http.get(uri, headers: headers);
    final responseBody = jsonDecode(response.body);
    print('Get Nearby Restaurants Response: $responseBody');

    if (response.statusCode == 200) {
      if (responseBody is List) {
        return responseBody.map((e) => Restaurant.fromJson(e)).toList();
      } else if (responseBody['restaurants'] != null) {
        return (responseBody['restaurants'] as List)
            .map((e) => Restaurant.fromJson(e))
            .toList();
      }
      return [];
    } else {
      throw Exception(_extractErrorMessage(responseBody));
    }
  }

  /// Get recommended restaurants (personalized)
  Future<List<Restaurant>> getRecommendedRestaurants() async {
    final uri = Uri.parse(Environment.recommendedRestaurantsEndpoint);
    final headers = await _getHeaders(requiresAuth: true);

    final response = await http.get(uri, headers: headers);
    final responseBody = jsonDecode(response.body);
    print('Get Recommended Restaurants Response: $responseBody');

    if (response.statusCode == 200) {
      return RecommendedData.fromJson(responseBody).recommendations;
    } else {
      throw Exception(_extractErrorMessage(responseBody));
    }
  }

  /// Get reorder suggestions
  Future<List<dynamic>> getReorderSuggestions() async {
    final uri = Uri.parse(Environment.reorderSuggestionsEndpoint);
    final headers = await _getHeaders(requiresAuth: true);

    final response = await http.get(uri, headers: headers);
    final responseBody = jsonDecode(response.body);
    print('Get Reorder Suggestions Response: $responseBody');

    if (response.statusCode == 200) {
      return responseBody['reorder_suggestions'] ?? [];
    } else {
      throw Exception(_extractErrorMessage(responseBody));
    }
  }

  /// Get search suggestions
  Future<List<String>> getSearchSuggestions() async {
    final uri = Uri.parse(Environment.searchSuggestionsEndpoint);
    final headers = await _getHeaders(requiresAuth: true);

    final response = await http.get(uri, headers: headers);
    final responseBody = jsonDecode(response.body);
    print('Get Search Suggestions Response: $responseBody');

    if (response.statusCode == 200) {
      return SuggestionsData.fromJson(responseBody).suggestions;
    } else {
      throw Exception(_extractErrorMessage(responseBody));
    }
  }

  /// Get trending items
  Future<TrendingData> getTrending() async {
    final uri = Uri.parse(Environment.trendingEndpoint);
    final headers = await _getHeaders(requiresAuth: true);

    final response = await http.get(uri, headers: headers);
    final responseBody = jsonDecode(response.body);
    print('Get Trending Response: $responseBody');

    if (response.statusCode == 200) {
      return TrendingData.fromJson(responseBody);
    } else {
      throw Exception(_extractErrorMessage(responseBody));
    }
  }
}

final homeServices = HomeServices();
