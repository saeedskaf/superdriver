// lib/presentation/screens/notifications/notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:superdriver/domain/bloc/auth/auth_bloc.dart';
import 'package:superdriver/domain/bloc/notification/notification_bloc.dart';
import 'package:superdriver/domain/bloc/orders/orders_bloc.dart';
import 'package:superdriver/domain/models/notification_model.dart';
import 'package:superdriver/l10n/app_localizations.dart';
import 'package:superdriver/presentation/components/text_custom.dart';
import 'package:superdriver/presentation/screens/main/order_details_screen.dart';
import 'package:superdriver/presentation/themes/colors_custom.dart';
import 'package:superdriver/domain/services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    final isAuth = context.read<AuthBloc>().state is AuthAuthenticated;
    if (isAuth) {
      context.read<NotificationBloc>().add(const NotificationsLoadRequested());
    }
  }

  Future<void> _onRefresh() async {
    context.read<NotificationBloc>().add(const NotificationsLoadRequested());
    await Future.delayed(const Duration(milliseconds: 600));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isAuth = context.read<AuthBloc>().state is AuthAuthenticated;

    return Scaffold(
      backgroundColor: ColorsCustom.background,
      appBar: _buildAppBar(l10n),
      body: isAuth ? _buildBody(l10n) : _buildLoginRequired(l10n),
    );
  }

  PreferredSizeWidget _buildAppBar(AppLocalizations l10n) {
    return AppBar(
      backgroundColor: ColorsCustom.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            decoration: BoxDecoration(
              color: ColorsCustom.primarySoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: ColorsCustom.primary,
            ),
          ),
        ),
      ),
      title: TextCustom(
        text: l10n.notifications,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: ColorsCustom.textPrimary,
      ),
      actions: [
        BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) {
            if (state.unreadCount > 0) {
              return TextButton(
                onPressed: () {
                  context.read<NotificationBloc>().add(
                    const NotificationMarkAllAsReadRequested(),
                  );
                },
                child: TextCustom(
                  text: l10n.markAllAsRead,
                  fontSize: 13,
                  color: ColorsCustom.primary,
                  fontWeight: FontWeight.w600,
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, state) {
        if (state is NotificationLoading && state is! NotificationsLoaded) {
          return const Center(
            child: CircularProgressIndicator(color: ColorsCustom.primary),
          );
        }

        if (state is NotificationError && state is! NotificationsLoaded) {
          return _buildErrorState(l10n, state.message);
        }

        if (state is NotificationsLoaded) {
          if (state.notifications.isEmpty) {
            return _buildEmptyState(l10n);
          }
          return RefreshIndicator(
            onRefresh: _onRefresh,
            color: ColorsCustom.primary,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: state.notifications.length,
              separatorBuilder: (_, __) => const Divider(
                height: 1,
                indent: 72,
                endIndent: 16,
                color: ColorsCustom.border,
              ),
              itemBuilder: (context, index) {
                return _NotificationTile(
                  notification: state.notifications[index],
                  onTap: () => _onNotificationTap(state.notifications[index]),
                );
              },
            ),
          );
        }

        return const Center(
          child: CircularProgressIndicator(color: ColorsCustom.primary),
        );
      },
    );
  }

  void _onNotificationTap(NotificationItem notification) {
    if (!notification.isRead) {
      context.read<NotificationBloc>().add(
        NotificationMarkAsReadRequested(notification.id),
      );
    }
    _navigateByType(notification);
  }

  void _navigateByType(NotificationItem notification) {
    final type = notification.notificationType;

    debugPrint('═══════════ NOTIFICATION LIST TAP ═══════════');
    debugPrint('Type : $type');
    debugPrint('ID   : ${notification.id}');
    debugPrint('Title: ${notification.title}');
    debugPrint('═════════════════════════════════════════════');

    switch (type) {
      case 'order_placed':
      case 'order_accepted':
      case 'order_preparing':
      case 'order_picked':
      case 'order_delivered':
      case 'order_cancelled':
        _navigateToOrderFromNotification(notification);
        break;
      default:
        break;
    }
  }

  void _navigateToOrderFromNotification(NotificationItem notification) {
    _fetchDetailAndNavigate(notification.id);
  }

  Future<void> _fetchDetailAndNavigate(int notificationId) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: CircularProgressIndicator(color: ColorsCustom.primary),
        ),
      );

      final detail = await notificationApiService.fetchNotificationDetail(
        notificationId,
      );

      if (mounted) Navigator.pop(context);

      if (detail.referenceType == 'order' && detail.referenceId != null) {
        _goToOrder(detail.referenceId!);
      } else {
        debugPrint('Push: No order reference in notification detail');
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      debugPrint('Push: Error fetching notification detail: $e');
    }
  }

  void _goToOrder(int orderId) {
    debugPrint('Navigating to OrderDetailsScreen(orderId: $orderId)');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<OrdersBloc>(),
          child: OrderDetailsScreen(orderId: orderId),
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: ColorsCustom.primarySoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                size: 40,
                color: ColorsCustom.primary,
              ),
            ),
            const SizedBox(height: 20),
            TextCustom(
              text: l10n.noNotifications,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ColorsCustom.textPrimary,
            ),
            const SizedBox(height: 8),
            TextCustom(
              text: l10n.noNotificationsMessage,
              fontSize: 13,
              color: ColorsCustom.textSecondary,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(AppLocalizations l10n, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: ColorsCustom.error,
            ),
            const SizedBox(height: 16),
            TextCustom(
              text: l10n.errorOccurred,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ColorsCustom.textPrimary,
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => context.read<NotificationBloc>().add(
                const NotificationsLoadRequested(),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: ColorsCustom.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextCustom(
                  text: l10n.retry,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginRequired(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.notifications_off_rounded,
              size: 48,
              color: ColorsCustom.textHint,
            ),
            const SizedBox(height: 16),
            TextCustom(
              text: l10n.loginRequired,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ColorsCustom.textPrimary,
            ),
            const SizedBox(height: 8),
            TextCustom(
              text: l10n.loginRequiredMessage,
              fontSize: 13,
              color: ColorsCustom.textSecondary,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================
// NOTIFICATION TILE
// ============================================

class _NotificationTile extends StatelessWidget {
  final NotificationItem notification;
  final VoidCallback onTap;

  const _NotificationTile({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: notification.isRead
            ? Colors.transparent
            : ColorsCustom.primarySoft,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIcon(),
            const SizedBox(width: 12),
            Expanded(child: _buildContent(context)),
            if (!notification.isRead) _buildUnreadDot(),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    final iconImage = _getImageForType(notification.notificationType);
    final iconColor = _getColorForType(notification.notificationType);

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: iconColor.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Image.asset(iconImage, fit: BoxFit.contain, color: iconColor),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final displayTitle =
        (!isAr &&
            notification.titleEn != null &&
            notification.titleEn!.isNotEmpty)
        ? notification.titleEn!
        : notification.title;
    final displayBody =
        (!isAr &&
            notification.bodyEn != null &&
            notification.bodyEn!.isNotEmpty)
        ? notification.bodyEn!
        : notification.body;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextCustom(
          text: displayTitle,
          fontSize: 14,
          fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w700,
          color: ColorsCustom.textPrimary,
          maxLines: 2,
        ),
        const SizedBox(height: 4),
        TextCustom(
          text: displayBody,
          fontSize: 12,
          color: ColorsCustom.textSecondary,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        TextCustom(
          text: _formatTimeAgo(notification.createdAt, context),
          fontSize: 11,
          color: ColorsCustom.textHint,
        ),
      ],
    );
  }

  Widget _buildUnreadDot() {
    return Container(
      width: 8,
      height: 8,
      margin: const EdgeInsets.only(top: 6),
      decoration: const BoxDecoration(
        color: ColorsCustom.primary,
        shape: BoxShape.circle,
      ),
    );
  }

  String _getImageForType(String type) {
    switch (type) {
      case 'order_placed':
        return 'assets/icons/status_confirmed.png';
      case 'order_accepted':
        return 'assets/icons/status_delivered.png';
      case 'order_preparing':
        return 'assets/icons/status_preparing.png';
      case 'order_picked':
        return 'assets/icons/status_ready.png';
      case 'order_delivered':
        return 'assets/icons/status_delivering.png';
      case 'order_cancelled':
        return 'assets/icons/status_cancelled.png';
      case 'promotion':
        return 'assets/icons/status_announcement.png';
      default:
        return 'assets/icons/status_error.png';
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'order_placed':
        return ColorsCustom.primary;
      case 'order_accepted':
        return ColorsCustom.success;
      case 'order_preparing':
        return ColorsCustom.warning;
      case 'order_picked':
        return ColorsCustom.primary;
      case 'order_delivered':
        return ColorsCustom.success;
      case 'order_cancelled':
        return ColorsCustom.error;
      case 'promotion':
        return ColorsCustom.secondary;
      default:
        return ColorsCustom.textSecondary;
    }
  }

  String _formatTimeAgo(DateTime dateTime, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return l10n.today;
    if (diff.inMinutes < 60) return l10n.minutesAgo(diff.inMinutes);
    if (diff.inHours < 24) return l10n.hoursAgo(diff.inHours);
    if (diff.inDays == 1) return l10n.yesterday;
    if (diff.inDays < 7) return l10n.daysAgo(diff.inDays);

    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}
