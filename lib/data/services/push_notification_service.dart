// lib/data/services/push_notification_service.dart
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:superdriver/data/local_secure/secure_storage.dart';
import 'package:superdriver/domain/bloc/auth/auth_bloc.dart';
import 'package:superdriver/domain/bloc/orders/orders_bloc.dart';
import 'package:superdriver/data/services/notification_service.dart';
import 'package:superdriver/data/services/in_app_messaging_service.dart';
import 'package:superdriver/presentation/screens/main/chat/chat_conversation_screen.dart';
import 'package:superdriver/presentation/screens/main/chat/chat_screen.dart';
import 'package:superdriver/presentation/screens/main/order_details_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Debug logging helper
// ─────────────────────────────────────────────────────────────────────────────

void _debugLogMessage(String label, RemoteMessage message,
    {Map<String, String>? extra}) {
  if (!kDebugMode) return;

  debugPrint('');
  debugPrint('╔═══════════════════════════════════════════════════════╗');
  debugPrint('║  $label');
  debugPrint('╠═══════════════════════════════════════════════════════╣');
  debugPrint('║ MessageID   : ${message.messageId}');
  debugPrint('║ SentTime    : ${message.sentTime}');
  debugPrint('║ From        : ${message.from}');
  debugPrint('║ Category    : ${message.category}');
  debugPrint('║ CollapseKey  : ${message.collapseKey}');
  debugPrint('║ ContentAvail: ${message.contentAvailable}');
  debugPrint('║ MutableCont : ${message.mutableContent}');
  debugPrint('║ ThreadID    : ${message.threadId}');
  debugPrint('╠═══════════ NOTIFICATION FIELD ═══════════════════════╣');
  debugPrint('║ Title       : ${message.notification?.title}');
  debugPrint('║ TitleLocKey : ${message.notification?.titleLocKey}');
  debugPrint('║ TitleLocArgs: ${message.notification?.titleLocArgs}');
  debugPrint('║ Body        : ${message.notification?.body}');
  debugPrint('║ BodyLocKey  : ${message.notification?.bodyLocKey}');
  debugPrint('║ BodyLocArgs : ${message.notification?.bodyLocArgs}');
  debugPrint('║ Image (and) : ${message.notification?.android?.imageUrl}');
  debugPrint('║ Image (ios) : ${message.notification?.apple?.imageUrl}');
  debugPrint('║ Sound       : ${message.notification?.android?.sound}');
  debugPrint('╠═══════════ DATA FIELD ══════════════════════════════╣');
  message.data.forEach((k, v) => debugPrint('║ $k : $v'));
  if (message.data.isEmpty) debugPrint('║ (empty)');
  if (extra != null) {
    debugPrint('╠═══════════ APP STATE ═════════════════════════════════╣');
    extra.forEach((k, v) => debugPrint('║ $k : $v'));
  }
  debugPrint('╚═══════════════════════════════════════════════════════╝');
  debugPrint('');
}

// ─────────────────────────────────────────────────────────────────────────────
// Background handler (must be top-level for FCM)
// ─────────────────────────────────────────────────────────────────────────────

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  _debugLogMessage('PUSH NOTIFICATION — BACKGROUND', message);
}

// ─────────────────────────────────────────────────────────────────────────────
// Service
// ─────────────────────────────────────────────────────────────────────────────

class PushNotificationService {
  static final PushNotificationService _instance =
      PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  VoidCallback? onForegroundMessage;
  void Function(Map<String, dynamic> data)? onNotificationTap;

  bool _initialized = false;
  final Set<String> _recentForegroundMessageKeys = <String>{};
  final List<String> _foregroundMessageOrder = <String>[];

  static const _channelId = 'superdriver_notifications';
  static const _maxRecentForegroundKeys = 30;

  static const _androidChannel = AndroidNotificationChannel(
    _channelId,
    'SuperDriver Notifications',
    description: 'Order updates and promotions',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
  );

  // ───────────────────── Locale ─────────────────────

  String _locale = 'ar';

