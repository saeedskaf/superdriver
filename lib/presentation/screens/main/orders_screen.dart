import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:superdriver/domain/bloc/orders/orders_bloc.dart';
import 'package:superdriver/domain/models/order_model.dart';
import 'package:superdriver/l10n/app_localizations.dart';
import 'package:superdriver/presentation/components/text_custom.dart';
import 'package:superdriver/presentation/screens/main/order_details_screen.dart';
import 'package:superdriver/presentation/themes/colors_custom.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadOrders();
  }

  void _loadOrders() {
    context.read<OrdersBloc>().add(const OrdersLoadRequested());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: ColorsCustom.background,
      body: BlocConsumer<OrdersBloc, OrdersState>(
        listener: (context, state) {
          if (state is OrdersError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red.shade700,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          } else if (state is OrderCancelled) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.orderCancelled),
                backgroundColor: Colors.green.shade700,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
            // Refresh orders
            _loadOrders();
          } else if (state is OrderReordered) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.orderReordered),
                backgroundColor: Colors.green.shade700,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Column(
              children: [
                _buildHeader(context, l10n),
                _buildTabs(context, l10n),
                Expanded(child: _buildBody(context, l10n, state)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      decoration: const BoxDecoration(color: Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextCustom(
            text: l10n.myOrders,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: ColorsCustom.textPrimary,
          ),
          const SizedBox(height: 4),
          TextCustom(
            text: l10n.trackYourOrders,
            fontSize: 14,
            color: ColorsCustom.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Container(
        height: 50,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: ColorsCustom.grey100,
          borderRadius: BorderRadius.circular(14),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelColor: ColorsCustom.primary,
          unselectedLabelColor: ColorsCustom.textSecondary,
          labelStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          tabs: [
            Tab(text: l10n.active),
            Tab(text: l10n.completed),
            Tab(text: l10n.cancelled),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    AppLocalizations l10n,
    OrdersState state,
  ) {
    if (state is OrdersLoading) {
      return _buildLoadingState();
    }

    if (state is OrdersError) {
      return _buildErrorState(context, l10n, state.message);
    }

    if (state is OrdersEmpty) {
      return TabBarView(
        controller: _tabController,
        children: [
          _buildEmptyState(context, l10n, l10n.noActiveOrders),
          _buildEmptyState(context, l10n, l10n.noCompletedOrders),
          _buildEmptyState(context, l10n, l10n.noCancelledOrders),
        ],
      );
    }

    if (state is OrdersLoaded) {
      return TabBarView(
        controller: _tabController,
        children: [
          _buildOrdersList(context, l10n, state.activeOrders, 'active'),
          _buildOrdersList(context, l10n, state.completedOrders, 'completed'),
          _buildOrdersList(context, l10n, state.cancelledOrders, 'cancelled'),
        ],
      );
    }

    return _buildEmptyState(context, l10n, l10n.noOrders);
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(ColorsCustom.primary),
            ),
          ),
          const SizedBox(height: 16),
          TextCustom(
            text: 'جاري التحميل...',
            fontSize: 16,
            color: ColorsCustom.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    AppLocalizations l10n,
    String message,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 50,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 24),
            TextCustom(
              text: l10n.errorOccurred,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: ColorsCustom.textPrimary,
            ),
            const SizedBox(height: 8),
            TextCustom(
              text: message,
              fontSize: 14,
              color: ColorsCustom.textSecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadOrders,
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorsCustom.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: TextCustom(
                text: l10n.retry,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    AppLocalizations l10n,
    String message,
  ) {
    return RefreshIndicator(
      onRefresh: () async => _loadOrders(),
      color: ColorsCustom.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.8, end: 1),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: ColorsCustom.grey100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.receipt_long_outlined,
                          size: 56,
                          color: ColorsCustom.grey400,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                TextCustom(
                  text: message,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: ColorsCustom.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrdersList(
    BuildContext context,
    AppLocalizations l10n,
    List<Order> orders,
    String type,
  ) {
    if (orders.isEmpty) {
      String message;
      switch (type) {
        case 'active':
          message = l10n.noActiveOrders;
          break;
        case 'completed':
          message = l10n.noCompletedOrders;
          break;
        case 'cancelled':
          message = l10n.noCancelledOrders;
          break;
        default:
          message = l10n.noOrders;
      }
      return _buildEmptyState(context, l10n, message);
    }

    return RefreshIndicator(
      onRefresh: () async => _loadOrders(),
      color: ColorsCustom.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: Duration(milliseconds: 300 + (index * 80)),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildOrderCard(context, l10n, order),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(
    BuildContext context,
    AppLocalizations l10n,
    Order order,
  ) {
    final statusInfo = _getStatusInfo(order.status, l10n);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<OrdersBloc>(),
              child: OrderDetailsScreen(order: order),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Restaurant Logo
                Container(
                  width: 65,
                  height: 65,
                  decoration: BoxDecoration(
                    color: statusInfo['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: order.restaurantLogo != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            order.restaurantLogo!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.restaurant_rounded,
                              color: statusInfo['color'],
                              size: 30,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.restaurant_rounded,
                          color: statusInfo['color'],
                          size: 30,
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextCustom(
                            text: order.orderNumber,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: ColorsCustom.textPrimary,
                          ),
                          _buildStatusBadge(statusInfo),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.restaurant_rounded,
                            size: 16,
                            color: ColorsCustom.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: TextCustom(
                              text: order.restaurantName,
                              fontSize: 14,
                              color: ColorsCustom.textSecondary,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 16,
                            color: ColorsCustom.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          TextCustom(
                            text: '${order.itemsCount} ${l10n.items}',
                            fontSize: 13,
                            color: ColorsCustom.textSecondary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(height: 1, color: ColorsCustom.grey200),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 18,
                      color: ColorsCustom.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    TextCustom(
                      text: _formatDate(order.createdAt, l10n),
                      fontSize: 13,
                      color: ColorsCustom.textSecondary,
                    ),
                  ],
                ),
                TextCustom(
                  text:
                      '${order.totalDouble.toStringAsFixed(2)} ${l10n.currency}',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: ColorsCustom.primary,
                ),
              ],
            ),

            // Action buttons for active orders
            if (order.isActive && order.canCancel) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _showCancelDialog(context, l10n, order),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red.shade700,
                        side: BorderSide(color: Colors.red.shade200),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: TextCustom(
                        text: l10n.cancelOrder,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: context.read<OrdersBloc>(),
                              child: OrderDetailsScreen(order: order),
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorsCustom.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: TextCustom(
                        text: l10n.trackOrder,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            // Reorder button for completed orders
            if (order.isCompleted) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _reorder(context, order),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ColorsCustom.primary,
                    side: BorderSide(color: ColorsCustom.primary),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.replay_rounded,
                        size: 20,
                        color: ColorsCustom.primary,
                      ),
                      const SizedBox(width: 8),
                      TextCustom(
                        text: l10n.reorder,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: ColorsCustom.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(Map<String, dynamic> statusInfo) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusInfo['color'].withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusInfo['icon'], size: 14, color: statusInfo['color']),
          const SizedBox(width: 4),
          TextCustom(
            text: statusInfo['label'],
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: statusInfo['color'],
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getStatusInfo(String status, AppLocalizations l10n) {
    switch (status) {
      case 'draft':
        return {
          'label': l10n.statusDraft,
          'color': Colors.grey,
          'icon': Icons.edit_outlined,
        };
      case 'pending':
        return {
          'label': l10n.statusPending,
          'color': Colors.orange,
          'icon': Icons.hourglass_empty_rounded,
        };
      case 'accepted':
        return {
          'label': l10n.statusAccepted,
          'color': Colors.blue,
          'icon': Icons.check_circle_outline_rounded,
        };
      case 'preparing':
        return {
          'label': l10n.statusPreparing,
          'color': Colors.purple,
          'icon': Icons.restaurant_rounded,
        };
      case 'ready':
        return {
          'label': l10n.statusReady,
          'color': Colors.teal,
          'icon': Icons.inventory_2_rounded,
        };
      case 'picked':
        return {
          'label': l10n.statusPicked,
          'color': ColorsCustom.primary,
          'icon': Icons.delivery_dining_rounded,
        };
      case 'delivered':
      case 'completed':
        return {
          'label': l10n.statusCompleted,
          'color': Colors.green,
          'icon': Icons.check_circle_rounded,
        };
      case 'cancelled':
        return {
          'label': l10n.statusCancelled,
          'color': Colors.red,
          'icon': Icons.cancel_rounded,
        };
      default:
        return {
          'label': status,
          'color': Colors.grey,
          'icon': Icons.help_outline_rounded,
        };
    }
  }

  String _formatDate(DateTime date, AppLocalizations l10n) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) {
      return '${l10n.ago} ${diff.inMinutes} ${l10n.minutes}';
    } else if (diff.inHours < 24) {
      return '${l10n.ago} ${diff.inHours} ${l10n.hours}';
    } else if (diff.inDays == 1) {
      return l10n.yesterday;
    } else if (diff.inDays < 7) {
      return '${l10n.ago} ${diff.inDays} ${l10n.days}';
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }

  void _showCancelDialog(
    BuildContext context,
    AppLocalizations l10n,
    Order order,
  ) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: TextCustom(
          text: l10n.cancelOrder,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: ColorsCustom.textPrimary,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextCustom(
              text: l10n.cancelOrderConfirmation,
              fontSize: 15,
              color: ColorsCustom.textSecondary,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: l10n.cancellationReason,
                filled: true,
                fillColor: ColorsCustom.grey100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: TextCustom(
              text: l10n.back,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: ColorsCustom.textSecondary,
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<OrdersBloc>().add(
                OrderCancelRequested(
                  orderId: order.id,
                  reason: reasonController.text.isNotEmpty
                      ? reasonController.text
                      : 'تم الإلغاء من قبل المستخدم',
                ),
              );
            },
            child: TextCustom(
              text: l10n.confirmCancel,
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade700,
            ),
          ),
        ],
      ),
    );
  }

  void _reorder(BuildContext context, Order order) {
    context.read<OrdersBloc>().add(OrderReorderRequested(orderId: order.id));
  }
}
