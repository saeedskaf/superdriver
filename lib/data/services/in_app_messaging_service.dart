import 'dart:developer';

import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';

class InAppMessagingService {
  InAppMessagingService._();
  static final InAppMessagingService _instance = InAppMessagingService._();
  factory InAppMessagingService() => _instance;

  final FirebaseInAppMessaging _fiam = FirebaseInAppMessaging.instance;
  bool _initialized = false;

  Future<void> initialize({
    bool dataCollectionEnabled = true,
    bool suppressMessages = false,
  }) async {
    if (_initialized) return;
    try {
      await _fiam.setAutomaticDataCollectionEnabled(dataCollectionEnabled);
      await _fiam.setMessagesSuppressed(suppressMessages);
      _initialized = true;
      log(
        'FIAM initialized (collection=$dataCollectionEnabled, suppressed=$suppressMessages)',
      );
    } catch (e, st) {
      log('FIAM initialization failed: $e', stackTrace: st);
    }
  }

  Future<void> setSuppressed(bool suppressed) async {
    try {
      await _fiam.setMessagesSuppressed(suppressed);
      log('FIAM suppressed=$suppressed');
    } catch (e, st) {
      log('FIAM setSuppressed failed: $e', stackTrace: st);
    }
  }

  Future<void> triggerEvent(String eventName) async {
    if (eventName.trim().isEmpty) return;
    try {
      await _fiam.triggerEvent(eventName.trim());
      log('FIAM event triggered: $eventName');
    } catch (e, st) {
      log('FIAM triggerEvent failed: $e', stackTrace: st);
    }
  }

  Future<void> onUserSignedIn() async {
    await setSuppressed(false);
    await triggerEvent('user_signed_in');
  }

  Future<void> onUserSignedOut() async {
    await setSuppressed(false);
    await triggerEvent('user_signed_out');
  }
}

final inAppMessagingService = InAppMessagingService();
