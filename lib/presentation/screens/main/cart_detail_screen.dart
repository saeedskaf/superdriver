import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:superdriver/domain/bloc/cart/cart_bloc.dart';
import 'package:superdriver/domain/bloc/auth/auth_bloc.dart';
import 'package:superdriver/domain/bloc/orders/orders_bloc.dart';
import 'package:superdriver/domain/bloc/profile/profile_bloc.dart';
import 'package:superdriver/domain/bloc/address/address_bloc.dart';
import 'package:superdriver/domain/models/cart_model.dart';
import 'package:superdriver/l10n/app_localizations.dart';
import 'package:superdriver/presentation/components/text_custom.dart';
import 'package:superdriver/presentation/components/btn_custom.dart';
import 'package:superdriver/presentation/screens/main/checkout_screen.dart';
import 'package:superdriver/presentation/screens/main/home/home_widgets.dart';
import 'package:superdriver/presentation/screens/auth/login_screen.dart';
import 'package:superdriver/presentation/themes/colors_custom.dart';

// ============================================
// CART DETAIL SCREEN
// ============================================

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
  final _couponController = TextEditingController();
  bool _showCouponField = false;

  /// Cache the last valid cart so transient error states (e.g. invalid coupon)
  /// don't wipe the UI.
  Cart? _lastCart;

  /// Track items dismissed via swipe so they vanish instantly from the list
  /// before the server round-trip completes.
  final Set<int> _dismissedItemIds = {};

  // ── AuthCheckStatus removed: caller (CartScreen) already guarantees auth,
  //    and the BlocBuilder below reacts to AuthBloc state changes anyway.

  @override
  void initState() {
    super.initState();
    _loadCartIfAuthenticated();
  }

  void _loadCartIfAuthenticated() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<CartBloc>().add(CartLoadRequested(cartId: widget.cartId));
    }
  }

  bool get _isAuthenticated {
    final authState = context.read<AuthBloc>().state;
    return authState is AuthAuthenticated;
  }

  bool _isArabic(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'ar';
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = _isArabic(context);

    return Scaffold(
      backgroundColor: ColorsCustom.background,
      appBar: _buildAppBar(l10n),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (!_isAuthenticated) {
            return _NotLoggedInView(onLogin: () => _navigateToLogin(context));
          }

          return BlocConsumer<CartBloc, CartState>(
            listenWhen: (prev, curr) => prev != curr,
            listener: _handleCartState,
            builder: (context, state) {
              if (state is CartLoading && _lastCart == null) {
                return const _LoadingView();
              }

              final freshCart = _getCartFromState(state);
              if (freshCart != null) {
                _lastCart = freshCart;
                _dismissedItemIds.clear();
              }
              final cart = freshCart ?? _lastCart;

              if (cart == null || cart.isEmpty) {
                return _EmptyCartView(onBack: () => Navigator.pop(context));
              }

              // All visible items dismissed — cart is effectively empty
              final visibleItems = cart.items
                  .where((i) => !_dismissedItemIds.contains(i.id))
                  .toList();
              if (visibleItems.isEmpty) {
                return _EmptyCartView(onBack: () => Navigator.pop(context));
              }

              return Column(
                children: [
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async => _loadCartIfAuthenticated(),
                      color: ColorsCustom.primary,
                      child: _buildCartContent(l10n, cart, state, isArabic),
                    ),
                  ),
                  _CheckoutSection(
                    cart: cart,
                    onCheckout: () => _navigateToCheckout(context, cart),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  void _handleCartState(BuildContext context, CartState state) {
    final l10n = AppLocalizations.of(context)!;

    if (state is CartError) {
      // Suppress "cart not found" errors when the cart is already empty
      // (happens after deleting the last item triggers an auto-reload).
      if (_lastCart == null || _lastCart!.isEmpty) return;
      _showSnackBar(context, state.message, isError: true);
    } else if (state is CartOperationSuccess) {
      _showSnackBar(context, state.message, isError: false);
    } else if (state is CartCouponApplied) {
      setState(() => _showCouponField = false);
      _couponController.clear();
      _showSnackBar(context, l10n.couponApplied, isError: false);
    } else if (state is CartCleared) {
      Navigator.pop(context);
    }
  }

  PreferredSizeWidget _buildAppBar(AppLocalizations l10n) {
    return AppBar(
      backgroundColor: ColorsCustom.surface,
      elevation: 0,
      leading: const _BackButton(),
      title: TextCustom(
        text: l10n.cartDetails,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: ColorsCustom.textPrimary,
      ),
      actions: [
        _ClearCartButton(onTap: () => _showClearCartDialog(context, l10n)),
      ],
    );
  }

  Widget _buildCartContent(
    AppLocalizations l10n,
    Cart cart,
    CartState state,
    bool isArabic,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (cart.restaurant != null)
          _RestaurantInfoCard(restaurant: cart.restaurant!, isArabic: isArabic),
        const SizedBox(height: 16),
        ...cart.items.where((item) => !_dismissedItemIds.contains(item.id)).map(
          (item) {
            final isUpdating =
                state is CartItemUpdating && state.updatingItemId == item.id;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _CartItemCard(
                item: item,
                isArabic: isArabic,
                isUpdating: isUpdating,
                onQuantityChanged: (qty) => _updateQuantity(item.id, qty),
                onRemove: () => _removeItem(item.id),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        _CouponSection(
          cart: cart,
          controller: _couponController,
          showField: _showCouponField,
          onToggle: () => setState(() => _showCouponField = !_showCouponField),
          onApply: () => _applyCoupon(cart.id),
          onRemove: () => _removeCoupon(cart.id),
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  void _updateQuantity(int itemId, int quantity) {
    if (quantity < 1) {
      _removeItem(itemId);
    } else {
      context.read<CartBloc>().add(
        CartUpdateItemRequested(itemId: itemId, quantity: quantity),
      );
    }
  }

  void _removeItem(int itemId) {
    setState(() => _dismissedItemIds.add(itemId));
    context.read<CartBloc>().add(CartRemoveItemRequested(itemId: itemId));
  }

  void _applyCoupon(int cartId) {
    final code = _couponController.text.trim();
    if (code.isNotEmpty) {
      context.read<CartBloc>().add(
        CartApplyCouponRequested(cartId: cartId, couponCode: code),
      );
    }
  }

  void _removeCoupon(int cartId) {
    context.read<CartBloc>().add(CartRemoveCouponRequested(cartId: cartId));
  }

  void _navigateToLogin(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _navigateToCheckout(BuildContext context, Cart cart) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<CartBloc>()),
            BlocProvider.value(value: context.read<AuthBloc>()),
            BlocProvider.value(value: context.read<OrdersBloc>()),
            BlocProvider.value(value: context.read<ProfileBloc>()),
            BlocProvider(create: (_) => AddressBloc()),
          ],
          child: CheckoutScreen(cart: cart),
        ),
      ),
    );
  }

  void _showClearCartDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => _ClearCartDialog(
        onCancel: () => Navigator.pop(ctx),
        onClear: () {
          Navigator.pop(ctx);
          context.read<CartBloc>().add(
            CartClearRequested(cartId: widget.cartId),
          );
        },
      ),
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

// ============================================
// APP BAR WIDGETS
// ============================================

class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
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
    );
  }
}

class _ClearCartButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ClearCartButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: ColorsCustom.errorBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.delete_outline_rounded,
            color: ColorsCustom.error,
            size: 22,
          ),
        ),
      ),
    );
  }
}

