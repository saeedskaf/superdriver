// lib/domain/services/push_notification_service.dart
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:superdriver/data/local_secure/secure_storage.dart';
import 'package:superdriver/domain/bloc/orders/orders_bloc.dart';
import 'package:superdriver/domain/services/notification_service.dart';
import 'package:superdriver/presentation/screens/main/order_details_screen.dart';

// ═══════════════════════════════════════════════════════════════
// BACKGROUND HANDLER — must be top-level
// ═══════════════════════════════════════════════════════════════

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('');
  debugPrint('╔═══════════════════════════════════════════════════════╗');
  debugPrint('║         PUSH NOTIFICATION — BACKGROUND               ║');
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
  message.data.forEach((k, v) {
    debugPrint('║ $k : $v');
  });
  if (message.data.isEmpty) debugPrint('║ (empty)');
  debugPrint('╚═══════════════════════════════════════════════════════╝');
  debugPrint('');
}

// ═══════════════════════════════════════════════════════════════
// PUSH NOTIFICATION SERVICE
// ═══════════════════════════════════════════════════════════════

class PushNotificationService {
  static final PushNotificationService _instance =
      PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// Assign to MaterialApp.navigatorKey
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  /// Called when a foreground FCM arrives → use to bump badge count.
  VoidCallback? onForegroundMessage;

  /// Optional external callback (kept for compatibility).
  /// Navigation is handled directly in _navigateFromData().
  void Function(Map<String, dynamic> data)? onNotificationTap;

  bool _initialized = false;

  static const _channelId = 'superdriver_notifications';

  static const _androidChannel = AndroidNotificationChannel(
    _channelId,
    'SuperDriver Notifications',
    description: 'Order updates and promotions',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
  );

  // ═══════════════════════════════════════════════════════════════
  // INITIALIZE
  // ═══════════════════════════════════════════════════════════════

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

  // ═══════════════════════════════════════════════════════════════
  // FCM TOKEN
  // ═══════════════════════════════════════════════════════════════

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

