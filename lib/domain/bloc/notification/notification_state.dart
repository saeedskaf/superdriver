// lib/domain/bloc/notification/notification_state.dart

part of 'notification_bloc.dart';

abstract class NotificationState extends Equatable {
  final int unreadCount;

  const NotificationState({this.unreadCount = 0});

  @override
  List<Object?> get props => [unreadCount];
}

class NotificationInitial extends NotificationState {
  const NotificationInitial() : super(unreadCount: 0);
}

class NotificationLoading extends NotificationState {
  const NotificationLoading({super.unreadCount});
}

class NotificationsLoaded extends NotificationState {
  final List<NotificationItem> notifications;

  const NotificationsLoaded({
    required this.notifications,
    required super.unreadCount,
  });

  @override
  List<Object?> get props => [notifications, unreadCount];
}

class NotificationError extends NotificationState {
  final String message;

  const NotificationError(this.message, {super.unreadCount});

  @override
  List<Object?> get props => [message, unreadCount];
}
