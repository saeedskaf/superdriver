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
  final bool hasMore;
  final bool isLoadingMore;

  const NotificationsLoaded({
    required this.notifications,
    required super.unreadCount,
    this.hasMore = false,
    this.isLoadingMore = false,
  });

  @override
  List<Object?> get props => [notifications, unreadCount, hasMore, isLoadingMore];
}

class NotificationError extends NotificationState {
  final String message;

  const NotificationError(this.message, {super.unreadCount});

  @override
  List<Object?> get props => [message, unreadCount];
}
