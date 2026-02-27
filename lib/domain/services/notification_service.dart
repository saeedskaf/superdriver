// lib/domain/services/notification_service.dart
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:superdriver/data/env/environment.dart';
import 'package:superdriver/data/local_secure/secure_storage.dart';
import 'package:superdriver/domain/models/notification_model.dart';

class NotificationApiService {
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

  /// GET /api/notifications/ — List all notifications
  Future<List<NotificationItem>> fetchNotifications() async {
    final uri = Uri.parse(Environment.notificationsEndpoint);
    final headers = await _getAuthHeaders();
    final response = await http.get(uri, headers: headers);

    log('Notifications list status: ${response.statusCode}');
    log('Notifications list response: ${response.body}');

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body is List) {
        return body.map((e) => NotificationItem.fromJson(e)).toList();
      }
      if (body is Map<String, dynamic> && body['results'] is List) {
        return (body['results'] as List)
            .map((e) => NotificationItem.fromJson(e))
            .toList();
      }
      return [];
    } else {
      throw Exception(_extractErrorMessage(jsonDecode(response.body)));
    }
  }

  /// GET /api/notifications/{id}/ — Notification detail
  Future<NotificationDetail> fetchNotificationDetail(int id) async {
    final uri = Uri.parse(Environment.notificationDetailEndpoint(id));
    final headers = await _getAuthHeaders();
    final response = await http.get(uri, headers: headers);

    log('Notification detail: ${response.statusCode}');

    if (response.statusCode == 200) {
      return NotificationDetail.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(_extractErrorMessage(jsonDecode(response.body)));
    }
  }

  /// POST /api/notifications/{id}/read/ — Mark one as read
  Future<void> markAsRead(int id) async {
    final uri = Uri.parse(Environment.notificationReadEndpoint(id));
    final headers = await _getAuthHeaders();
    final response = await http.post(uri, headers: headers);

    log('Mark notification read: ${response.statusCode}');

    if (response.statusCode != 200) {
      throw Exception('Failed to mark notification as read');
    }
  }

  /// POST /api/notifications/read-all/ — Mark all as read
  Future<void> markAllAsRead() async {
    final uri = Uri.parse(Environment.notificationsReadAllEndpoint);
    final headers = await _getAuthHeaders();
    final response = await http.post(uri, headers: headers);

    log('Mark all read: ${response.statusCode}');

    if (response.statusCode != 200) {
      throw Exception('Failed to mark all as read');
    }
  }

  /// GET /api/notifications/unread-count/ — Unread badge count
  Future<int> fetchUnreadCount() async {
    final uri = Uri.parse(Environment.notificationsUnreadCountEndpoint);
    final headers = await _getAuthHeaders();
    final response = await http.get(uri, headers: headers);

    log('Unread count: ${response.statusCode}');

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body['count'] ?? 0;
    } else {
      throw Exception('Failed to get unread count');
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

    final response = await http.post(uri, headers: headers, body: body);

    log('Register device: ${response.statusCode}');

    if (response.statusCode != 200 && response.statusCode != 201) {
      log('Register device failed: ${response.body}');
    }
  }

  /// POST /api/notifications/devices/unregister/ — Unregister FCM token
  Future<void> unregisterDevice({required String token}) async {
    final uri = Uri.parse(Environment.unregisterDeviceEndpoint);
    final headers = await _getAuthHeaders();
    final body = jsonEncode({'token': token});

    final response = await http.post(uri, headers: headers, body: body);

    log('Unregister device: ${response.statusCode}');

    if (response.statusCode != 200) {
      log('Unregister device failed: ${response.body}');
    }
  }
}

final notificationApiService = NotificationApiService();