// ============================================
// NOT LOGGED IN VIEW
// ============================================

class _NotLoggedInView extends StatelessWidget {
  final VoidCallback onLogin;

  const _NotLoggedInView({required this.onLogin});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
                color: ColorsCustom.primarySoft,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.login_rounded,
                size: 48,
                color: ColorsCustom.primary.withAlpha(153),
              ),
            ),
            const SizedBox(height: 24),
            TextCustom(
              text: l10n.loginRequired,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: ColorsCustom.textPrimary,
            ),
            const SizedBox(height: 10),
            TextCustom(
              text: l10n.loginToViewCart,
              fontSize: 14,
              color: ColorsCustom.textSecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ButtonCustom.primary(text: l10n.login, onPressed: onLogin),
          ],
        ),
      ),
    );
  }
}

// ============================================
// EMPTY CART VIEW
// ============================================

class _EmptyCartView extends StatelessWidget {
  final VoidCallback onBack;

  const _EmptyCartView({required this.onBack});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
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
                Icons.shopping_cart_outlined,
                size: 48,
                color: ColorsCustom.primary.withAlpha(153),
              ),
            ),
            const SizedBox(height: 28),
            TextCustom(
              text: l10n.emptyCart,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: ColorsCustom.textPrimary,
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextCustom(
                text: l10n.emptyCartMessage,
                fontSize: 14,
                color: ColorsCustom.textSecondary,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            ButtonCustom.primary(
              text: l10n.browseRestaurants,
              onPressed: onBack,
              icon: const Icon(
                Icons.restaurant_menu_rounded,
                color: ColorsCustom.textOnPrimary,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================
// LOADING VIEW
// ============================================

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(ColorsCustom.primary),
      ),
    );
  }
}

