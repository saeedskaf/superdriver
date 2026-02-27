import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:superdriver/domain/bloc/cart/cart_bloc.dart';
import 'package:superdriver/domain/bloc/auth/auth_bloc.dart';
import 'package:superdriver/domain/models/cart_model.dart';
import 'package:superdriver/l10n/app_localizations.dart';
import 'package:superdriver/presentation/components/text_custom.dart';
import 'package:superdriver/presentation/components/btn_custom.dart';
import 'package:superdriver/presentation/screens/main/cart_detail_screen.dart';
import 'package:superdriver/presentation/screens/main/home/home_widgets.dart';
import 'package:superdriver/presentation/screens/auth/login_screen.dart';
import 'package:superdriver/presentation/themes/colors_custom.dart';

// ============================================
// CART SCREEN
// ============================================

class CartScreen extends StatefulWidget {
  final VoidCallback? onNavigateToHome;

  const CartScreen({super.key, this.onNavigateToHome});

  @override
  State<CartScreen> createState() => CartScreenState();
}

class CartScreenState extends State<CartScreen> {
  // ── AuthCheckStatus removed: parent (MainScreen) already handles auth,
  //    and the BlocBuilder below reacts to AuthBloc state changes anyway.

  @override
  void initState() {
    super.initState();
    loadCarts();
  }

