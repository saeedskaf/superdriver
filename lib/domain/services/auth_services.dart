import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:superdriver/data/env/environment.dart';

class AuthServices {
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
    return 'حدث خطأ غير متوقع';
  }

  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String phone,
    required String password,
    required String confirmPassword,
  }) async {
    final uri = Uri.parse(Environment.registerEndpoint);
    final formattedPhone = _formatPhoneNumber(phone);

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        "first_name": firstName,
        "last_name": lastName,
        "phone_number": formattedPhone,
        "password": password,
        "confirm_password": confirmPassword,
      }),
    );

    final responseBody = jsonDecode(response.body);
    print(responseBody);

    if (response.statusCode == 201 && responseBody['success'] == true) {
      return responseBody;
    } else {
      throw Exception(_extractErrorMessage(responseBody));
    }
  }

  // LOGIN - Just return response, don't save tokens
  Future<Map<String, dynamic>> login(String phone, String password) async {
    final uri = Uri.parse(Environment.loginEndpoint);
    final formattedPhone = _formatPhoneNumber(phone);

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({"phone_number": formattedPhone, "password": password}),
    );

    final responseBody = jsonDecode(response.body);
    print(responseBody);

    if (response.statusCode == 200 && responseBody['success'] == true) {
      return responseBody;
    } else {
      throw Exception(_extractErrorMessage(responseBody));
    }
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String otpCode,
    required String otpType,
  }) async {
    final uri = Uri.parse(Environment.verifyOtpEndpoint);
    final formattedPhone = _formatPhoneNumber(phone);

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        "phone_number": formattedPhone,
        "otp_code": otpCode,
        "otp_type": otpType,
      }),
    );

    final responseBody = jsonDecode(response.body);
    print(responseBody);

    if (response.statusCode == 200 && responseBody['success'] == true) {
      return responseBody;
    } else {
      throw Exception(_extractErrorMessage(responseBody));
    }
  }

  Future<void> resendOtp({
    required String phone,
    required String otpType,
  }) async {
    final uri = Uri.parse(Environment.resendOtpEndpoint);
    final formattedPhone = _formatPhoneNumber(phone);

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({"phone_number": formattedPhone, "otp_type": otpType}),
    );

    final responseBody = jsonDecode(response.body);
    print(responseBody);

    if (response.statusCode == 200 && responseBody['success'] == true) {
      return;
    } else {
      throw Exception(_extractErrorMessage(responseBody));
    }
  }

  Future<void> forgotPassword({required String phone}) async {
    final uri = Uri.parse(Environment.forgotPasswordEndpoint);
    final formattedPhone = _formatPhoneNumber(phone);

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({"phone_number": formattedPhone}),
    );

    final responseBody = jsonDecode(response.body);
    print(responseBody);

    if (response.statusCode == 200 && responseBody['success'] == true) {
      return;
    } else {
      throw Exception(_extractErrorMessage(responseBody));
    }
  }

  Future<void> resetPassword({
    required String phone,
    required String otpCode,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final uri = Uri.parse(Environment.resetPasswordEndpoint);
    final formattedPhone = _formatPhoneNumber(phone);

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        "phone_number": formattedPhone,
        "otp_code": otpCode,
        "new_password": newPassword,
        "confirm_password": confirmPassword,
      }),
    );

    final responseBody = jsonDecode(response.body);
    print(responseBody);

    if (response.statusCode == 200 && responseBody['success'] == true) {
      return;
    } else {
      throw Exception(_extractErrorMessage(responseBody));
    }
  }
}

final authServices = AuthServices();
