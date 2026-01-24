import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:superdriver/domain/bloc/cart/cart_bloc.dart';
import 'package:superdriver/domain/models/cart_model.dart';
import 'package:superdriver/l10n/app_localizations.dart';
import 'package:superdriver/presentation/components/text_custom.dart';
import 'package:superdriver/presentation/screens/main/checkout_screen.dart';
import 'package:superdriver/presentation/themes/colors_custom.dart';

class CartDetailScreen extends StatefulWidget {
  final int cartId;
  final int restaurantId;

  const CartDetailScreen({
    super.key,
    required this.cartId,
    required this.restaurantId,
  });

  @override
  State<CartDetailScreen> createState() => _CartDetailScreenState();
}

class _CartDetailScreenState extends State<CartDetailScreen> {
  final TextEditingController _couponController = TextEditingController();
  bool _showCouponField = false;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  void _loadCart() {
    context.read<CartBloc>().add(CartLoadRequested(cartId: widget.cartId));
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: ColorsCustom.background,
      appBar: _buildAppBar(context, l10n),
      body: BlocConsumer<CartBloc, CartState>(
        listener: (context, state) {
          if (state is CartError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red.shade700,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is CartOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green.shade700,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is CartCouponApplied) {
            setState(() => _showCouponField = false);
            _couponController.clear();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.couponApplied),
                backgroundColor: Colors.green.shade700,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is CartCleared) {
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          if (state is CartLoading) {
            return _buildLoadingState();
          }

          final cart = _getCartFromState(state);
          if (cart == null || cart.isEmpty) {
            return _buildEmptyCart(context, l10n);
          }

          return Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async => _loadCart(),
                  color: ColorsCustom.primary,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (cart.restaurant != null)
                        _buildRestaurantInfo(cart.restaurant!),
                      const SizedBox(height: 16),
                      ...cart.items.asMap().entries.map((entry) {
                        final item = entry.value;
                        final isUpdating =
                            state is CartItemUpdating &&
                            state.updatingItemId == item.id;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildCartItem(
                            context,
                            l10n,
                            item,
                            isUpdating,
                          ),
                        );
                      }),
                      const SizedBox(height: 8),
                      _buildCouponSection(context, l10n, cart),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
              _buildCheckoutSection(context, l10n, cart),
            ],
          );
        },
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
        icon: Icon(Icons.arrow_back, color: ColorsCustom.textPrimary),
      ),
      title: TextCustom(
        text: l10n.cartDetails,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: ColorsCustom.textPrimary,
      ),
      actions: [
        IconButton(
          onPressed: () => _showClearCartDialog(context, l10n),
          icon: Icon(Icons.delete_outline_rounded, color: Colors.red.shade600),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(ColorsCustom.primary),
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: ColorsCustom.grey300,
          ),
          const SizedBox(height: 16),
          TextCustom(
            text: l10n.emptyCart,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: ColorsCustom.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantInfo(CartRestaurant restaurant) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorsCustom.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: ColorsCustom.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: restaurant.logo != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      restaurant.logo!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Icon(Icons.restaurant, color: ColorsCustom.primary),
                    ),
                  )
                : Icon(Icons.restaurant, color: ColorsCustom.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: TextCustom(
              text: restaurant.name,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ColorsCustom.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(
    BuildContext context,
    AppLocalizations l10n,
    CartItem item,
    bool isUpdating,
  ) {
    return Dismissible(
      key: Key('cart_item_${item.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: Colors.red.shade500,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 28),
      ),
      onDismissed: (_) {
        context.read<CartBloc>().add(CartRemoveItemRequested(itemId: item.id));
      },
      child: Container(
        padding: const EdgeInsets.all(16),
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
        child: Stack(
          children: [
            Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: ColorsCustom.grey100,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: item.product.image != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.network(
                            item.product.image!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.fastfood_rounded,
                              size: 36,
                              color: ColorsCustom.grey400,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.fastfood_rounded,
                          size: 36,
                          color: ColorsCustom.grey400,
                        ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextCustom(
                        text: item.product.name,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: ColorsCustom.textPrimary,
                        maxLines: 2,
                      ),
                      if (item.variation != null) ...[
                        const SizedBox(height: 4),
                        TextCustom(
                          text: item.variation!.name,
                          fontSize: 12,
                          color: ColorsCustom.textSecondary,
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextCustom(
                            text:
                                '${item.totalPriceDouble.toStringAsFixed(2)} ${l10n.currency}',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: ColorsCustom.primary,
                          ),
                          _buildQuantityControls(context, item, isUpdating),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (isUpdating)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          ColorsCustom.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityControls(
    BuildContext context,
    CartItem item,
    bool isUpdating,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: ColorsCustom.grey100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildQuantityButton(
            icon: item.quantity == 1
                ? Icons.delete_outline_rounded
                : Icons.remove_rounded,
            onTap: isUpdating
                ? null
                : () {
                    if (item.quantity == 1) {
                      context.read<CartBloc>().add(
                        CartRemoveItemRequested(itemId: item.id),
                      );
                    } else {
                      context.read<CartBloc>().add(
                        CartUpdateItemRequested(
                          itemId: item.id,
                          quantity: item.quantity - 1,
                        ),
                      );
                    }
                  },
            isDelete: item.quantity == 1,
          ),
          Container(
            constraints: const BoxConstraints(minWidth: 36),
            alignment: Alignment.center,
            child: TextCustom(
              text: item.quantity.toString(),
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ColorsCustom.textPrimary,
            ),
          ),
          _buildQuantityButton(
            icon: Icons.add_rounded,
            onTap: isUpdating
                ? null
                : () {
                    context.read<CartBloc>().add(
                      CartUpdateItemRequested(
                        itemId: item.id,
                        quantity: item.quantity + 1,
                      ),
                    );
                  },
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    VoidCallback? onTap,
    bool isDelete = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isDelete
                ? Colors.red.shade50
                : ColorsCustom.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isDelete ? Colors.red.shade600 : ColorsCustom.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildCouponSection(
    BuildContext context,
    AppLocalizations l10n,
    Cart cart,
  ) {
    if (cart.hasCoupon) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.local_offer_rounded, color: Colors.green.shade700),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextCustom(
                    text: l10n.couponApplied,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                  TextCustom(
                    text: "cart.couponCode",
                    fontSize: 13,
                    color: Colors.green.shade600,
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                context.read<CartBloc>().add(
                  CartRemoveCouponRequested(cartId: cart.id),
                );
              },
              icon: Icon(Icons.close_rounded, color: Colors.green.shade700),
            ),
          ],
        ),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _showCouponField = !_showCouponField),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.local_offer_outlined, color: ColorsCustom.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextCustom(
                      text: l10n.addCoupon,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: ColorsCustom.textPrimary,
                    ),
                  ),
                  Icon(
                    _showCouponField
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: ColorsCustom.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          if (_showCouponField)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _couponController,
                      decoration: InputDecoration(
                        hintText: l10n.enterCouponCode,
                        filled: true,
                        fillColor: ColorsCustom.grey100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      if (_couponController.text.trim().isNotEmpty) {
                        context.read<CartBloc>().add(
                          CartApplyCouponRequested(
                            cartId: cart.id,
                            couponCode: _couponController.text.trim(),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorsCustom.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: TextCustom(
                      text: l10n.apply,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCheckoutSection(
    BuildContext context,
    AppLocalizations l10n,
    Cart cart,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPriceRow(l10n.subtotal, cart.subtotalDouble, l10n),
            const SizedBox(height: 10),
            _buildPriceRow(l10n.deliveryFee, cart.deliveryFeeDouble, l10n),
            if (cart.discountAmountDouble > 0) ...[
              const SizedBox(height: 10),
              _buildPriceRow(
                l10n.discount,
                -cart.discountAmountDouble,
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
                      '${cart.totalDouble.toStringAsFixed(2)} ${l10n.currency}',
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: ColorsCustom.primary,
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildCheckoutButton(context, l10n, cart),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(
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

  Widget _buildCheckoutButton(
    BuildContext context,
    AppLocalizations l10n,
    Cart cart,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<CartBloc>(),
                child: CheckoutScreen(cart: cart),
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorsCustom.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shopping_bag_rounded, color: Colors.white),
            const SizedBox(width: 10),
            TextCustom(
              text: l10n.checkout,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  void _showClearCartDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: TextCustom(
          text: l10n.clearCart,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: ColorsCustom.textPrimary,
        ),
        content: TextCustom(
          text: l10n.clearCartConfirmation,
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
                CartClearRequested(cartId: widget.cartId),
              );
            },
            child: TextCustom(
              text: l10n.clearAll,
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Cart? _getCartFromState(CartState state) {
    if (state is CartLoaded) return state.cart;
    if (state is CartOperationSuccess) return state.cart;
    if (state is CartCouponApplied) return state.cart;
    if (state is CartCouponRemoved) return state.cart;
    if (state is CartItemUpdating) return state.cart;
    if (state is CartValidated) return state.cart;
    if (state is CartValidationFailed) return state.cart;
    return null;
  }
}
