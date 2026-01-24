import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:superdriver/domain/bloc/orders/orders_bloc.dart';
import 'package:superdriver/domain/models/order_model.dart';
import 'package:superdriver/l10n/app_localizations.dart';
import 'package:superdriver/presentation/components/text_custom.dart';
import 'package:superdriver/presentation/themes/colors_custom.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderDetailsScreen extends StatefulWidget {
  final Order order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  late Order _order;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    // Load fresh order details
    context.read<OrdersBloc>().add(
      OrderDetailsLoadRequested(orderId: widget.order.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<OrdersBloc, OrdersState>(
      listener: (context, state) {
        if (state is OrderDetailsLoaded) {
          setState(() => _order = state.order);
        } else if (state is OrderCancelled) {
          setState(() => _order = state.order);
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
        } else if (state is OrderCancelError) {
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
        }
      },
      child: Scaffold(
        backgroundColor: ColorsCustom.background,
        appBar: _buildAppBar(context, l10n),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Status Card
              _buildStatusCard(context, l10n),

              // Order Timeline
              if (_order.isActive) _buildTimeline(context, l10n),

              // Restaurant Info
              _buildSectionTitle(l10n.restaurantInfo),
              _buildRestaurantCard(context, l10n),

              // Driver Info (if available)
              if (_order.driverName != null && _order.isActive) ...[
                _buildSectionTitle(l10n.driverInfo),
                _buildDriverCard(context, l10n),
              ],

              // Order Items
              _buildSectionTitle(l10n.orderItems),
              _buildItemsList(context, l10n),

              // Order Summary
              _buildSectionTitle(l10n.orderSummary),
              _buildSummaryCard(context, l10n),

              // Notes
              if (_order.notes != null && _order.notes!.isNotEmpty) ...[
                _buildSectionTitle(l10n.orderNotes),
                _buildNotesCard(context, l10n),
              ],

              const SizedBox(height: 100),
            ],
          ),
        ),
        bottomNavigationBar: _order.canCancel && _order.isActive
            ? _buildBottomActions(context, l10n)
            : null,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: ColorsCustom.grey100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: ColorsCustom.textPrimary,
          ),
        ),
      ),
      title: Column(
        children: [
          TextCustom(
            text: l10n.orderDetails,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: ColorsCustom.textPrimary,
          ),
          TextCustom(
            text: _order.orderNumber,
            fontSize: 13,
            color: ColorsCustom.textSecondary,
          ),
        ],
      ),
      centerTitle: true,
    );
  }

  Widget _buildStatusCard(BuildContext context, AppLocalizations l10n) {
    final statusInfo = _getStatusInfo(_order.status, l10n);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            statusInfo['color'].withOpacity(0.15),
            statusInfo['color'].withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusInfo['color'].withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: statusInfo['color'].withOpacity(0.2),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              statusInfo['icon'],
              color: statusInfo['color'],
              size: 36,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextCustom(
                  text: statusInfo['label'],
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: statusInfo['color'],
                ),
                const SizedBox(height: 4),
                TextCustom(
                  text: _formatDateTime(_order.createdAt, l10n),
                  fontSize: 14,
                  color: ColorsCustom.textSecondary,
                ),
                if (_order.estimatedDeliveryTime != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 16,
                          color: ColorsCustom.primary,
                        ),
                        const SizedBox(width: 4),
                        TextCustom(
                          text:
                              'ETA: ${DateFormat('HH:mm').format(_order.estimatedDeliveryTime!)}',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: ColorsCustom.primary,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(BuildContext context, AppLocalizations l10n) {
    final steps = [
      {
        'status': 'pending',
        'label': l10n.statusPending,
        'icon': Icons.hourglass_empty,
      },
      {
        'status': 'accepted',
        'label': l10n.statusAccepted,
        'icon': Icons.check_circle_outline,
      },
      {
        'status': 'preparing',
        'label': l10n.statusPreparing,
        'icon': Icons.restaurant,
      },
      {'status': 'ready', 'label': l10n.statusReady, 'icon': Icons.inventory_2},
      {
        'status': 'picked',
        'label': l10n.statusPicked,
        'icon': Icons.delivery_dining,
      },
      {
        'status': 'delivered',
        'label': l10n.statusDelivered,
        'icon': Icons.check_circle,
      },
    ];

    final currentIndex = steps.indexWhere((s) => s['status'] == _order.status);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: ColorsCustom.cardShadow,
      ),
      child: Column(
        children: steps.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;
          final isCompleted = index <= currentIndex;
          final isCurrent = index == currentIndex;
          final isLast = index == steps.length - 1;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? ColorsCustom.primary
                          : ColorsCustom.grey200,
                      borderRadius: BorderRadius.circular(10),
                      border: isCurrent
                          ? Border.all(color: ColorsCustom.primary, width: 2)
                          : null,
                    ),
                    child: Icon(
                      step['icon'] as IconData,
                      size: 18,
                      color: isCompleted ? Colors.white : ColorsCustom.grey400,
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 30,
                      color: isCompleted
                          ? ColorsCustom.primary
                          : ColorsCustom.grey200,
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextCustom(
                        text: step['label'] as String,
                        fontSize: 15,
                        fontWeight: isCurrent
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: isCompleted
                            ? ColorsCustom.textPrimary
                            : ColorsCustom.textSecondary,
                      ),
                      if (isCurrent)
                        TextCustom(
                          text: l10n.today,
                          fontSize: 12,
                          color: ColorsCustom.primary,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: TextCustom(
        text: title,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: ColorsCustom.textPrimary,
      ),
    );
  }

  Widget _buildRestaurantCard(BuildContext context, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: ColorsCustom.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: ColorsCustom.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: _order.restaurantLogo != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      _order.restaurantLogo!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.restaurant_rounded,
                        color: ColorsCustom.primary,
                        size: 28,
                      ),
                    ),
                  )
                : Icon(
                    Icons.restaurant_rounded,
                    color: ColorsCustom.primary,
                    size: 28,
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: TextCustom(
              text: _order.restaurantName,
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: ColorsCustom.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverCard(BuildContext context, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: ColorsCustom.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.delivery_dining_rounded,
              color: Colors.blue.shade600,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextCustom(
                  text: _order.driverName ?? '',
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: ColorsCustom.textPrimary,
                ),
                if (_order.driverPhone != null)
                  TextCustom(
                    text: _order.driverPhone!,
                    fontSize: 14,
                    color: ColorsCustom.textSecondary,
                  ),
              ],
            ),
          ),
          if (_order.driverPhone != null)
            IconButton(
              onPressed: () => _callDriver(_order.driverPhone!),
              icon: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.phone_rounded, color: Colors.green.shade600),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildItemsList(BuildContext context, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: ColorsCustom.cardShadow,
      ),
      child: Column(
        children: _order.items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isLast = index == _order.items.length - 1;

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: !isLast
                  ? Border(bottom: BorderSide(color: ColorsCustom.grey200))
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    color: ColorsCustom.grey100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: item.productImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            item.productImage!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.fastfood_rounded,
                              color: ColorsCustom.grey400,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.fastfood_rounded,
                          color: ColorsCustom.grey400,
                        ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextCustom(
                        text: item.productName,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: ColorsCustom.textPrimary,
                      ),
                      if (item.variationName != null)
                        TextCustom(
                          text: item.variationName!,
                          fontSize: 13,
                          color: ColorsCustom.textSecondary,
                        ),
                      if (item.addons.isNotEmpty)
                        Wrap(
                          spacing: 4,
                          children: item.addons.map((addon) {
                            return Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: ColorsCustom.grey100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: TextCustom(
                                text: '+ ${addon.addonName}',
                                fontSize: 11,
                                color: ColorsCustom.textSecondary,
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TextCustom(
                      text:
                          '${item.totalPriceDouble.toStringAsFixed(2)} ${l10n.currency}',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: ColorsCustom.primary,
                    ),
                    TextCustom(
                      text: 'x${item.quantity}',
                      fontSize: 13,
                      color: ColorsCustom.textSecondary,
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: ColorsCustom.cardShadow,
      ),
      child: Column(
        children: [
          _buildSummaryRow(l10n.subtotal, _order.subtotalDouble, l10n),
          const SizedBox(height: 12),
          _buildSummaryRow(l10n.deliveryFee, _order.deliveryFeeDouble, l10n),
          if (_order.discountAmountDouble > 0) ...[
            const SizedBox(height: 12),
            _buildSummaryRow(
              l10n.discount,
              -_order.discountAmountDouble,
              l10n,
              isDiscount: true,
            ),
          ],
          const SizedBox(height: 16),
          Container(height: 1, color: ColorsCustom.grey200),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextCustom(
                text: l10n.total,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ColorsCustom.textPrimary,
              ),
              TextCustom(
                text:
                    '${_order.totalDouble.toStringAsFixed(2)} ${l10n.currency}',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: ColorsCustom.primary,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ColorsCustom.grey100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.payments_rounded,
                  color: ColorsCustom.textSecondary,
                  size: 22,
                ),
                const SizedBox(width: 10),
                TextCustom(
                  text: l10n.cashOnDelivery,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ColorsCustom.textPrimary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    double amount,
    AppLocalizations l10n, {
    bool isDiscount = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextCustom(
          text: label,
          fontSize: 15,
          color: ColorsCustom.textSecondary,
        ),
        TextCustom(
          text:
              '${isDiscount ? '-' : ''}${amount.abs().toStringAsFixed(2)} ${l10n.currency}',
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: isDiscount ? Colors.green.shade600 : ColorsCustom.textPrimary,
        ),
      ],
    );
  }

  Widget _buildNotesCard(BuildContext context, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: ColorsCustom.cardShadow,
      ),
      child: Row(
        children: [
          Icon(Icons.note_alt_outlined, color: ColorsCustom.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: TextCustom(
              text: _order.notes!,
              fontSize: 14,
              color: ColorsCustom.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 25,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: () => _showCancelDialog(context, l10n),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red.shade700,
              side: BorderSide(color: Colors.red.shade300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cancel_outlined, color: Colors.red.shade700),
                const SizedBox(width: 8),
                TextCustom(
                  text: l10n.cancelOrder,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade700,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context, AppLocalizations l10n) {
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
                  orderId: _order.id,
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

  void _callDriver(String phone) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
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

  String _formatDateTime(DateTime date, AppLocalizations l10n) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return '${l10n.today} - ${DateFormat('HH:mm').format(date)}';
    } else if (diff.inDays == 1) {
      return '${l10n.yesterday} - ${DateFormat('HH:mm').format(date)}';
    } else {
      return DateFormat('dd/MM/yyyy - HH:mm').format(date);
    }
  }
}
