import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:superdriver/data/env/environment.dart';
import 'package:superdriver/data/local_secure/secure_storage.dart';

class AuthServices {
  static const Duration _timeout = Duration(seconds: 30);

  String _formatPhoneNumber(String phone) {
    String cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.startsWith('963')) {
      cleaned = cleaned.substring(3);
    }
    if (!cleaned.startsWith('0')) {
      cleaned = '0$cleaned';
    }
    return cleaned;
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json; charset=UTF-8',
  };

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
    return responseBody['error']?.toString() ?? 'Unexpected error occurred';
  }

  Future<Map<String, dynamic>> _postRequest({
    required String url,
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await http
          .post(Uri.parse(url), headers: _headers, body: jsonEncode(body))
          .timeout(_timeout);

      final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
      debugPrint('[$url] ${response.statusCode}: $responseBody');

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          responseBody['success'] == true) {
        return responseBody;
      } else {
        throw Exception(_extractErrorMessage(responseBody));
      }
    } on SocketException {
      throw Exception('No internet connection');
    } on http.ClientException {
      throw Exception('Connection failed');
    } on FormatException {
      throw Exception('Invalid server response');
    }
  }

  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String phone,
    required String password,
    required String confirmPassword,
  }) async {
    return _postRequest(
      url: Environment.registerEndpoint,
      body: {
        'first_name': firstName,
        'last_name': lastName,
        'phone_number': _formatPhoneNumber(phone),
        'password': password,
        'confirm_password': confirmPassword,
      },
    );
  }

  Future<Map<String, dynamic>> login(String phone, String password) async {
    return _postRequest(
      url: Environment.loginEndpoint,
      body: {'phone_number': _formatPhoneNumber(phone), 'password': password},
    );
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String otpCode,
    required String otpType,
  }) async {
    return _postRequest(
      url: Environment.verifyOtpEndpoint,
      body: {
        'phone_number': _formatPhoneNumber(phone),
        'otp_code': otpCode,
        'otp_type': otpType,
      },
    );
  }

  Future<void> resendOtp({
    required String phone,
    required String otpType,
  }) async {
    await _postRequest(
      url: Environment.resendOtpEndpoint,
      body: {'phone_number': _formatPhoneNumber(phone), 'otp_type': otpType},
    );
  }

  Future<void> forgotPassword({required String phone}) async {
    await _postRequest(
      url: Environment.forgotPasswordEndpoint,
      body: {'phone_number': _formatPhoneNumber(phone)},
    );
  }

  Future<void> resetPassword({
    required String phone,
    required String otpCode,
    required String newPassword,
    required String confirmPassword,
  }) async {
    await _postRequest(
      url: Environment.resetPasswordEndpoint,
      body: {
        'phone_number': _formatPhoneNumber(phone),
        'otp_code': otpCode,
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      },
    );
  }

  /// DELETE account — POST /api/accounts/delete-account/
  /// Requires Bearer token + password confirmation.
  Future<void> deleteAccount({required String password, String? reason}) async {
    try {
      final token = await secureStorage.getAccessToken();
      debugPrint('deleteAccount URL: ${Environment.deleteAccountEndpoint}');

      final body = <String, dynamic>{'password': password};
      if (reason != null && reason.trim().isNotEmpty) {
        body['reason'] = reason.trim();
      }

      final response = await http
          .post(
            Uri.parse(Environment.deleteAccountEndpoint),
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(body),
          )
          .timeout(_timeout);

      final decoded = jsonDecode(response.body);
      debugPrint('deleteAccount ${response.statusCode}: $decoded');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return;
      }

      if (decoded is Map<String, dynamic>) {
        for (final value in decoded.values) {
          if (value is List && value.isNotEmpty) {
            throw Exception(value[0].toString());
          }
        }
        throw Exception(_extractErrorMessage(decoded));
      }

      throw Exception('Unexpected error');
    } on SocketException {
      throw Exception('No internet connection');
    } on http.ClientException {
      throw Exception('Connection failed');
    } on FormatException catch (e) {
      debugPrint('deleteAccount FormatException: $e');
      throw Exception('Invalid server response');
    }
  }
}

final authServices = AuthServices();