  void loadCarts() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<CartBloc>().add(const CartLoadAllRequested());
    }
  }

  bool get _isAuthenticated {
    final authState = context.read<AuthBloc>().state;
    return authState is AuthAuthenticated;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsCustom.background,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            loadCarts();
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            if (!_isAuthenticated) {
              return SafeArea(
                child: _NotLoggedInView(
                  onLogin: () => _navigateToLogin(context),
                ),
              );
            }

            return Column(
              children: [
                _CartHeader(onRefresh: loadCarts),
                Expanded(
                  child: BlocConsumer<CartBloc, CartState>(
                    listenWhen: (prev, curr) => prev != curr,
                    listener: _handleCartState,
                    builder: (context, state) => _buildContent(state),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _handleCartState(BuildContext context, CartState state) {
    final l10n = AppLocalizations.of(context)!;

    if (state is CartError) {
      _showSnackBar(context, state.message, isError: true);
    } else if (state is CartDeleted) {
      _showSnackBar(context, l10n.cartDeleted, isError: false);
      loadCarts();
    }
  }

  Widget _buildContent(CartState state) {
    if (state is CartLoading) {
      return const _LoadingView();
    }

    if (state is CartAllLoaded) {
      if (state.carts.isEmpty) {
        return _EmptyCartView(onBrowse: _navigateToHome);
      }
      return _CartsList(
        carts: state.carts,
        onRefresh: loadCarts,
        onCartTap: (cart) => _navigateToCartDetail(context, cart),
        onDeleteCart: (cart) => _showDeleteDialog(context, cart),
      );
    }

    return _EmptyCartView(onBrowse: _navigateToHome);
  }

  void _navigateToLogin(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _navigateToHome() {
    if (widget.onNavigateToHome != null) {
      widget.onNavigateToHome!();
    }
  }

  void _navigateToCartDetail(BuildContext context, CartSummary cart) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<CartBloc>(),
          child: CartDetailScreen(
            cartId: cart.id,
            restaurantId: cart.restaurantId,
          ),
        ),
      ),
    ).then((_) {
      if (!mounted) return;
      loadCarts();
    });
  }

  void _showDeleteDialog(BuildContext context, CartSummary cart) {
    showDialog(
      context: context,
      builder: (ctx) => _DeleteCartDialog(
        cartName: cart.restaurantName,
        onCancel: () => Navigator.pop(ctx),
        onDelete: () {
          Navigator.pop(ctx);
          context.read<CartBloc>().add(CartDeleteRequested(cartId: cart.id));
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
}

// ============================================
// CART HEADER
// ============================================

class _CartHeader extends StatelessWidget {
  final VoidCallback onRefresh;

  const _CartHeader({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.fromLTRB(24, topPadding + 16, 16, 20),
      decoration: BoxDecoration(
        color: ColorsCustom.surface,
        boxShadow: ColorsCustom.shadowSm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ClipRRect(
            child: Image.asset(
              'assets/icons/cart_empty_state.png',
              width: 50,
              height: 50,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextCustom(
                text: l10n.cart,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: ColorsCustom.textPrimary,
              ),
              const SizedBox(height: 4),
              BlocBuilder<CartBloc, CartState>(
                builder: (context, state) {
                  final totalItems = state is CartAllLoaded
                      ? state.carts.fold<int>(0, (sum, c) => sum + c.itemsCount)
                      : 0;
                  return TextCustom(
                    text: '${l10n.items}: $totalItems',
                    fontSize: 13,
                    color: ColorsCustom.secondaryDark,
                  );
                },
              ),
            ],
          ),
          Spacer(),
          _IconButton(icon: Icons.refresh_rounded, onTap: onRefresh),
        ],
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
            const SizedBox(height: 28),
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
            ButtonCustom.primary(
              text: l10n.login,
              onPressed: onLogin,
              icon: const Icon(
                Icons.login_rounded,
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
// EMPTY CART VIEW
// ============================================

class _EmptyCartView extends StatelessWidget {
  final VoidCallback onBrowse;

  const _EmptyCartView({required this.onBrowse});

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
              onPressed: onBrowse,
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
// CARTS LIST
// ============================================

class _CartsList extends StatelessWidget {
  final List<CartSummary> carts;
  final VoidCallback onRefresh;
  final ValueChanged<CartSummary> onCartTap;
  final ValueChanged<CartSummary> onDeleteCart;

  const _CartsList({
    required this.carts,
    required this.onRefresh,
    required this.onCartTap,
    required this.onDeleteCart,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      color: ColorsCustom.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: carts.length,
        itemBuilder: (_, index) => Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _CartSummaryCard(
            cart: carts[index],
            onTap: () => onCartTap(carts[index]),
            onDelete: () => onDeleteCart(carts[index]),
          ),
        ),
      ),
    );
  }
}

// ============================================
// CART SUMMARY CARD
// ============================================

class _CartSummaryCard extends StatelessWidget {
  final CartSummary cart;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _CartSummaryCard({
    required this.cart,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: ColorsCustom.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cart.isExpired
              ? ColorsCustom.error.withAlpha(128)
              : ColorsCustom.border,
        ),
        boxShadow: ColorsCustom.shadowSm,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: cart.isExpired ? null : onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(l10n),
                const SizedBox(height: 14),
                if (cart.itemsPreview.isNotEmpty) _buildItemsPreview(l10n),
                if (cart.isExpired)
                  _StatusBanner(
                    icon: Icons.warning_rounded,
                    text: l10n.cartExpired,
                    color: ColorsCustom.error,
                    bgColor: ColorsCustom.errorBg,
                  ),
                if (!cart.isExpired && cart.isExpiringSoon)
                  _StatusBanner(
                    icon: Icons.timer_rounded,
                    text:
                        '${_formatTimeRemaining(cart.timeRemainingSeconds!, l10n)} ${l10n.remaining}',
                    color: ColorsCustom.warning,
                    bgColor: ColorsCustom.warningBg,
                  ),
                const SizedBox(height: 12),
                _buildFooter(l10n),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Row(
      children: [
        _RestaurantLogo(url: getFullImageUrl(cart.restaurantLogo)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextCustom(
                text: cart.restaurantName,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: ColorsCustom.textPrimary,
              ),
              const SizedBox(height: 3),
              TextCustom(
                text: '${l10n.items}: ${cart.itemsCount}',
                fontSize: 13,
                color: ColorsCustom.secondaryDark,
              ),
            ],
          ),
        ),
        _IconButton(
          icon: Icons.delete_outline_rounded,
          color: ColorsCustom.error,
          bgColor: ColorsCustom.errorBg,
          onTap: onDelete,
          size: 36,
        ),
      ],
    );
  }

  Widget _buildItemsPreview(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: ColorsCustom.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextCustom(
            text: l10n.orderItems,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: ColorsCustom.textHint,
          ),
          const SizedBox(height: 8),
          ...cart.itemsPreview
              .take(3)
              .map((item) => _CartItemPreviewRow(item: item)),
          if (cart.itemsPreview.length > 3)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: TextCustom(
                text: '+${cart.itemsPreview.length - 3} ${l10n.moreItems}',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: ColorsCustom.primary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFooter(AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextCustom(
              text: l10n.total,
              fontSize: 12,
              color: ColorsCustom.textSecondary,
            ),
            const SizedBox(height: 2),
            TextCustom(
              text: '${cart.totalDouble.toStringAsFixed(0)} ${l10n.currency}',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: ColorsCustom.primary,
            ),
          ],
        ),
        if (!cart.isExpired)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: ColorsCustom.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextCustom(
                  text: l10n.viewCart,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: ColorsCustom.textOnPrimary,
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: ColorsCustom.textOnPrimary,
                  size: 16,
                ),
              ],
            ),
          ),
      ],
    );
  }

  String _formatTimeRemaining(int seconds, AppLocalizations l10n) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    if (minutes > 0) {
      return '$minutes ${l10n.minuteShort} $remainingSeconds ${l10n.secondShort}';
    }
    return '$remainingSeconds ${l10n.secondShort}';
  }
}

// ============================================
// CART ITEM PREVIEW ROW
// ============================================

class _CartItemPreviewRow extends StatelessWidget {
  final CartItemPreview item;

  const _CartItemPreviewRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: ColorsCustom.primarySoft,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: TextCustom(
                text: '${item.quantity}',
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: ColorsCustom.primary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextCustom(
              text: item.productName,
              fontSize: 13,
              color: ColorsCustom.textPrimary,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          TextCustom(
            text: '${item.totalPrice.toStringAsFixed(0)} ${l10n.currency}',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: ColorsCustom.textSecondary,
          ),
        ],
      ),
    );
  }
}

