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
  int _currentPage = 1;
  bool _hasMore = false;

  NotificationBloc() : super(const NotificationInitial()) {
    on<NotificationsLoadRequested>(_onLoad);
    on<NotificationsLoadMoreRequested>(_onLoadMore);
    on<UnreadCountLoadRequested>(_onLoadUnreadCount);
    on<NotificationMarkAsReadRequested>(_onMarkAsRead);
    on<NotificationMarkAllAsReadRequested>(_onMarkAllAsRead);
    on<NotificationReceived>(_onNotificationReceived);
    on<NotificationResetRequested>(_onReset);
  }

  Future<void> _onLoad(
    NotificationsLoadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading(unreadCount: _unreadCount));
    try {
      _currentPage = 1;
      final results = await Future.wait([
        notificationService.fetchNotifications(page: 1),
        notificationService.fetchUnreadCount(),
      ]);

      final page = results[0] as NotificationPage;
      _notifications = page.items;
      _hasMore = page.hasMore;
      _unreadCount = results[1] as int;

      emit(
        NotificationsLoaded(
          notifications: _notifications,
          unreadCount: _unreadCount,
          hasMore: _hasMore,
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

  Future<void> _onLoadMore(
    NotificationsLoadMoreRequested event,
    Emitter<NotificationState> emit,
  ) async {
    if (!_hasMore) return;

    emit(
      NotificationsLoaded(
        notifications: _notifications,
        unreadCount: _unreadCount,
        hasMore: _hasMore,
        isLoadingMore: true,
      ),
    );

    try {
      final page = await notificationService.fetchNotifications(
        page: _currentPage + 1,
      );
      _currentPage++;
      _notifications = [..._notifications, ...page.items];
      _hasMore = page.hasMore;

      emit(
        NotificationsLoaded(
          notifications: _notifications,
          unreadCount: _unreadCount,
          hasMore: _hasMore,
        ),
      );
    } catch (e) {
      log('NotificationBloc loadMore error: $e');
      // Keep current list, just stop loading indicator
      emit(
        NotificationsLoaded(
          notifications: _notifications,
          unreadCount: _unreadCount,
          hasMore: _hasMore,
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
          hasMore: _hasMore,
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
          return n.copyWith(isRead: true);
        }
        return n;
      }).toList();

      emit(
        NotificationsLoaded(
          notifications: _notifications,
          unreadCount: _unreadCount,
          hasMore: _hasMore,
        ),
      );
    } catch (e) {
      log('NotificationBloc markAsRead error: $e');
      emit(
        NotificationsLoaded(
          notifications: _notifications,
          unreadCount: _unreadCount,
          hasMore: _hasMore,
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
          .map((n) => n.copyWith(isRead: true))
          .toList();

      emit(NotificationsLoaded(
        notifications: _notifications,
        unreadCount: 0,
        hasMore: _hasMore,
      ));
    } catch (e) {
      log('NotificationBloc markAllAsRead error: $e');
      emit(
        NotificationsLoaded(
          notifications: _notifications,
          unreadCount: _unreadCount,
          hasMore: _hasMore,
        ),
      );
    }
  }

  Future<void> _onNotificationReceived(
    NotificationReceived event,
    Emitter<NotificationState> emit,
  ) async {
    // Bump count optimistically
    _unreadCount++;
    emit(
      NotificationsLoaded(
        notifications: _notifications,
        unreadCount: _unreadCount,
        hasMore: _hasMore,
      ),
    );

    // Sync only the unread count from the server (avoids full list reload
    // which would emit NotificationLoading and cause UI flicker)
    add(const UnreadCountLoadRequested());
  }

  void _onReset(
    NotificationResetRequested event,
    Emitter<NotificationState> emit,
  ) {
    _unreadCount = 0;
    _notifications = [];
    _currentPage = 1;
    _hasMore = false;
    emit(const NotificationInitial());
  }
}
