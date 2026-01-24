// lib/data/local_secure/secure_storage.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  final _storage = const FlutterSecureStorage();

  // Token keys
  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUserId = 'user_id';
  static const String _keyPhone = 'phone';
  static const String _keyFirstName = 'first_name';
  static const String _keyLastName = 'last_name';
  static const String _keyIsVerified = 'is_verified';
  static const String _keyLocale = 'app_locale';

  // Save access token
  Future<void> persistenToken(String token) async {
    await _storage.write(key: _keyAccessToken, value: token);
  }

  // Save refresh token
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _keyRefreshToken, value: token);
  }

  // Get access token
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _keyAccessToken);
  }

  // Get refresh token
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _keyRefreshToken);
  }

  // Save complete user data
  Future<void> saveUserData({
    required String accessToken,
    required String refreshToken,
    required String phone,
    required String firstName,
    required String lastName,
    required String userId,
    required bool isVerified,
  }) async {
    await _storage.write(key: _keyAccessToken, value: accessToken);
    await _storage.write(key: _keyRefreshToken, value: refreshToken);
    await _storage.write(key: _keyPhone, value: phone);
    await _storage.write(key: _keyFirstName, value: firstName);
    await _storage.write(key: _keyLastName, value: lastName);
    await _storage.write(key: _keyUserId, value: userId);
    await _storage.write(key: _keyIsVerified, value: isVerified.toString());
  }

  // Get user data
  Future<Map<String, String>> getUserData() async {
    final accessToken = await _storage.read(key: _keyAccessToken) ?? '';
    final refreshToken = await _storage.read(key: _keyRefreshToken) ?? '';
    final phone = await _storage.read(key: _keyPhone) ?? '';
    final firstName = await _storage.read(key: _keyFirstName) ?? '';
    final lastName = await _storage.read(key: _keyLastName) ?? '';
    final userId = await _storage.read(key: _keyUserId) ?? '';
    final isVerified = await _storage.read(key: _keyIsVerified) ?? 'false';

    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'phone': phone,
      'firstName': firstName,
      'lastName': lastName,
      'userId': userId,
      'isVerified': isVerified,
    };
  }

  // Check if user is logged in (only checks access token)
  Future<bool> isLoggedInAndVerified() async {
    final accessToken = await _storage.read(key: _keyAccessToken);
    return accessToken != null && accessToken.isNotEmpty;
  }

  // Clear all auth data (but keep locale preference)
  Future<void> clearAuthData() async {
    await _storage.delete(key: _keyAccessToken);
    await _storage.delete(key: _keyRefreshToken);
    await _storage.delete(key: _keyPhone);
    await _storage.delete(key: _keyFirstName);
    await _storage.delete(key: _keyLastName);
    await _storage.delete(key: _keyUserId);
    await _storage.delete(key: _keyIsVerified);
  }

  // Clear all storage
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  // Additional helper methods
  Future<void> persistenName(String name) async {
    await _storage.write(key: 'user_name', value: name);
  }

  Future<String?> getName() async {
    return await _storage.read(key: 'user_name');
  }

  Future<void> updateUserData({
    String? firstName,
    String? lastName,
    String? phone,
  }) async {
    if (firstName != null) {
      await _storage.write(key: _keyFirstName, value: firstName);
    }
    if (lastName != null) {
      await _storage.write(key: _keyLastName, value: lastName);
    }
    if (phone != null) {
      await _storage.write(key: _keyPhone, value: phone);
    }
  }

  // ============================================
  // Locale Methods
  // ============================================

  /// Save locale preference
  Future<void> saveLocale(String languageCode) async {
    await _storage.write(key: _keyLocale, value: languageCode);
  }

  /// Get saved locale preference
  Future<String?> getLocale() async {
    return await _storage.read(key: _keyLocale);
  }

  /// Clear locale preference
  Future<void> clearLocale() async {
    await _storage.delete(key: _keyLocale);
  }
}

final secureStorage = SecureStorage();