// ============================================
// HELPER WIDGETS
// ============================================

class _RestaurantLogo extends StatelessWidget {
  final String? url;

  const _RestaurantLogo({this.url});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: ColorsCustom.primarySoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ColorsCustom.border),
      ),
      child: (url != null && url!.isNotEmpty)
          ? ClipRRect(
              borderRadius: BorderRadius.circular(13),
              child: CachedNetworkImage(
                imageUrl: url!,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => _buildPlaceholder(),
              ),
            )
          : _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return const Center(
      child: Icon(Icons.restaurant, color: ColorsCustom.primary, size: 24),
    );
  }
}

/// Reusable icon button used across the cart screens.
class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final Color bgColor;
  final double size;

  const _IconButton({
    required this.icon,
    required this.onTap,
    this.color = ColorsCustom.primary,
    this.bgColor = ColorsCustom.primarySoft,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: size * 0.5),
      ),
    );
  }
}

/// Status banner for expired / expiring-soon carts.
class _StatusBanner extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final Color bgColor;

  const _StatusBanner({
    required this.icon,
    required this.text,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: TextCustom(
              text: text,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================
// DELETE CART DIALOG
// ============================================

class _DeleteCartDialog extends StatelessWidget {
  final String cartName;
  final VoidCallback onCancel;
  final VoidCallback onDelete;

  const _DeleteCartDialog({
    required this.cartName,
    required this.onCancel,
    required this.onDelete,
  });

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
                Icons.delete_outline_rounded,
                color: ColorsCustom.error,
                size: 28,
              ),
            ),
            const SizedBox(height: 20),
            TextCustom(
              text: l10n.deleteCart,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ColorsCustom.textPrimary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            TextCustom(
              text: l10n.deleteCartConfirmation,
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
                    text: l10n.delete,
                    onPressed: onDelete,
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
