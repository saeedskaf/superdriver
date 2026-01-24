import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:superdriver/domain/bloc/cart/cart_bloc.dart';
import 'package:superdriver/domain/models/cart_model.dart';
import 'package:superdriver/l10n/app_localizations.dart';
import 'package:superdriver/presentation/components/text_custom.dart';
import 'package:superdriver/presentation/screens/main/cart_detail_screen.dart';
import 'package:superdriver/presentation/themes/colors_custom.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    _loadAllCarts();
  }

  void _loadAllCarts() {
    context.read<CartBloc>().add(const CartLoadAllRequested());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: ColorsCustom.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, l10n),
            Expanded(
              child: BlocConsumer<CartBloc, CartState>(
                listener: (context, state) {
                  if (state is CartError) {
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
                  } else if (state is CartDeleted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.cartDeleted ?? 'تم حذف السلة'),
                        backgroundColor: Colors.green.shade700,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                    _loadAllCarts();
                  }
                },
                builder: (context, state) {
                  if (state is CartLoading) {
                    return _buildLoadingState();
                  }

                  if (state is CartAllLoaded) {
                    if (state.carts.isEmpty) {
                      return _buildEmptyCart(context, l10n);
                    }
                    return _buildCartsList(context, l10n, state.carts);
                  }

                  // Initial state or empty
                  return _buildEmptyCart(context, l10n);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextCustom(
                text: l10n.cart,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: ColorsCustom.textPrimary,
              ),
              const SizedBox(height: 4),
              BlocBuilder<CartBloc, CartState>(
                builder: (context, state) {
                  if (state is CartAllLoaded) {
                    final totalItems = state.carts.fold<int>(
                      0,
                      (sum, cart) => sum + cart.itemsCount,
                    );
                    return TextCustom(
                      text: '$totalItems ${l10n.items}',
                      fontSize: 14,
                      color: ColorsCustom.textSecondary,
                    );
                  }
                  return TextCustom(
                    text: '0 ${l10n.items}',
                    fontSize: 14,
                    color: ColorsCustom.textSecondary,
                  );
                },
              ),
            ],
          ),
          IconButton(
            onPressed: _loadAllCarts,
            icon: Icon(
              Icons.refresh_rounded,
              color: ColorsCustom.primary,
              size: 26,
            ),
          ),
        ],
      ),
    );
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

  Widget _buildEmptyCart(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: SingleChildScrollView(
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
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          ColorsCustom.primary.withOpacity(0.1),
                          ColorsCustom.primary.withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.shopping_cart_outlined,
                      size: 70,
                      color: ColorsCustom.primary.withOpacity(0.6),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            TextCustom(
              text: l10n.emptyCart,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: ColorsCustom.textPrimary,
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: TextCustom(
                text: l10n.emptyCartMessage,
                fontSize: 15,
                color: ColorsCustom.textSecondary,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 40),
            _buildBrowseButton(context, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildBrowseButton(BuildContext context, AppLocalizations l10n) {
    return Container(
      height: 56,
      margin: const EdgeInsets.symmetric(horizontal: 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorsCustom.primary,
            ColorsCustom.primary.withOpacity(0.85),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ColorsCustom.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Navigate to restaurants/home
            Navigator.pop(context);
          },
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.restaurant_menu_rounded,
                  color: Colors.white,
                  size: 22,
                ),
                const SizedBox(width: 10),
                TextCustom(
                  text: l10n.browseRestaurants,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCartsList(
    BuildContext context,
    AppLocalizations l10n,
    List<CartSummary> carts,
  ) {
    return RefreshIndicator(
      onRefresh: () async => _loadAllCarts(),
      color: ColorsCustom.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: carts.length,
        itemBuilder: (context, index) {
          final cartSummary = carts[index];
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: Duration(milliseconds: 300 + (index * 100)),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildCartSummaryCard(context, l10n, cartSummary),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCartSummaryCard(
    BuildContext context,
    AppLocalizations l10n,
    CartSummary cartSummary,
  ) {
    final isExpired =
        cartSummary.expiresAt != null &&
        DateTime.now().isAfter(cartSummary.expiresAt!);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isExpired
            ? Border.all(color: Colors.red.shade200, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isExpired
              ? null
              : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<CartBloc>(),
                        child: CartDetailScreen(
                          cartId: cartSummary.id,
                          restaurantId: cartSummary.restaurantId,
                        ),
                      ),
                    ),
                  ).then((_) => _loadAllCarts());
                },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Restaurant Header
                Row(
                  children: [
                    // Restaurant Logo
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: ColorsCustom.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: cartSummary.restaurantLogo != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.network(
                                cartSummary.restaurantLogo!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.restaurant,
                                  color: ColorsCustom.primary,
                                  size: 30,
                                ),
                              ),
                            )
                          : Icon(
                              Icons.restaurant,
                              color: ColorsCustom.primary,
                              size: 30,
                            ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextCustom(
                            text: cartSummary.restaurantName,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: ColorsCustom.textPrimary,
                          ),
                          const SizedBox(height: 4),
                          TextCustom(
                            text: '${cartSummary.itemsCount} ${l10n.items}',
                            fontSize: 14,
                            color: ColorsCustom.textSecondary,
                          ),
                        ],
                      ),
                    ),
                    // Delete Button
                    IconButton(
                      onPressed: () =>
                          _showDeleteCartDialog(context, l10n, cartSummary),
                      icon: Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.red.shade400,
                        size: 24,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Items Preview
                if (cartSummary.itemsPreview.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ColorsCustom.grey100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextCustom(
                          text: l10n.items,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: ColorsCustom.textSecondary,
                        ),
                        const SizedBox(height: 6),
                        ...cartSummary.itemsPreview
                            .take(3)
                            .map(
                              (item) => Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: TextCustom(
                                  text: '• $item',
                                  fontSize: 13,
                                  color: ColorsCustom.textPrimary,
                                  maxLines: 1,
                                ),
                              ),
                            ),
                        if (cartSummary.itemsPreview.length > 3)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: TextCustom(
                              text:
                                  '+${cartSummary.itemsPreview.length - 3} ${l10n.more ?? "المزيد"}',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: ColorsCustom.primary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Expiration Warning
                if (isExpired) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_rounded,
                          color: Colors.red.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextCustom(
                            text: l10n.cartExpired ?? 'انتهت صلاحية السلة',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ] else if (cartSummary.timeRemainingSeconds != null &&
                    cartSummary.timeRemainingSeconds! < 600) ...[
                  // Less than 10 minutes remaining
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.timer_rounded,
                          color: Colors.orange.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextCustom(
                            text:
                                '${_formatTimeRemaining(cartSummary.timeRemainingSeconds!)} ${l10n.remaining ?? "متبقي"}',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Total and Action
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextCustom(
                          text: l10n.total,
                          fontSize: 13,
                          color: ColorsCustom.textSecondary,
                        ),
                        const SizedBox(height: 2),
                        TextCustom(
                          text:
                              '${cartSummary.totalDouble.toStringAsFixed(2)} ${l10n.currency}',
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: ColorsCustom.primary,
                        ),
                      ],
                    ),
                    if (!isExpired)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              ColorsCustom.primary,
                              ColorsCustom.primary.withOpacity(0.85),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextCustom(
                              text: l10n.viewCart ?? 'عرض السلة',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTimeRemaining(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    if (minutes > 0) {
      return '$minutes د ${remainingSeconds} ث';
    }
    return '$remainingSeconds ث';
  }

  void _showDeleteCartDialog(
    BuildContext context,
    AppLocalizations l10n,
    CartSummary cartSummary,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: TextCustom(
          text: l10n.deleteCart ?? 'حذف السلة',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: ColorsCustom.textPrimary,
        ),
        content: TextCustom(
          text:
              l10n.deleteCartConfirmation ??
              'هل أنت متأكد من حذف سلة ${cartSummary.restaurantName}؟',
          fontSize: 15,
          color: ColorsCustom.textSecondary,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: TextCustom(
              text: l10n.cancel,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: ColorsCustom.textSecondary,
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<CartBloc>().add(
                CartDeleteRequested(cartId: cartSummary.id),
              );
            },
            child: TextCustom(
              text: l10n.delete ?? 'حذف',
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