// ============================================
// RESTAURANT INFO CARD
// ============================================

class _RestaurantInfoCard extends StatelessWidget {
  final CartRestaurant restaurant;
  final bool isArabic;

  const _RestaurantInfoCard({required this.restaurant, required this.isArabic});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ColorsCustom.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ColorsCustom.border),
        boxShadow: ColorsCustom.shadowSm,
      ),
      child: Row(
        children: [
          _RestaurantLogo(url: getFullImageUrl(restaurant.logo)),
          const SizedBox(width: 12),
          Expanded(
            child: TextCustom(
              text: restaurant.getLocalizedName(isArabic),
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ColorsCustom.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _RestaurantLogo extends StatelessWidget {
  final String? url;

  const _RestaurantLogo({this.url});

  @override
  Widget build(BuildContext context) {
    final hasValidUrl = url != null && url!.isNotEmpty;

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: ColorsCustom.primarySoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorsCustom.border),
      ),
      child: hasValidUrl
          ? ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: CachedNetworkImage(
                imageUrl: url!,
                fit: BoxFit.cover,
                placeholder: (_, __) => _buildPlaceholder(),
                errorWidget: (_, __, ___) => _buildPlaceholder(),
              ),
            )
          : _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return const Center(
      child: Icon(Icons.restaurant, color: ColorsCustom.primary, size: 22),
    );
  }
}

// ============================================
// CART ITEM CARD
// ============================================

class _CartItemCard extends StatelessWidget {
  final CartItem item;
  final bool isArabic;
  final bool isUpdating;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onRemove;

  const _CartItemCard({
    required this.item,
    required this.isArabic,
    required this.isUpdating,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Dismissible(
      key: Key('cart_item_${item.id}'),
      direction: DismissDirection.endToStart,
      background: _buildDismissBackground(),
      confirmDismiss: (_) async {
        onRemove();
        return false;
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: ColorsCustom.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ColorsCustom.border),
          boxShadow: ColorsCustom.shadowSm,
        ),
        child: Stack(
          children: [
            Row(
              children: [
                _ProductImage(url: getFullImageUrl(item.product.image)),
                const SizedBox(width: 12),
                Expanded(child: _buildProductInfo(l10n)),
              ],
            ),
            if (isUpdating) _buildLoadingOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildDismissBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 24),
      decoration: BoxDecoration(
        color: ColorsCustom.error,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(
        Icons.delete_rounded,
        color: ColorsCustom.textOnPrimary,
        size: 28,
      ),
    );
  }

  Widget _buildProductInfo(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextCustom(
          text: item.product.getLocalizedName(isArabic),
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: ColorsCustom.textPrimary,
          maxLines: 2,
        ),
        if (item.variation != null) ...[
          const SizedBox(height: 4),
          TextCustom(
            text: item.variation!.getLocalizedName(isArabic),
            fontSize: 12,
            color: ColorsCustom.textSecondary,
          ),
        ],
        if (item.addons.isNotEmpty) ...[
          const SizedBox(height: 6),
          _buildAddonsList(),
        ],
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextCustom(
              text:
                  '${item.totalPriceDouble.toStringAsFixed(0)} ${l10n.currency}',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ColorsCustom.primary,
            ),
            _QuantityControls(
              quantity: item.quantity,
              isUpdating: isUpdating,
              onChanged: onQuantityChanged,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAddonsList() {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: item.addons.map((addon) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: ColorsCustom.primarySoft,
            borderRadius: BorderRadius.circular(6),
          ),
          child: TextCustom(
            text: '+ ${addon.getLocalizedName(isArabic)}',
            fontSize: 10,
            color: ColorsCustom.primary,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLoadingOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(204),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(ColorsCustom.primary),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  final String? url;

  const _ProductImage({this.url});

  @override
  Widget build(BuildContext context) {
    final hasValidUrl = url != null && url!.isNotEmpty;

    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        color: ColorsCustom.primarySoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ColorsCustom.border),
      ),
      child: hasValidUrl
          ? ClipRRect(
              borderRadius: BorderRadius.circular(13),
              child: CachedNetworkImage(
                imageUrl: url!,
                fit: BoxFit.cover,
                placeholder: (_, __) => _buildPlaceholder(),
                errorWidget: (_, __, ___) => _buildPlaceholder(),
              ),
            )
          : _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return const Center(
      child: Icon(
        Icons.fastfood_rounded,
        size: 32,
        color: ColorsCustom.primary,
      ),
    );
  }
}

class _QuantityControls extends StatelessWidget {
  final int quantity;
  final bool isUpdating;
  final ValueChanged<int> onChanged;

  const _QuantityControls({
    required this.quantity,
    required this.isUpdating,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColorsCustom.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ColorsCustom.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _QuantityButton(
            icon: quantity == 1
                ? Icons.delete_outline_rounded
                : Icons.remove_rounded,
            isDelete: quantity == 1,
            onTap: isUpdating ? null : () => onChanged(quantity - 1),
          ),
          Container(
            constraints: const BoxConstraints(minWidth: 34),
            alignment: Alignment.center,
            child: TextCustom(
              text: quantity.toString(),
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: ColorsCustom.textPrimary,
            ),
          ),
          _QuantityButton(
            icon: Icons.add_rounded,
            onTap: isUpdating ? null : () => onChanged(quantity + 1),
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final bool isDelete;
  final VoidCallback? onTap;

  const _QuantityButton({
    required this.icon,
    this.isDelete = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: isDelete ? ColorsCustom.errorBg : ColorsCustom.primarySoft,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isDelete ? ColorsCustom.error : ColorsCustom.primary,
        ),
      ),
    );
  }
}

// ============================================
// COUPON SECTION
// ============================================

class _CouponSection extends StatelessWidget {
  final Cart cart;
  final TextEditingController controller;
  final bool showField;
  final VoidCallback onToggle;
  final VoidCallback onApply;
  final VoidCallback onRemove;

  const _CouponSection({
    required this.cart,
    required this.controller,
    required this.showField,
    required this.onToggle,
    required this.onApply,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (cart.hasCoupon) {
      return _buildAppliedCoupon(l10n);
    }

    return _buildCouponInput(l10n);
  }

  Widget _buildAppliedCoupon(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ColorsCustom.successBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ColorsCustom.success.withAlpha(77)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.local_offer_rounded,
            color: ColorsCustom.success,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextCustom(
                  text: l10n.couponApplied,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: ColorsCustom.success,
                ),
                if (cart.couponCode != null)
                  TextCustom(
                    text: cart.couponCode!,
                    fontSize: 12,
                    color: ColorsCustom.success.withAlpha(179),
                  ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: ColorsCustom.success.withAlpha(38),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.close_rounded,
                color: ColorsCustom.success,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponInput(AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: ColorsCustom.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ColorsCustom.border),
        boxShadow: ColorsCustom.shadowSm,
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const Icon(
                    Icons.local_offer_outlined,
                    color: ColorsCustom.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextCustom(
                      text: l10n.addCoupon,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: ColorsCustom.textPrimary,
                    ),
                  ),
                  Icon(
                    showField
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: ColorsCustom.textSecondary,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
          if (showField)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      style: const TextStyle(
                        fontSize: 14,
                        color: ColorsCustom.textPrimary,
                        fontFamily: 'Cairo',
                      ),
                      decoration: InputDecoration(
                        hintText: l10n.enterCouponCode,
                        hintStyle: const TextStyle(
                          color: ColorsCustom.textHint,
                          fontSize: 14,
                          fontFamily: 'Cairo',
                        ),
                        filled: true,
                        fillColor: ColorsCustom.secondarySoft,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: onApply,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: ColorsCustom.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextCustom(
                        text: l10n.apply,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: ColorsCustom.textOnPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================
// CHECKOUT SECTION
// ============================================

class _CheckoutSection extends StatelessWidget {
  final Cart cart;
  final VoidCallback onCheckout;

  const _CheckoutSection({required this.cart, required this.onCheckout});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(20),
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
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PriceRow(label: l10n.subtotal, amount: cart.subtotalDouble),
            const SizedBox(height: 8),
            _PriceRow(label: l10n.deliveryFee, amount: cart.deliveryFeeDouble),
            if (cart.discountAmountDouble > 0) ...[
              const SizedBox(height: 8),
              _PriceRow(
                label: l10n.discount,
                amount: -cart.discountAmountDouble,
                isDiscount: true,
              ),
            ],
            const SizedBox(height: 14),
            const Divider(color: ColorsCustom.border, height: 1),
            const SizedBox(height: 14),
            _TotalRow(total: cart.totalDouble),
            const SizedBox(height: 18),
            _CheckoutButton(onTap: onCheckout),
          ],
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final double amount;
  final bool isDiscount;

  const _PriceRow({
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

class _TotalRow extends StatelessWidget {
  final double total;

  const _TotalRow({required this.total});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextCustom(
          text: l10n.total,
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: ColorsCustom.textPrimary,
        ),
        TextCustom(
          text: '${total.toStringAsFixed(0)} ${l10n.currency}',
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: ColorsCustom.primary,
        ),
      ],
    );
  }
}

class _CheckoutButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CheckoutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: ColorsCustom.primary,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.arrow_forward_rounded,
              color: ColorsCustom.textOnPrimary,
              size: 20,
            ),
            const SizedBox(width: 10),
            TextCustom(
              text: l10n.continueToCheckout,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ColorsCustom.textOnPrimary,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================
// CLEAR CART DIALOG
// ============================================

class _ClearCartDialog extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onClear;

  const _ClearCartDialog({required this.onCancel, required this.onClear});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
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
                Icons.remove_shopping_cart_outlined,
                color: ColorsCustom.error,
                size: 28,
              ),
            ),
            const SizedBox(height: 20),
            TextCustom(
              text: l10n.clearCart,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ColorsCustom.textPrimary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            TextCustom(
              text: l10n.clearCartConfirmation,
              fontSize: 14,
              color: ColorsCustom.textSecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ButtonCustom.secondary(
                    text: l10n.cancel,
                    onPressed: onCancel,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ButtonCustom.primary(
                    text: l10n.clearAll,
                    onPressed: onClear,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
