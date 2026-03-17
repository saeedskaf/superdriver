// lib/data/services/notification_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:superdriver/data/env/environment.dart';
import 'package:superdriver/data/local_secure/secure_storage.dart';
import 'package:superdriver/domain/models/notification_model.dart';

class NotificationService {
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await secureStorage.getAccessToken();
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  String _extractErrorMessage(dynamic responseBody) {
    if (responseBody is Map<String, dynamic>) {
      for (var value in responseBody.values) {
        if (value is List && value.isNotEmpty) return value[0].toString();
        if (value is String) return value;
      }
    }
    return 'Unexpected error';
  }

  String _extractErrorMessageFromBody(String responseBody) {
    try {
      return _extractErrorMessage(jsonDecode(responseBody));
    } catch (_) {
      final text = responseBody.trim();
      return text.isEmpty ? 'Unexpected error' : text;
    }
  }

  /// Default page size for paginated requests
  static const int _pageSize = 20;

  /// GET /api/notifications/ — List notifications (paginated)
  ///
  /// [page] starts from 1. Returns a [NotificationPage] with the items
  /// and whether more pages exist.
  Future<NotificationPage> fetchNotifications({int page = 1}) async {
    final uri = Uri.parse(Environment.notificationsEndpoint).replace(
      queryParameters: {
        'page': '$page',
        'page_size': '$_pageSize',
      },
    );
    final headers = await _getAuthHeaders();
    final response = await http
        .get(uri, headers: headers)
        .timeout(const Duration(seconds: 30));

    if (kDebugMode) {
      log('Notifications list status: ${response.statusCode}');
    }

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      // Paginated response: { results: [...], next: "url"|null, ... }
      if (body is Map<String, dynamic> && body['results'] is List) {
        final items = (body['results'] as List)
            .map((e) => NotificationItem.fromJson(e))
            .toList();
        final hasMore = body['next'] != null;
        return NotificationPage(items: items, hasMore: hasMore);
      }

      // Non-paginated response: plain list (no more pages)
      if (body is List) {
        final items =
            body.map((e) => NotificationItem.fromJson(e)).toList();
        return NotificationPage(items: items, hasMore: false);
      }

      return const NotificationPage(items: [], hasMore: false);
    } else {
      throw Exception(_extractErrorMessageFromBody(response.body));
    }
  }

  /// GET /api/notifications/{id}/ — Notification detail
  Future<NotificationDetail> fetchNotificationDetail(int id) async {
    final uri = Uri.parse(Environment.notificationDetailEndpoint(id));
    final headers = await _getAuthHeaders();
    final response = await http
        .get(uri, headers: headers)
        .timeout(const Duration(seconds: 30));

    if (kDebugMode) log('Notification detail: ${response.statusCode}');

    if (response.statusCode == 200) {
      return NotificationDetail.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(_extractErrorMessageFromBody(response.body));
    }
  }

  /// POST /api/notifications/{id}/read/ — Mark one as read
  Future<void> markAsRead(int id) async {
    final uri = Uri.parse(Environment.notificationReadEndpoint(id));
    final headers = await _getAuthHeaders();
    final response = await http
        .post(uri, headers: headers)
        .timeout(const Duration(seconds: 30));

    if (kDebugMode) log('Mark notification read: ${response.statusCode}');

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_extractErrorMessageFromBody(response.body));
    }
  }

  /// POST /api/notifications/read-all/ — Mark all as read
  Future<void> markAllAsRead() async {
    final uri = Uri.parse(Environment.notificationsReadAllEndpoint);
    final headers = await _getAuthHeaders();
    final response = await http
        .post(uri, headers: headers)
        .timeout(const Duration(seconds: 30));

    if (kDebugMode) log('Mark all read: ${response.statusCode}');

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_extractErrorMessageFromBody(response.body));
    }
  }

  /// GET /api/notifications/unread-count/ — Unread badge count
  Future<int> fetchUnreadCount() async {
    final uri = Uri.parse(Environment.notificationsUnreadCountEndpoint);
    final headers = await _getAuthHeaders();
    final response = await http
        .get(uri, headers: headers)
        .timeout(const Duration(seconds: 30));

    if (kDebugMode) log('Unread count: ${response.statusCode}');

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final count = body['count'];
      if (count is int) return count;
      return int.tryParse(count?.toString() ?? '') ?? 0;
    } else {
      throw Exception(_extractErrorMessageFromBody(response.body));
    }
  }

  /// POST /api/notifications/devices/register/ — Register FCM token
  Future<void> registerDevice({
    required String token,
    required String deviceType,
    String? deviceName,
    String? language,
  }) async {
    final uri = Uri.parse(Environment.registerDeviceEndpoint);
    final headers = await _getAuthHeaders();
    final body = jsonEncode({
      'token': token,
      'device_type': deviceType,
      if (deviceName != null) 'device_name': deviceName,
      'language': language ?? 'ar',
    });

    final response = await http
        .post(uri, headers: headers, body: body)
        .timeout(const Duration(seconds: 30));

    if (kDebugMode) log('Register device: ${response.statusCode}');

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = _extractErrorMessageFromBody(response.body);
      if (kDebugMode) log('Register device failed: $message');
      throw Exception(message);
    }
  }

  /// POST /api/notifications/devices/unregister/ — Unregister FCM token
  Future<void> unregisterDevice({required String token}) async {
    final uri = Uri.parse(Environment.unregisterDeviceEndpoint);
    final headers = await _getAuthHeaders();
    final body = jsonEncode({'token': token});

    final response = await http
        .post(uri, headers: headers, body: body)
        .timeout(const Duration(seconds: 30));

    if (kDebugMode) log('Unregister device: ${response.statusCode}');

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = _extractErrorMessageFromBody(response.body);
      if (kDebugMode) log('Unregister device failed: $message');
      throw Exception(message);
    }
  }
}

final notificationService = NotificationService();
