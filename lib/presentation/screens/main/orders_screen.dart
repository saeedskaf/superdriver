import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:superdriver/domain/bloc/orders/orders_bloc.dart';
import 'package:superdriver/domain/models/order_model.dart';
import 'package:superdriver/l10n/app_localizations.dart';
import 'package:superdriver/presentation/components/text_custom.dart';
import 'package:superdriver/presentation/components/btn_custom.dart';
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

  List<Order> _activeOrders = [];
  List<Order> _historyOrders = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadActiveOrders();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    if (_tabController.index == 0) {
      _loadActiveOrders();
    } else {
      _loadHistoryOrders();
    }
  }

  void _loadActiveOrders() {
    context.read<OrdersBloc>().add(const OrdersActiveLoadRequested());
  }

  void _loadHistoryOrders() {
    context.read<OrdersBloc>().add(const OrdersHistoryLoadRequested());
  }

  void _refreshCurrentTab() {
    if (_tabController.index == 0) {
      _loadActiveOrders();
    } else {
      _loadHistoryOrders();
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  // ── Snackbar ──

  void _showSnackBar(
    BuildContext context,
    String message, {
    required bool isError,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? ColorsCustom.error : ColorsCustom.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ── Navigation ──

  void _navigateToOrderDetails(BuildContext context, Order order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<OrdersBloc>(),
          child: OrderDetailsScreen(orderId: order.id),
        ),
      ),
    ).then((_) {
      if (mounted) _refreshCurrentTab();
    });
  }

  void _reorder(BuildContext context, Order order) {
    context.read<OrdersBloc>().add(OrderReorderRequested(orderId: order.id));
  }

  // ── Build ──

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: ColorsCustom.background,
      body: BlocConsumer<OrdersBloc, OrdersState>(
        listenWhen: (previous, current) {
          return current is OrdersLoaded ||
              current is OrdersLoading ||
              current is OrdersError ||
              current is OrdersEmpty ||
              current is OrderCancelled ||
              current is OrderCancelError ||
              current is OrderReordered ||
              current is OrderReorderError;
        },
        listener: (context, state) {
          if (state is OrdersLoaded) {
            setState(() {
              _activeOrders = state.activeOrders;
              _historyOrders = state.historyOrders;
              _isLoading = false;
              _errorMessage = null;
            });
          } else if (state is OrdersLoading) {
            setState(() => _isLoading = true);
          } else if (state is OrdersError) {
            setState(() {
              _isLoading = false;
              _errorMessage = state.message;
            });
            _showSnackBar(context, state.message, isError: true);
          } else if (state is OrdersEmpty) {
            setState(() {
              _isLoading = false;
              _errorMessage = null;
            });
          } else if (state is OrderCancelled) {
            _refreshCurrentTab();
          } else if (state is OrderCancelError) {
            _showSnackBar(context, state.message, isError: true);
          } else if (state is OrderReordered) {
            _showSnackBar(context, l10n.orderReordered, isError: false);
          } else if (state is OrderReorderError) {
            _showSnackBar(context, state.message, isError: true);
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              _buildHeader(l10n),
              _buildTabs(l10n),
              Expanded(child: _buildTabContent(l10n)),
            ],
          );
        },
      ),
    );
  }

  // ── Header ──

  Widget _buildHeader(AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        MediaQuery.of(context).padding.top + 16,
        24,
        16,
      ),
      decoration: const BoxDecoration(color: ColorsCustom.surface),
      child: Row(
        children: [
          ClipRRect(
            child: Image.asset(
              'assets/icons/orders_empty_state.png',
              width: 50,
              height: 50,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextCustom(
                  text: l10n.myOrders,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: ColorsCustom.textPrimary,
                ),
                const SizedBox(height: 2),
                TextCustom(
                  text: l10n.trackYourOrders,
                  fontSize: 13,
                  color: ColorsCustom.textSecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Tabs ──

  Widget _buildTabs(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: ColorsCustom.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Container(
        height: 50,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: ColorsCustom.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: ColorsCustom.border),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: ColorsCustom.surface,
            borderRadius: BorderRadius.circular(11),
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
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.pending_actions_rounded, size: 18),
                  const SizedBox(width: 6),
                  Text(l10n.active),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.history_rounded, size: 18),
                  const SizedBox(width: 6),
                  Text(l10n.history),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Tab Content ──

  Widget _buildTabContent(AppLocalizations l10n) {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildOrdersTab(
          l10n,
          orders: _activeOrders,
          emptyMessage: l10n.noActiveOrders,
          emptyIcon: Icons.pending_actions_outlined,
          isActiveTab: true,
        ),
        _buildOrdersTab(
          l10n,
          orders: _historyOrders,
          emptyMessage: l10n.noOrderHistory,
          emptyIcon: Icons.history_rounded,
          isActiveTab: false,
        ),
      ],
    );
  }

  Widget _buildOrdersTab(
    AppLocalizations l10n, {
    required List<Order> orders,
    required String emptyMessage,
    required IconData emptyIcon,
    required bool isActiveTab,
  }) {
    if (_isLoading) return _buildLoadingState(l10n);
    if (_errorMessage != null) return _buildErrorState(l10n);
    if (orders.isEmpty) return _buildEmptyState(l10n, emptyMessage, emptyIcon);
    return _buildOrdersList(l10n, orders, isActiveTab);
  }

  // ── Loading ──

  Widget _buildLoadingState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 44,
            height: 44,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(ColorsCustom.primary),
            ),
          ),
          const SizedBox(height: 16),
          TextCustom(
            text: l10n.loading,
            fontSize: 15,
            color: ColorsCustom.textSecondary,
          ),
        ],
      ),
    );
  }

  // ── Error ──

  Widget _buildErrorState(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: ColorsCustom.errorBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: ColorsCustom.error,
              ),
            ),
            const SizedBox(height: 24),
            TextCustom(
              text: l10n.errorOccurred,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ColorsCustom.textPrimary,
            ),
            const SizedBox(height: 8),
            TextCustom(
              text: _errorMessage ?? '',
              fontSize: 14,
              color: ColorsCustom.textSecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ButtonCustom.primary(
              text: l10n.retry,
              onPressed: _refreshCurrentTab,
            ),
          ],
        ),
      ),
    );
  }

  // ── Empty ──

  Widget _buildEmptyState(
    AppLocalizations l10n,
    String message,
    IconData icon,
  ) {
    return RefreshIndicator(
      onRefresh: () async => _refreshCurrentTab(),
      color: ColorsCustom.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: ColorsCustom.primarySoft,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 48,
                    color: ColorsCustom.primary.withAlpha(153),
                  ),
                ),
                const SizedBox(height: 24),
                TextCustom(
                  text: message,
                  fontSize: 16,
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

  // ── Orders List ──

  Widget _buildOrdersList(
    AppLocalizations l10n,
    List<Order> orders,
    bool isActiveTab,
  ) {
    return RefreshIndicator(
      onRefresh: () async => _refreshCurrentTab(),
      color: ColorsCustom.primary,
      backgroundColor: ColorsCustom.surface,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _buildOrderCard(l10n, orders[index], isActiveTab),
          );
        },
      ),
    );
  }

  // ── Order Card ──

  Widget _buildOrderCard(AppLocalizations l10n, Order order, bool isActiveTab) {
    final statusInfo = _getStatusInfo(order.status, l10n);
    final Color statusColor = statusInfo['color'];

    return GestureDetector(
      onTap: () => _navigateToOrderDetails(context, order),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ColorsCustom.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ColorsCustom.border),
        ),
        child: Column(
          children: [
            // ── Header row ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(20),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: statusColor.withAlpha(51)),
                  ),
                  child:
                      (order.restaurantLogo != null &&
                          order.restaurantLogo!.isNotEmpty)
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(13),
                          child: Image.network(
                            order.restaurantLogo!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.restaurant_rounded,
                              color: statusColor,
                              size: 26,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.restaurant_rounded,
                          color: statusColor,
                          size: 26,
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextCustom(
                              text: _getShortOrderNumber(order.orderNumber),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: ColorsCustom.textPrimary,
                              maxLines: 1,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildStatusBadge(statusInfo),
                        ],
                      ),
                      const SizedBox(height: 4),
                      TextCustom(
                        text: order.restaurantName,
                        fontSize: 14,
                        color: ColorsCustom.textSecondary,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.shopping_bag_outlined,
                            size: 14,
                            color: ColorsCustom.secondaryDark,
                          ),
                          const SizedBox(width: 4),
                          TextCustom(
                            text:
                                '${l10n.items}: ${_parseItemsCount(order.itemsCount)}',
                            fontSize: 12,
                            color: ColorsCustom.secondaryDark,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(color: ColorsCustom.border, height: 1),
            ),

            // ── Footer ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      size: 16,
                      color: ColorsCustom.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    TextCustom(
                      text: _formatDate(order.createdAt, l10n),
                      fontSize: 12,
                      color: ColorsCustom.textSecondary,
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: ColorsCustom.primarySoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextCustom(
                    text:
                        '${order.totalDouble.toStringAsFixed(0)} ${l10n.currency}',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: ColorsCustom.primary,
                  ),
                ),
              ],
            ),

            // ── Action buttons ──
            if (isActiveTab && ['draft', 'placed'].contains(order.status)) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: ButtonCustom.secondary(
                      text: l10n.cancelOrder,
                      onPressed: () => _showCancelDialog(context, l10n, order),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ButtonCustom.primary(
                      text: l10n.orderDetails,
                      onPressed: () => _navigateToOrderDetails(context, order),
                    ),
                  ),
                ],
              ),
            ] else if (isActiveTab) ...[
              const SizedBox(height: 14),
              ButtonCustom.primary(
                text: l10n.orderDetails,
                onPressed: () => _navigateToOrderDetails(context, order),
              ),
            ],

            if (!isActiveTab && order.isCompleted) ...[
              const SizedBox(height: 14),
              ButtonCustom.secondary(
                text: l10n.reorder,
                onPressed: () => _reorder(context, order),
                icon: const Icon(
                  Icons.replay_rounded,
                  size: 18,
                  color: ColorsCustom.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(Map<String, dynamic> statusInfo) {
    final Color color = statusInfo['color'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(31),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(51)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 12,
            height: 12,
            child: Image.asset(
              statusInfo['image'],
              fit: BoxFit.contain,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          TextCustom(
            text: statusInfo['label'],
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ],
      ),
    );
  }

  // ── Cancel Dialog ──

  void _showCancelDialog(
    BuildContext context,
    AppLocalizations l10n,
    Order order,
  ) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ColorsCustom.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: EdgeInsets.zero,
        content: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: ColorsCustom.errorBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cancel_outlined,
                  color: ColorsCustom.error,
                  size: 28,
                ),
              ),
              const SizedBox(height: 20),
              TextCustom(
                text: l10n.cancelOrder,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ColorsCustom.textPrimary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              TextCustom(
                text: l10n.cancelOrderConfirmation,
                fontSize: 14,
                color: ColorsCustom.textSecondary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                maxLines: 3,
                style: const TextStyle(
                  fontSize: 14,
                  color: ColorsCustom.textPrimary,
                  fontFamily: 'Cairo',
                ),
                decoration: InputDecoration(
                  hintText: l10n.cancellationReason,
                  hintStyle: const TextStyle(
                    color: ColorsCustom.textHint,
                    fontSize: 13,
                    fontFamily: 'Cairo',
                  ),
                  filled: true,
                  fillColor: ColorsCustom.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ButtonCustom.secondary(
                      text: l10n.back,
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ButtonCustom.primary(
                      text: l10n.confirm,
                      onPressed: () {
                        Navigator.pop(ctx);
                        context.read<OrdersBloc>().add(
                          OrderCancelRequested(
                            orderId: order.id,
                            reason: reasonController.text.isNotEmpty
                                ? reasonController.text
                                : l10n.cancelledByUser,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Helpers ──

  Map<String, dynamic> _getStatusInfo(String status, AppLocalizations l10n) {
    switch (status) {
      case 'draft':
        return {
          'label': l10n.statusDraft,
          'color': ColorsCustom.textSecondary,
          'image': 'assets/icons/status_pending.png',
        };
      case 'placed':
        return {
          'label': l10n.statusPlaced,
          'color': ColorsCustom.secondaryDark,
          'image': 'assets/icons/status_confirmed.png',
        };
      case 'preparing':
        return {
          'label': l10n.statusPreparing,
          'color': Colors.blue,
          'image': 'assets/icons/status_preparing.png',
        };
      case 'picked':
        return {
          'label': l10n.statusPicked,
          'color': ColorsCustom.primary,
          'image': 'assets/icons/status_ready.png',
        };
      case 'delivered':
        return {
          'label': l10n.statusDelivered,
          'color': ColorsCustom.success,
          'image': 'assets/icons/status_delivering.png',
        };
      case 'cancelled':
        return {
          'label': l10n.statusCancelled,
          'color': ColorsCustom.error,
          'image': 'assets/icons/status_cancelled.png',
        };
      default:
        return {
          'label': status,
          'color': ColorsCustom.textSecondary,
          'image': 'assets/icons/status_error.png',
        };
    }
  }

  String _formatDate(DateTime date, AppLocalizations l10n) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) {
      return l10n.minutesAgo(diff.inMinutes);
    } else if (diff.inHours < 24) {
      return l10n.hoursAgo(diff.inHours);
    } else if (diff.inDays == 1) {
      return l10n.yesterday;
    } else if (diff.inDays < 7) {
      return l10n.daysAgo(diff.inDays);
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }

  String _getShortOrderNumber(String orderNumber) {
    if (orderNumber.contains('-')) {
      final parts = orderNumber.split('-');
      if (parts.length >= 3) return '#${parts.last}';
    }
    return '#$orderNumber';
  }

  int _parseItemsCount(String itemsCount) {
    return int.tryParse(itemsCount) ?? 0;
  }
}