      await notificationApiService.registerDevice(
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

      await notificationApiService.unregisterDevice(token: fcmToken);
      log('Push: Device unregistered');
    } catch (e) {
      log('Push: Unregister error: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // PERMISSION
  // ═══════════════════════════════════════════════════════════════

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

  // ═══════════════════════════════════════════════════════════════
  // ANDROID CHANNEL
  // ═══════════════════════════════════════════════════════════════

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

  // ═══════════════════════════════════════════════════════════════
  // LOCAL NOTIFICATIONS INIT
  // ═══════════════════════════════════════════════════════════════

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

  // ═══════════════════════════════════════════════════════════════
  // FOREGROUND MESSAGE HANDLER
  // ═══════════════════════════════════════════════════════════════

  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('');
    debugPrint('╔═══════════════════════════════════════════════════════╗');
    debugPrint('║         PUSH NOTIFICATION — FOREGROUND                ║');
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
    message.data.forEach((k, v) {
      debugPrint('║ $k : $v');
    });
    if (message.data.isEmpty) debugPrint('║ (empty)');
    debugPrint('╠═══════════ APP STATE ═════════════════════════════════╣');
    debugPrint('║ Current locale: $_locale');
    debugPrint('╚═══════════════════════════════════════════════════════╝');
    debugPrint('');

    final notification = message.notification;
    if (notification != null) {
      _showLocalNotification(message);
    }

    onForegroundMessage?.call();
  }

  void _showLocalNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    final data = message.data;
    final isAr = _locale == 'ar';

    // Backend sends: title (Arabic), title_en (English), body (Arabic), body_en (English)
    String title;
    String body;
    if (isAr) {
      title = (data['title'] as String?) ?? notification.title ?? '';
      body = (data['body'] as String?) ?? notification.body ?? '';
    } else {
      title =
          (data['title_en'] as String?) ??
          (data['title'] as String?) ??
          notification.title ??
          '';
      body =
          (data['body_en'] as String?) ??
          (data['body'] as String?) ??
          notification.body ??
          '';
    }

    debugPrint('╠═══════════ SHOWING NOTIFICATION ═══════════════════╣');
    debugPrint('║ isAr        : $isAr');
    debugPrint('║ data[title]   : ${data['title']}');
    debugPrint('║ data[title_en]: ${data['title_en']}');
    debugPrint('║ data[body]    : ${data['body']}');
    debugPrint('║ data[body_en] : ${data['body_en']}');
    debugPrint('║ FINAL Title : $title');
    debugPrint('║ FINAL Body  : $body');
    debugPrint('╚════════════════════════════════════════════════════╝');

    final notificationId =
        message.messageId?.hashCode ??
        DateTime.now().millisecondsSinceEpoch % 2147483647;

    final androidDetails = AndroidNotificationDetails(
      _androidChannel.id,
      _androidChannel.name,
      channelDescription: _androidChannel.description,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    _localNotifications.show(
      notificationId,
      title,
      body,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: jsonEncode(data),
    );
  }

  /// Current app locale — updated from outside via [updateLocale].
  /// Used to pick the right notification language.
  String _locale = 'ar';

  /// Call this whenever the app locale changes.
  void updateLocale(String languageCode) {
    final changed = _locale != languageCode;
    _locale = languageCode;
    if (changed) {
      debugPrint('Push: Locale changed to $_locale');
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // NOTIFICATION TAP — ALL NAVIGATION HANDLED HERE
  // ═══════════════════════════════════════════════════════════════

  /// Tap from background/terminated (via FCM onMessageOpenedApp / getInitialMessage)
  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('');
    debugPrint('╔═══════════════════════════════════════════════════════╗');
    debugPrint('║         NOTIFICATION TAPPED — FCM BG/TERMINATED       ║');
    debugPrint('╠═══════════════════════════════════════════════════════╣');
    debugPrint('║ MessageID   : ${message.messageId}');
    debugPrint('║ Title       : ${message.notification?.title}');
    debugPrint('║ Body        : ${message.notification?.body}');
    debugPrint('╠═══════════ DATA FIELD ══════════════════════════════╣');
    message.data.forEach((k, v) {
      debugPrint('║ $k : $v');
    });
    debugPrint('╚═══════════════════════════════════════════════════════╝');
    debugPrint('');

    _navigateFromData(Map<String, dynamic>.from(message.data));
  }

  /// Tap from foreground local notification
  void _onLocalNotificationTap(NotificationResponse response) {
    debugPrint('');
    debugPrint('╔═══════════════════════════════════════════════════════╗');
    debugPrint('║         NOTIFICATION TAPPED — LOCAL FOREGROUND        ║');
    debugPrint('╠═══════════════════════════════════════════════════════╣');
    debugPrint('║ Payload     : ${response.payload}');
    debugPrint('║ ActionId    : ${response.actionId}');
    debugPrint('║ Input       : ${response.input}');
    debugPrint('║ Id          : ${response.id}');
    debugPrint('╚═══════════════════════════════════════════════════════╝');
    debugPrint('');

    if (response.payload != null && response.payload!.isNotEmpty) {
      try {
        final data = Map<String, dynamic>.from(jsonDecode(response.payload!));
        _navigateFromData(data);
      } catch (e) {
        log('Push: Failed to parse notification payload: $e');
      }
    }
  }

  /// Central navigation — handles ALL notification types directly.
  /// Uses navigatorKey so it works from foreground, background, and terminated.
  void _navigateFromData(Map<String, dynamic> data) {
    final refType = data['reference_type']?.toString();
    final refId = int.tryParse(data['reference_id']?.toString() ?? '');

    debugPrint('Push Navigate: refType=$refType, refId=$refId');

    final navigator = navigatorKey.currentState;
    if (navigator == null) {
      debugPrint('Push Navigate: navigatorKey.currentState is NULL');
      return;
    }

    switch (refType) {
      case 'order':
        if (refId != null) {
          debugPrint('Push Navigate: → OrderDetailsScreen(orderId: $refId)');
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

      // Add more types here:
      // case 'promotion':
      //   navigator.push(MaterialPageRoute(
      //     builder: (_) => PromotionScreen(id: refId),
      //   ));
      //   break;

      default:
        debugPrint('Push Navigate: Unknown refType "$refType" — no navigation');
        break;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // TOKEN REFRESH
  // ═══════════════════════════════════════════════════════════════

  void _onTokenRefresh(String newToken) {
    log('Push: Token refreshed');
    registerDeviceToken();
  }

  // ═══════════════════════════════════════════════════════════════
  // ENABLE / DISABLE
  // ═══════════════════════════════════════════════════════════════

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
          await notificationApiService.unregisterDevice(token: fcmToken);
        } catch (_) {}
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

  // ═══════════════════════════════════════════════════════════════
  // DEBUG
  // ═══════════════════════════════════════════════════════════════

  Future<void> _printDebugInfo() async {
    try {
      final token = await _messaging.getToken();
      debugPrint('════════════════════════════════════════');
      if (token != null) {
        debugPrint('FCM TOKEN: $token');
      } else {
        debugPrint('FCM TOKEN: NULL');
      }

      if (Platform.isIOS) {
        final apnsToken = await _messaging.getAPNSToken();
        if (apnsToken == null) {
          debugPrint('APNs TOKEN: NULL — Push will NOT work on iOS!');
        } else {
          debugPrint('APNs TOKEN: Available');
        }
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
