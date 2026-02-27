import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:superdriver/data/env/environment.dart';
import 'package:superdriver/data/local_secure/secure_storage.dart';

class ProfileService {
  Future<Map<String, String>> _getAuthHeaders() async {
    final accessToken = await secureStorage.getAccessToken();
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      if (accessToken != null) 'Authorization': 'Bearer $accessToken',
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
    return 'Unexpected error';
  }

  /// GET /api/auth/profile/
  Future<Map<String, dynamic>> getProfile() async {
    final uri = Uri.parse(Environment.profileEndpoint);
    final headers = await _getAuthHeaders();

    final response = await http.get(uri, headers: headers);
    final responseBody = jsonDecode(response.body);
    log('GET Profile Response: $responseBody');

    if (response.statusCode == 200) {
      if (responseBody['user'] != null) {
        return Map<String, dynamic>.from(responseBody['user']);
      }
      return responseBody;
    } else if (response.statusCode == 401) {
      throw Exception('Session expired');
    } else {
      throw Exception(_extractErrorMessage(responseBody));
    }
  }

  /// PATCH /api/auth/profile/
  Future<Map<String, dynamic>> updateProfile({
    String? firstName,
    String? lastName,
  }) async {
    final uri = Uri.parse(Environment.profileEndpoint);
    final headers = await _getAuthHeaders();

    final Map<String, dynamic> body = {};
    if (firstName != null) body['first_name'] = firstName;
    if (lastName != null) body['last_name'] = lastName;

    final response = await http.patch(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );

    final responseBody = jsonDecode(response.body);
    log('PATCH Profile Response: $responseBody');

    if (response.statusCode == 200) {
      Map<String, dynamic> userData;
      if (responseBody['user'] != null) {
        userData = Map<String, dynamic>.from(responseBody['user']);
      } else {
        userData = responseBody;
      }

      await secureStorage.updateUserData(
        firstName: userData['first_name'],
        lastName: userData['last_name'],
      );
      return userData;
    } else if (response.statusCode == 401) {
      throw Exception('Session expired');
    } else {
      throw Exception(_extractErrorMessage(responseBody));
    }
  }

  /// POST /api/auth/change-password/
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final uri = Uri.parse(Environment.changePasswordEndpoint);
    final headers = await _getAuthHeaders();

    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode({
        'old_password': oldPassword,
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      }),
    );

    log('Change Password Response Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 401) {
      throw Exception('Session expired');
    } else {
      final responseBody = jsonDecode(response.body);
      throw Exception(_extractErrorMessage(responseBody));
    }
  }
}

final profileService = ProfileService();
