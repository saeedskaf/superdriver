// lib/domain/bloc/notification/notification_bloc.dart

import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:superdriver/domain/models/notification_model.dart';
import 'package:superdriver/data/services/notification_service.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  int _unreadCount = 0;
  List<NotificationItem> _notifications = [];

  NotificationBloc() : super(const NotificationInitial()) {
    on<NotificationsLoadRequested>(_onLoad);
    on<UnreadCountLoadRequested>(_onLoadUnreadCount);
    on<NotificationMarkAsReadRequested>(_onMarkAsRead);
    on<NotificationMarkAllAsReadRequested>(_onMarkAllAsRead);
    on<NotificationReceived>(_onNotificationReceived);
  }

  Future<void> _onLoad(
    NotificationsLoadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading(unreadCount: _unreadCount));
    try {
      final results = await Future.wait([
        notificationService.fetchNotifications(),
        notificationService.fetchUnreadCount(),
      ]);

      _notifications = results[0] as List<NotificationItem>;
      _unreadCount = results[1] as int;

      emit(
        NotificationsLoaded(
          notifications: _notifications,
          unreadCount: _unreadCount,
        ),
      );
    } catch (e) {
      log('NotificationBloc load error: $e');
      emit(
        NotificationError(
          e.toString().replaceAll('Exception: ', ''),
          unreadCount: _unreadCount,
        ),
      );
    }
  }

  Future<void> _onLoadUnreadCount(
    UnreadCountLoadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      _unreadCount = await notificationService.fetchUnreadCount();
      emit(
        NotificationsLoaded(
          notifications: _notifications,
          unreadCount: _unreadCount,
        ),
      );
    } catch (e) {
      log('NotificationBloc unread count error: $e');
    }
  }

  Future<void> _onMarkAsRead(
    NotificationMarkAsReadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await notificationService.markAsRead(event.notificationId);

      // Update local state
      _notifications = _notifications.map((n) {
        if (n.id == event.notificationId && !n.isRead) {
          _unreadCount = (_unreadCount - 1).clamp(0, 99999);
          return NotificationItem(
            id: n.id,
            notificationType: n.notificationType,
            title: n.title,
            titleEn: n.titleEn,
            body: n.body,
            bodyEn: n.bodyEn,
            isRead: true,
            createdAt: n.createdAt,
          );
        }
        return n;
      }).toList();

      emit(
        NotificationsLoaded(
          notifications: _notifications,
          unreadCount: _unreadCount,
        ),
      );
    } catch (e) {
      log('NotificationBloc markAsRead error: $e');
      // Re-emit current state so UI stays consistent
      emit(
        NotificationsLoaded(
          notifications: _notifications,
          unreadCount: _unreadCount,
        ),
      );
    }
  }

  Future<void> _onMarkAllAsRead(
    NotificationMarkAllAsReadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await notificationService.markAllAsRead();

      _unreadCount = 0;
      _notifications = _notifications
          .map(
            (n) => NotificationItem(
              id: n.id,
              notificationType: n.notificationType,
              title: n.title,
              titleEn: n.titleEn,
              body: n.body,
              bodyEn: n.bodyEn,
              isRead: true,
              createdAt: n.createdAt,
            ),
          )
          .toList();

      emit(NotificationsLoaded(notifications: _notifications, unreadCount: 0));
    } catch (e) {
      log('NotificationBloc markAllAsRead error: $e');
      emit(
        NotificationError(
          e.toString().replaceAll('Exception: ', ''),
          unreadCount: _unreadCount,
        ),
      );
    }
  }

  Future<void> _onNotificationReceived(
    NotificationReceived event,
    Emitter<NotificationState> emit,
  ) async {
    // Bump count optimistically, then reload
    _unreadCount++;
    emit(
      NotificationsLoaded(
        notifications: _notifications,
        unreadCount: _unreadCount,
      ),
    );

    // Reload full list in background
    add(const NotificationsLoadRequested());
  }
}
