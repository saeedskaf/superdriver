// lib/domain/bloc/notification/notification_event.dart

part of 'notification_bloc.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class NotificationsLoadRequested extends NotificationEvent {
  const NotificationsLoadRequested();
}

class UnreadCountLoadRequested extends NotificationEvent {
  const UnreadCountLoadRequested();
}

class NotificationMarkAsReadRequested extends NotificationEvent {
  final int notificationId;

  const NotificationMarkAsReadRequested(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

class NotificationMarkAllAsReadRequested extends NotificationEvent {
  const NotificationMarkAllAsReadRequested();
}

/// Called when a push notification arrives (foreground) to bump count
class NotificationReceived extends NotificationEvent {
  const NotificationReceived();
}