  void updateLocale(String languageCode) {
    final changed = _locale != languageCode;
    _locale = languageCode;
    if (kDebugMode && changed) {
      debugPrint('Push: Locale changed to $_locale');
    }
  }

  // ───────────────────── Initialization ─────────────────────

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      await _createAndroidChannel();
      await _initLocalNotifications();
      await _requestPermission();

      // Foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Notification tap — app was in background
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      // Notification tap — app was terminated
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        Future.delayed(const Duration(milliseconds: 1500), () {
          _handleNotificationTap(initialMessage);
        });
      }

      // Token refresh
      _messaging.onTokenRefresh.listen(_onTokenRefresh);

      // iOS: DISABLE system alerts — we use flutter_local_notifications.
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: false,
        badge: true,
        sound: false,
      );

      _initialized = true;
      await _printDebugInfo();
      log('PushNotificationService initialized');
    } catch (e, st) {
      log('PushNotificationService init error: $e\n$st');
    }
  }

  // ───────────────────── Device token ─────────────────────

  Future<void> registerDeviceToken() async {
    try {
      final enabled = await _areNotificationsEnabledSafe();
      if (!enabled) {
        log('Push: Skipping registration (disabled by user)');
        return;
      }

      final authToken = await secureStorage.getAccessToken();
      if (authToken == null || authToken.isEmpty) {
        log('Push: Skipping registration (guest mode)');
        return;
      }

      String? fcmToken;
      for (int attempt = 1; attempt <= 3; attempt++) {
        fcmToken = await _messaging.getToken();
        if (fcmToken != null) break;
        log('Push: FCM token null, retrying ($attempt/3)...');
        await Future.delayed(const Duration(seconds: 2));
      }

      if (fcmToken == null) {
        log('Push: FCM token is null after retries');
        return;
      }

      final deviceType = Platform.isIOS ? 'ios' : 'android';
      final deviceName = Platform.isIOS ? 'iPhone' : 'Android';

      await notificationService.registerDevice(
        token: fcmToken,
        deviceType: deviceType,
        deviceName: deviceName,
        language: _locale,
      );

      log(
        'Push: Device registered (lang=$_locale): ${fcmToken.substring(0, 20)}...',
      );
    } catch (e) {
      log('Push: Register device error: $e');
    }
  }

  Future<void> unregisterDeviceToken() async {
    try {
      final authToken = await secureStorage.getAccessToken();
      if (authToken == null || authToken.isEmpty) return;

      final fcmToken = await _messaging.getToken();
      if (fcmToken == null) return;

      await notificationService.unregisterDevice(token: fcmToken);
      log('Push: Device unregistered');
    } catch (e) {
      log('Push: Unregister error: $e');
    }
  }

  // ───────────────────── Permission ─────────────────────

  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    final status = settings.authorizationStatus;
    log('Push: Permission status: $status');

    if (status == AuthorizationStatus.denied) {
      log('WARNING: Notification permission DENIED by user');
    }
  }

  // ───────────────────── Channel & local notifications ─────────────────────

  Future<void> _createAndroidChannel() async {
    if (!Platform.isAndroid) return;

    final plugin = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (plugin != null) {
      await plugin.createNotificationChannel(_androidChannel);
    }
  }

  Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _localNotifications.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );
  }

  // ───────────────────── Foreground handling ─────────────────────

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    _debugLogMessage(
      'PUSH NOTIFICATION — FOREGROUND',
      message,
      extra: {'Current locale': _locale},
    );

    if (_isDuplicateForegroundMessage(message)) return;

    final notificationsEnabled = await _areNotificationsEnabledSafe();
    if (!notificationsEnabled) {
      if (kDebugMode) {
        debugPrint('Push: foreground message skipped (notifications disabled)');
      }
      return;
    }

    final shown = await _showLocalNotification(message);

    // Only bump unread count if a notification was actually displayed
    if (shown) {
      onForegroundMessage?.call();
    }
  }

  Future<bool> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final data = message.data;
    final isAr = _locale == 'ar';

    // Backend sends: title (Arabic), title_en (English), body (Arabic), body_en (English)
    String title;
    String body;
    if (isAr) {
      title =
          _safeString(data['title']) ??
          _safeString(data['notification_title']) ??
          notification?.title ??
          '';
      body =
          _safeString(data['body']) ??
          _safeString(data['message']) ??
          _safeString(data['notification_body']) ??
          notification?.body ??
          '';
    } else {
      title =
          _safeString(data['title_en']) ??
          _safeString(data['title']) ??
          _safeString(data['notification_title']) ??
          notification?.title ??
          '';
      body =
          _safeString(data['body_en']) ??
          _safeString(data['body']) ??
          _safeString(data['message']) ??
          _safeString(data['notification_body']) ??
          notification?.body ??
          '';
    }

    title = title.trim();
    body = body.trim();
    if (title.isEmpty && body.isEmpty) {
      if (kDebugMode) {
        debugPrint('Push: foreground message skipped (empty visual payload)');
      }
      return false;
    }

    // Extract image URL from notification or data payload
    final imageUrl = _safeString(data['image']) ??
        _safeString(data['image_url']) ??
        _safeString(data['imageUrl']) ??
        notification?.android?.imageUrl ??
        notification?.apple?.imageUrl;

    if (kDebugMode) {
      debugPrint('╠═══════════ SHOWING NOTIFICATION ═══════════════════╣');
      debugPrint('║ isAr        : $isAr');
      debugPrint('║ data[title]   : ${data['title']}');
      debugPrint('║ data[title_en]: ${data['title_en']}');
      debugPrint('║ data[body]    : ${data['body']}');
      debugPrint('║ data[body_en] : ${data['body_en']}');
      debugPrint('║ imageUrl    : $imageUrl');
      debugPrint('║ FINAL Title : $title');
      debugPrint('║ FINAL Body  : $body');
      debugPrint('╚════════════════════════════════════════════════════╝');
    }

    final notificationId =
        message.messageId?.hashCode ??
        DateTime.now().millisecondsSinceEpoch % 2147483647;

    // Download image if available
    Uint8List? imageBytes;
    String? imagePath;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      try {
        final response = await http
            .get(Uri.parse(imageUrl))
            .timeout(const Duration(seconds: 10));
        if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
          imageBytes = response.bodyBytes;

          // Save to temp file for iOS attachment
          if (Platform.isIOS) {
            final tempDir = Directory.systemTemp;
            final file = File(
              '${tempDir.path}/notif_${notificationId}_img.jpg',
            );
            await file.writeAsBytes(imageBytes);
            imagePath = file.path;
          }
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Push: Failed to download notification image: $e');
        }
      }
    }

    final androidDetails = AndroidNotificationDetails(
      _androidChannel.id,
      _androidChannel.name,
      channelDescription: _androidChannel.description,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
      styleInformation: imageBytes != null
          ? BigPictureStyleInformation(
              ByteArrayAndroidBitmap(imageBytes),
              hideExpandedLargeIcon: true,
            )
          : null,
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      attachments: imagePath != null
          ? [DarwinNotificationAttachment(imagePath)]
          : null,
    );

    try {
      _localNotifications.show(
        notificationId,
        title,
        body,
        NotificationDetails(android: androidDetails, iOS: iosDetails),
        payload: jsonEncode(data),
      );
      return true;
    } catch (e) {
      log('Push: Failed to show local notification: $e');
      return false;
    }
  }

  // ───────────────────── Notification tap handling ─────────────────────

  void _handleNotificationTap(RemoteMessage message) {
    if (kDebugMode) {
      debugPrint('');
      debugPrint('╔═══════════════════════════════════════════════════════╗');
      debugPrint('║  NOTIFICATION TAPPED — FCM BG/TERMINATED              ║');
      debugPrint('╠═══════════════════════════════════════════════════════╣');
      debugPrint('║ MessageID   : ${message.messageId}');
      debugPrint('║ Title       : ${message.notification?.title}');
      debugPrint('║ Body        : ${message.notification?.body}');
      debugPrint('╠═══════════ DATA FIELD ══════════════════════════════╣');
      message.data.forEach((k, v) => debugPrint('║ $k : $v'));
      debugPrint('╚═══════════════════════════════════════════════════════╝');
      debugPrint('');
    }

    inAppMessagingService.triggerEvent('notification_opened');
    final data = Map<String, dynamic>.from(message.data);
    onNotificationTap?.call(data);
    _navigateFromData(data);
  }

  void _onLocalNotificationTap(NotificationResponse response) {
    if (kDebugMode) {
      debugPrint('');
      debugPrint('╔═══════════════════════════════════════════════════════╗');
      debugPrint('║  NOTIFICATION TAPPED — LOCAL FOREGROUND               ║');
      debugPrint('╠═══════════════════════════════════════════════════════╣');
      debugPrint('║ Payload     : ${response.payload}');
      debugPrint('║ ActionId    : ${response.actionId}');
      debugPrint('║ Input       : ${response.input}');
      debugPrint('║ Id          : ${response.id}');
      debugPrint('╚═══════════════════════════════════════════════════════╝');
      debugPrint('');
    }

    if (response.payload != null && response.payload!.isNotEmpty) {
      try {
        inAppMessagingService.triggerEvent('notification_opened');
        final data = Map<String, dynamic>.from(jsonDecode(response.payload!));
        onNotificationTap?.call(data);
        _navigateFromData(data);
      } catch (e) {
        log('Push: Failed to parse notification payload: $e');
      }
    }
  }

  // ───────────────────── Navigation ─────────────────────

  void _navigateFromData(Map<String, dynamic> data) {
    final notifType = _extractNotificationType(data);
    final refId = _parseIntFromKeys(data, const [
      'reference_id',
      'referenceId',
      'order_id',
      'orderId',
      'id',
    ]);
    final chatId = _firstNonEmptyString(data, const [
      'chatId',
      'chat_id',
      'conversation_id',
      'conversationId',
    ]);

    if (kDebugMode) {
      debugPrint('Push Navigate: type=$notifType, refId=$refId');
    }

    final navigator = navigatorKey.currentState;
    if (navigator == null) {
      if (kDebugMode) {
        debugPrint(
          'Push Navigate: navigatorKey.currentState is NULL, retrying...',
        );
      }
      _retryNavigation(data, attempts: 8);
      return;
    }

    if (!_isUserAuthenticated()) {
      if (kDebugMode) {
        debugPrint('Push Navigate: ignored (user is not authenticated)');
      }
      return;
    }

    switch (notifType) {
      case 'order':
        if (refId != null) {
          if (kDebugMode) {
            debugPrint(
              'Push Navigate: → OrderDetailsScreen(orderId: $refId)',
            );
          }
          navigator.push(
            MaterialPageRoute(
              builder: (_) => BlocProvider(
                create: (_) => OrdersBloc(),
                child: OrderDetailsScreen(orderId: refId),
              ),
            ),
          );
        }
        break;

      case 'chat':
        if (kDebugMode) {
          debugPrint('Push Navigate: → Chat flow');
        }
        navigator.push(
          MaterialPageRoute(
            builder: (_) => (chatId != null && chatId.isNotEmpty)
                ? ChatConversationScreen(conversationId: chatId)
                : const ChatScreen(),
          ),
        );
        break;

      default:
        if (kDebugMode) {
          debugPrint(
            'Push Navigate: Unknown type "$notifType" — no navigation',
          );
        }
        break;
    }
  }

  // ───────────────────── Payload helpers ─────────────────────

  String? _extractNotificationType(Map<String, dynamic> data) {
    final rawType = _firstNonEmptyString(data, const [
      'reference_type',
      'type',
      'notification_type',
      'event_type',
    ]);
    if (rawType == null) return null;

    final normalized = rawType.toLowerCase().trim();
    if (normalized == 'order' || normalized.startsWith('order_')) {
      return 'order';
    }
    if (normalized == 'chat' ||
        normalized.startsWith('chat_') ||
        normalized == 'message' ||
        normalized == 'conversation') {
      return 'chat';
    }
    return normalized;
  }

  int? _parseIntFromKeys(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value == null) continue;
      if (value is int) return value;
      final parsed = int.tryParse(value.toString().trim());
      if (parsed != null) return parsed;
    }
    return null;
  }

  String? _firstNonEmptyString(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = _safeString(data[key]);
      if (value != null) return value;
    }
    return null;
  }

  void _retryNavigation(Map<String, dynamic> data, {required int attempts}) {
    if (attempts <= 0) return;
    Future.delayed(const Duration(milliseconds: 300), () {
      final navigator = navigatorKey.currentState;
      if (navigator != null) {
        _navigateFromData(data);
        return;
      }
      _retryNavigation(data, attempts: attempts - 1);
    });
  }

  bool _isUserAuthenticated() {
    final context = navigatorKey.currentContext;
    if (context == null) return false;
    try {
      return context.read<AuthBloc>().state is AuthAuthenticated;
    } catch (_) {
      return false;
    }
  }

  // ───────────────────── Duplicate prevention ─────────────────────

  bool _isDuplicateForegroundMessage(RemoteMessage message) {
    final messageId = message.messageId;
    if (messageId == null || messageId.isEmpty) return false;

    if (_recentForegroundMessageKeys.contains(messageId)) {
      if (kDebugMode) {
        debugPrint('Push: duplicate foreground message skipped: $messageId');
      }
      return true;
    }

    _recentForegroundMessageKeys.add(messageId);
    _foregroundMessageOrder.add(messageId);
    if (_foregroundMessageOrder.length > _maxRecentForegroundKeys) {
      final removed = _foregroundMessageOrder.removeAt(0);
      _recentForegroundMessageKeys.remove(removed);
    }
    return false;
  }

  String? _safeString(dynamic value) {
    if (value == null) return null;
    final result = value.toString().trim();
    return result.isEmpty ? null : result;
  }

  // ───────────────────── Token refresh ─────────────────────

  void _onTokenRefresh(String newToken) {
    log('Push: Token refreshed');
    registerDeviceToken();
  }

  // ───────────────────── Enable / disable ─────────────────────

  Future<bool> _areNotificationsEnabledSafe() async {
    try {
      return await secureStorage.getPushNotificationsEnabled();
    } catch (_) {
      return true;
    }
  }

  Future<bool> areNotificationsEnabled() => _areNotificationsEnabledSafe();

  Future<void> disableNotifications() async {
    try {
      final fcmToken = await _messaging.getToken();
      if (fcmToken != null) {
        try {
          await notificationService.unregisterDevice(token: fcmToken);
        } catch (e) {
          log('Push: Failed to unregister: $e');
        }
      }
      await secureStorage.savePushNotificationsEnabled(false);
      log('Push: Notifications disabled');
    } catch (e) {
      log('Push: Disable error: $e');
    }
  }

  Future<void> enableNotifications() async {
    try {
      await secureStorage.savePushNotificationsEnabled(true);
      await registerDeviceToken();
      log('Push: Notifications enabled');
    } catch (e) {
      log('Push: Enable error: $e');
    }
  }

  // ───────────────────── Debug info ─────────────────────

  Future<void> _printDebugInfo() async {
    if (!kDebugMode) return;

    try {
      final token = await _messaging.getToken();
      debugPrint('════════════════════════════════════════');
      debugPrint('FCM TOKEN: ${token ?? 'NULL'}');

      if (Platform.isIOS) {
        final apnsToken = await _messaging.getAPNSToken();
        debugPrint(apnsToken == null
            ? 'APNs TOKEN: NULL — Push will NOT work on iOS!'
            : 'APNs TOKEN: Available');
      }
      debugPrint('════════════════════════════════════════');
    } catch (e) {
      debugPrint('FCM debug error: $e');
    }
  }

  Future<String?> getFcmToken() async {
    try {
      return await _messaging.getToken();
    } catch (_) {
      return null;
    }
  }
}

final pushNotificationService = PushNotificationService();
