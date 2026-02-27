import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:superdriver/domain/bloc/orders/orders_bloc.dart';
import 'package:superdriver/domain/bloc/review/review_bloc.dart';
import 'package:superdriver/domain/models/order_model.dart';
import 'package:superdriver/l10n/app_localizations.dart';
import 'package:superdriver/presentation/components/text_custom.dart';
import 'package:superdriver/presentation/components/btn_custom.dart';
import 'package:superdriver/presentation/screens/main/driver_review_screen.dart';
import 'package:superdriver/presentation/themes/colors_custom.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderDetailsScreen extends StatefulWidget {
  final int orderId;

  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  Order? _order;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isCancelling = false;

  static const List<String> _statusFlow = [
    'placed',
    'preparing',
    'picked',
    'delivered',
  ];

  @override
  void initState() {
    super.initState();
    _loadOrderDetails();
  }

  void _loadOrderDetails() {
    context.read<OrdersBloc>().add(
      OrderDetailsLoadRequested(orderId: widget.orderId),
    );
  }

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

  bool _shouldShowCancelButton() {
    if (_order == null) return false;
    return _order!.canBeCancelled;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<OrdersBloc, OrdersState>(
      listenWhen: (prev, curr) {
        if (prev == curr) return false;
        return curr is OrderDetailsLoaded ||
            curr is OrderDetailsLoading ||
            curr is OrderDetailsError ||
            curr is OrderCancelled ||
            curr is OrderCancelling ||
            curr is OrderCancelError;
      },
      listener: (context, state) {
        if (state is OrderDetailsLoaded) {
          setState(() {
            _order = state.order;
            _isLoading = false;
            _errorMessage = null;
          });
        } else if (state is OrderDetailsLoading) {
          setState(() => _isLoading = true);
        } else if (state is OrderDetailsError) {
          setState(() {
            _isLoading = false;
            _errorMessage = state.message;
          });
        } else if (state is OrderCancelling) {
          setState(() => _isCancelling = true);
        } else if (state is OrderCancelled) {
          setState(() {
            _order = state.order;
            _isCancelling = false;
          });
        } else if (state is OrderCancelError) {
          setState(() => _isCancelling = false);
          _showSnackBar(context, state.message, isError: true);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: ColorsCustom.background,
          appBar: _buildAppBar(l10n),
          body: _buildBody(l10n),
          bottomNavigationBar: _shouldShowCancelButton()
              ? _buildBottomCancel(l10n)
              : null,
        );
      },
    );
  }

  // ── AppBar ──

  PreferredSizeWidget _buildAppBar(AppLocalizations l10n) {
    return AppBar(
      backgroundColor: ColorsCustom.surface,
      elevation: 0,
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
        text: l10n.orderDetails,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: ColorsCustom.textPrimary,
      ),
      centerTitle: true,
      actions: [
        if (_order != null)
          IconButton(
            onPressed: _loadOrderDetails,
            icon: const Icon(
              Icons.refresh_rounded,
              color: ColorsCustom.primary,
            ),
          ),
      ],
    );
  }

  // ── Body ──

  Widget _buildBody(AppLocalizations l10n) {
    if (_isLoading) return _buildLoadingState();
    if (_errorMessage != null) return _buildErrorState(l10n);
    if (_order == null) return _buildEmptyState(l10n);
    return _buildOrderDetails(l10n);
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(ColorsCustom.primary),
      ),
    );
  }

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
              onPressed: _loadOrderDetails,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
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
              Icons.receipt_long_outlined,
              size: 48,
              color: ColorsCustom.primary.withAlpha(153),
            ),
          ),
          const SizedBox(height: 16),
          TextCustom(
            text: l10n.orderNotFound,
            fontSize: 16,
            color: ColorsCustom.textSecondary,
          ),
        ],
      ),
    );
  }

  // ── Order Details ──

  Widget _buildOrderDetails(AppLocalizations l10n) {
    return RefreshIndicator(
      onRefresh: () async => _loadOrderDetails(),
      color: ColorsCustom.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderNumberCard(l10n),
            if (_order!.isScheduled && _order!.scheduledDeliveryTime != null)
              _buildScheduledDeliveryCard(l10n),
            _buildStatusCard(l10n),
            if (_order!.isActive && !_order!.isCancelled) _buildTimeline(l10n),

            // ── Rate / review (server controls via canReview) ──
            if (_order!.canReview && !_order!.isDriverRated)
              _buildRateDriverCard(l10n),

            _buildSectionTitle(l10n.restaurantInfo),
            _buildRestaurantCard(),
            if (_order!.driverName != null && _order!.isActive) ...[
              _buildSectionTitle(l10n.driverInfo),
              _buildDriverCard(l10n),
            ],
            _buildSectionTitle(l10n.deliveryAddress),
            _buildAddressCard(l10n),
            if (_order!.contactPhone != null &&
                _order!.contactPhone!.isNotEmpty) ...[
              _buildSectionTitle(l10n.contactNumber),
              _buildContactPhoneCard(),
            ],
            _buildSectionTitle(l10n.orderItems),
            _buildItemsList(l10n),
            _buildSectionTitle(l10n.orderSummary),
            _buildSummaryCard(l10n),
            if (_order!.notes != null && _order!.notes!.isNotEmpty) ...[
              _buildSectionTitle(l10n.orderNotes),
              _buildNotesCard(),
            ],
            if (_order!.isCancelled &&
                _order!.cancellationReason != null &&
                _order!.cancellationReason!.isNotEmpty) ...[
              _buildSectionTitle(l10n.cancellationReasonTitle),
              _buildCancellationCard(),
            ],
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  // ── Section Title ──

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: TextCustom(
        text: title,
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: ColorsCustom.textPrimary,
      ),
    );
  }

  // ── Order Number Card ──

  Widget _buildOrderNumberCard(AppLocalizations l10n) {
    return _CardWrapper(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: ColorsCustom.primarySoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.tag_rounded,
              color: ColorsCustom.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextCustom(
                  text: l10n.orderNumber,
                  fontSize: 12,
                  color: ColorsCustom.textSecondary,
                ),
                const SizedBox(height: 2),
                TextCustom(
                  text: _order!.orderNumber,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: ColorsCustom.textPrimary,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _copyOrderNumber(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: ColorsCustom.primarySoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.copy_rounded,
                    size: 16,
                    color: ColorsCustom.primary,
                  ),
                  const SizedBox(width: 4),
                  TextCustom(
                    text: l10n.copy,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: ColorsCustom.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _copyOrderNumber(BuildContext context) {
    Clipboard.setData(ClipboardData(text: _order!.orderNumber));
    _showSnackBar(context, 'تم نسخ رقم الطلب', isError: false);
  }

  // ── Scheduled Delivery ──

  Widget _buildScheduledDeliveryCard(AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withAlpha(15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withAlpha(77)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.blue.withAlpha(26),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.schedule_rounded,
              color: Colors.blue,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextCustom(
                  text: l10n.scheduledDelivery,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
                const SizedBox(height: 2),
                TextCustom(
                  text: _formatScheduledTime(
                    _order!.scheduledDeliveryTime!,
                    l10n,
                  ),
                  fontSize: 13,
                  color: Colors.blue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatScheduledTime(DateTime dateTime, AppLocalizations l10n) {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final scheduledDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final locale = Localizations.localeOf(context).languageCode;

    String dayPart;
    if (scheduledDate == DateTime(now.year, now.month, now.day)) {
      dayPart = l10n.today;
    } else if (scheduledDate == tomorrow) {
      dayPart = l10n.tomorrow;
    } else {
      dayPart = DateFormat('EEEE، d MMMM', locale).format(dateTime);
    }

    final timePart = DateFormat('HH:mm').format(dateTime);
    return '$dayPart ${l10n.atTime} $timePart';
  }

  // ── Status Card ──

  Widget _buildStatusCard(AppLocalizations l10n) {
    final statusInfo = _getStatusInfo(_order!.status, l10n);
    final Color color = statusInfo['color'];

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(51)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withAlpha(36),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Image.asset(
                statusInfo['image'],
                fit: BoxFit.contain,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextCustom(
                  text: statusInfo['label'],
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                const SizedBox(height: 4),
                TextCustom(
                  text: _formatDateTime(_order!.createdAt, l10n),
                  fontSize: 13,
                  color: ColorsCustom.textSecondary,
                ),
                if (_order!.estimatedDeliveryTime != null &&
                    _order!.isActive) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: ColorsCustom.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.schedule_rounded,
                          size: 14,
                          color: ColorsCustom.primary,
                        ),
                        const SizedBox(width: 4),
                        TextCustom(
                          text:
                              '${l10n.estimatedArrival}: ${DateFormat('HH:mm').format(_order!.estimatedDeliveryTime!)}',
                          fontSize: 11,
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

  // ── Rate Driver Card ──

  Widget _buildRateDriverCard(AppLocalizations l10n) {
    return _CardWrapper(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: ColorsCustom.warningBg,
      borderColor: ColorsCustom.warning.withAlpha(77),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: ColorsCustom.warning.withAlpha(36),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.star_rounded,
              color: ColorsCustom.warning,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextCustom(
                  text: l10n.rateDriver,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: ColorsCustom.textPrimary,
                ),
                const SizedBox(height: 2),
                TextCustom(
                  text: l10n.rateYourExperience,
                  fontSize: 12,
                  color: ColorsCustom.textSecondary,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _navigateToDriverReview,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: ColorsCustom.warning,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextCustom(
                text: l10n.rate,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: ColorsCustom.textOnPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToDriverReview() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => ReviewBloc(),
          child: DriverReviewScreen(
            orderId: _order!.id,
            driverName: _order!.driverName,
          ),
        ),
      ),
    ).then((_) {
      if (mounted) _loadOrderDetails();
    });
  }

  // ── Timeline ──

  Widget _buildTimeline(AppLocalizations l10n) {
    final currentStatusIndex = _statusFlow.indexOf(_order!.status);

    final steps = [
      {
        'status': 'placed',
        'label': l10n.statusPlaced,
        'image': 'assets/icons/status_confirmed.png',
      },
      {
        'status': 'preparing',
        'label': l10n.statusPreparing,
        'image': 'assets/icons/status_preparing.png',
      },
      {
        'status': 'picked',
        'label': l10n.statusPicked,
        'image': 'assets/icons/status_ready.png',
      },
      {
        'status': 'delivered',
        'label': l10n.statusDelivered,
        'image': 'assets/icons/status_delivering.png',
      },
    ];

    return _CardWrapper(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextCustom(
            text: l10n.trackOrder,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: ColorsCustom.textPrimary,
          ),
          const SizedBox(height: 20),
          ...steps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            final stepIdx = _statusFlow.indexOf(step['status'] as String);
            final isCompleted = currentStatusIndex >= stepIdx;
            final isCurrent = _order!.status == step['status'];
            final isLast = index == steps.length - 1;

            return _TimelineStep(
              image: step['image'] as String,
              label: step['label'] as String,
              isCompleted: isCompleted,
              isCurrent: isCurrent,
              isLast: isLast,
              currentStatusText: l10n.currentStatus,
            );
          }),
        ],
      ),
    );
  }

  // ── Restaurant Card ──

  Widget _buildRestaurantCard() {
    return _CardWrapper(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: ColorsCustom.primarySoft,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ColorsCustom.border),
            ),
            child: _order!.restaurantLogo != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: Image.network(
                      _order!.restaurantLogo!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.restaurant_rounded,
                        color: ColorsCustom.primary,
                        size: 24,
                      ),
                    ),
                  )
                : const Icon(
                    Icons.restaurant_rounded,
                    color: ColorsCustom.primary,
                    size: 24,
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: TextCustom(
              text: _order!.restaurantName,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ColorsCustom.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Driver Card ──

  Widget _buildDriverCard(AppLocalizations l10n) {
    return _CardWrapper(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: ColorsCustom.primarySoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.asset('assets/icons/driver_illustration.png', fit: BoxFit.contain),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextCustom(
                  text: '${l10n.driver} ${_order!.driverName ?? ''}',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ColorsCustom.textPrimary,
                ),
                if (_order!.driverPhone != null)
                  TextCustom(
                    text: _order!.driverPhone!,
                    fontSize: 13,
                    color: ColorsCustom.textSecondary,
                  ),
              ],
            ),
          ),
          if (_order!.driverPhone != null)
            GestureDetector(
              onTap: () => _callPhone(_order!.driverPhone!),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withAlpha(26),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.phone_rounded,
                  color: Colors.blue,
                  size: 20,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Address Card ──

  Widget _buildAddressCard(AppLocalizations l10n) {
    final address = _order!.addressSnapshot;

    if (address == null) {
      return _CardWrapper(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: ColorsCustom.primarySoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.location_on_rounded,
                color: ColorsCustom.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: TextCustom(
                text: l10n.addressNotAvailable,
                fontSize: 14,
                color: ColorsCustom.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return _CardWrapper(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: ColorsCustom.primarySoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: ColorsCustom.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: TextCustom(
                  text: address.title,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ColorsCustom.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ColorsCustom.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _AddressRow(
                  icon: Icons.map_outlined,
                  label: l10n.areaLabel,
                  value: '${address.governorate}، ${address.area}',
                ),
                if (address.street.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _AddressRow(
                    icon: Icons.signpost_outlined,
                    label: l10n.streetLabel,
                    value: address.street,
                  ),
                ],
                if (address.buildingDetails != null) ...[
                  const SizedBox(height: 10),
                  _AddressRow(
                    icon: Icons.apartment_rounded,
                    label: l10n.buildingDetailsLabel,
                    value: address.buildingDetails!,
                  ),
                ],
                if (address.landmark != null &&
                    address.landmark!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _AddressRow(
                    icon: Icons.place_outlined,
                    label: l10n.landmarkLabel,
                    value: address.landmark!,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Contact Phone ──

  Widget _buildContactPhoneCard() {
    return _CardWrapper(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.blue.withAlpha(26),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.phone_rounded,
              color: Colors.blue,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: TextCustom(
              text: _order!.contactPhone ?? '',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: ColorsCustom.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Items List ──

  Widget _buildItemsList(AppLocalizations l10n) {
    if (_order!.items.isEmpty) {
      return _CardWrapper(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Center(
          child: TextCustom(
            text: l10n.noItems,
            fontSize: 14,
            color: ColorsCustom.textSecondary,
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: ColorsCustom.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorsCustom.border),
      ),
      child: Column(
        children: _order!.items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isLast = index == _order!.items.length - 1;

          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              border: !isLast
                  ? const Border(bottom: BorderSide(color: ColorsCustom.border))
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: ColorsCustom.primarySoft,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: ColorsCustom.border),
                  ),
                  child: item.productImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(9),
                          child: Image.network(
                            item.productImage!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.fastfood_rounded,
                              color: ColorsCustom.primary,
                              size: 20,
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.fastfood_rounded,
                          color: ColorsCustom.primary,
                          size: 20,
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextCustom(
                        text: item.productName,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: ColorsCustom.textPrimary,
                      ),
                      if (item.variationName != null)
                        TextCustom(
                          text: item.variationName!,
                          fontSize: 12,
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
                                color: ColorsCustom.background,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: TextCustom(
                                text: '+ ${addon.addonName}',
                                fontSize: 10,
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
                          '${item.totalPriceDouble.toStringAsFixed(0)} ${l10n.currency}',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: ColorsCustom.primary,
                    ),
                    TextCustom(
                      text: 'x${item.quantity}',
                      fontSize: 12,
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

  // ── Summary Card ──

  Widget _buildSummaryCard(AppLocalizations l10n) {
    return _CardWrapper(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _SummaryRow(label: l10n.subtotal, amount: _order!.subtotalDouble),
          const SizedBox(height: 10),
          _SummaryRow(
            label: l10n.deliveryFee,
            amount: _order!.deliveryFeeDouble,
          ),
          if (_order!.discountAmountDouble > 0) ...[
            const SizedBox(height: 10),
            _SummaryRow(
              label: l10n.discount,
              amount: -_order!.discountAmountDouble,
              isDiscount: true,
            ),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(color: ColorsCustom.border, height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextCustom(
                text: l10n.total,
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: ColorsCustom.textPrimary,
              ),
              TextCustom(
                text:
                    '${_order!.totalDouble.toStringAsFixed(0)} ${l10n.currency}',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: ColorsCustom.primary,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ColorsCustom.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.payments_rounded,
                  color: Colors.green.shade700,
                  size: 20,
                ),
                const SizedBox(width: 10),
                TextCustom(
                  text:
                      (_order!.paymentMethodDisplay.isEmpty ||
                          _order!.paymentMethodDisplay == 'نقدي')
                      ? l10n.cashOnDelivery
                      : _order!.paymentMethodDisplay,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade700,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Notes Card ──

  Widget _buildNotesCard() {
    return _CardWrapper(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Icon(
            Icons.note_alt_outlined,
            color: ColorsCustom.textSecondary,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextCustom(
              text: _order!.notes!,
              fontSize: 14,
              color: ColorsCustom.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Cancellation Card ──

  Widget _buildCancellationCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorsCustom.errorBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorsCustom.error.withAlpha(77)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.cancel_outlined,
            color: ColorsCustom.error,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextCustom(
              text: _order!.cancellationReason!,
              fontSize: 14,
              color: ColorsCustom.error,
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom Cancel ──

  Widget _buildBottomCancel(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: ColorsCustom.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: GestureDetector(
          onTap: _isCancelling ? null : () => _showCancelDialog(context, l10n),
          child: Container(
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              color: ColorsCustom.errorBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: ColorsCustom.error.withAlpha(77)),
            ),
            child: Center(
              child: _isCancelling
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          ColorsCustom.error,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.cancel_outlined,
                          color: ColorsCustom.error,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        TextCustom(
                          text: l10n.cancelOrder,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: ColorsCustom.error,
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Cancel Dialog ──

  void _showCancelDialog(BuildContext context, AppLocalizations l10n) {
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
                            orderId: _order!.id,
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

  void _callPhone(String phone) async {
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
          'color': ColorsCustom.textSecondary,
          'image': 'assets/icons/status_pending.png',
        };
      case 'placed':
        return {
          'label': l10n.statusPlaced,
          'color': ColorsCustom.warning,
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

  String _formatDateTime(DateTime date, AppLocalizations l10n) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0)
      return '${l10n.today} - ${DateFormat('HH:mm').format(date)}';
    if (diff.inDays == 1)
      return '${l10n.yesterday} - ${DateFormat('HH:mm').format(date)}';
    return DateFormat('dd/MM/yyyy - HH:mm').format(date);
  }
}

// ============================================
// SHARED WIDGETS
// ============================================

class _CardWrapper extends StatelessWidget {
  final Widget child;
  final EdgeInsets? margin;
  final Color? color;
  final Color? borderColor;

  const _CardWrapper({
    required this.child,
    this.margin,
    this.color,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color ?? ColorsCustom.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor ?? ColorsCustom.border),
      ),
      child: child,
    );
  }
}

class _TimelineStep extends StatelessWidget {
  final String image;
  final String label;
  final bool isCompleted;
  final bool isCurrent;
  final bool isLast;
  final String? currentStatusText;

  const _TimelineStep({
    required this.image,
    required this.label,
    required this.isCompleted,
    required this.isCurrent,
    required this.isLast,
    this.currentStatusText,
  });

  @override
  Widget build(BuildContext context) {
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
                    : ColorsCustom.background,
                borderRadius: BorderRadius.circular(10),
                border: isCurrent
                    ? Border.all(color: ColorsCustom.primary, width: 2)
                    : Border.all(color: ColorsCustom.border),
              ),
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: Image.asset(
                  image,
                  fit: BoxFit.contain,
                  color: isCompleted
                      ? ColorsCustom.textOnPrimary
                      : ColorsCustom.textHint,
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 30,
                margin: const EdgeInsets.symmetric(vertical: 4),
                color: isCompleted ? ColorsCustom.primary : ColorsCustom.border,
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextCustom(
                  text: label,
                  fontSize: 14,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                  color: isCompleted
                      ? ColorsCustom.textPrimary
                      : ColorsCustom.textSecondary,
                ),
                if (isCurrent && currentStatusText != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: TextCustom(
                      text: currentStatusText!,
                      fontSize: 11,
                      color: ColorsCustom.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AddressRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _AddressRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: ColorsCustom.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextCustom(
                text: label,
                fontSize: 11,
                color: ColorsCustom.textSecondary,
              ),
              TextCustom(
                text: value,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: ColorsCustom.textPrimary,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double amount;
  final bool isDiscount;

  const _SummaryRow({
    required this.label,
    required this.amount,
    this.isDiscount = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextCustom(
          text: label,
          fontSize: 14,
          color: ColorsCustom.textSecondary,
        ),
        TextCustom(
          text:
              '${isDiscount ? '-' : ''}${amount.abs().toStringAsFixed(0)} ${l10n.currency}',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isDiscount ? ColorsCustom.success : ColorsCustom.textPrimary,
        ),
      ],
    );
  }
}
