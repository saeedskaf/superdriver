import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:superdriver/data/env/environment.dart';
import 'package:superdriver/data/local_secure/secure_storage.dart';
import 'package:superdriver/domain/models/review_model.dart';

class ReviewServices {
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await secureStorage.getAccessToken();
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
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
    return '\u062d\u062f\u062b \u062e\u0637\u0623 \u063a\u064a\u0631 \u0645\u062a\u0648\u0642\u0639';
  }

  /// Create driver review
  /// API accepts: order (int), overall_rating (int 1-5), comment (string, optional)
  Future<DriverReview> createDriverReview(
    CreateDriverReviewRequest request,
  ) async {
    final uri = Uri.parse(Environment.createDriverReviewEndpoint);
    final headers = await _getAuthHeaders();
    log('$uri');
    log('${request.orderId}');

    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(request.toJson()),
    ).timeout(const Duration(seconds: 30));

    final responseBody = jsonDecode(response.body);
    log('Create Driver Review Response: $responseBody');

    if (response.statusCode == 201 || response.statusCode == 200) {
      return DriverReview.fromJson(responseBody);
    } else {
      throw Exception(_extractErrorMessage(responseBody));
    }
  }
}

final reviewServices = ReviewServices();
