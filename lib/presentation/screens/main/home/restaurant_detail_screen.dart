import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:superdriver/domain/bloc/restaurant/restaurant_bloc.dart';
import 'package:superdriver/domain/bloc/menu/menu_bloc.dart';
import 'package:superdriver/domain/bloc/cart/cart_bloc.dart';
import 'package:superdriver/domain/models/cart_model.dart';
import 'package:superdriver/domain/bloc/auth/auth_bloc.dart';
import 'package:superdriver/domain/models/restaurant_model.dart';
import 'package:superdriver/domain/models/menu_model.dart';
import 'package:superdriver/l10n/app_localizations.dart';
import 'package:superdriver/presentation/components/btn_custom.dart';
import 'package:superdriver/presentation/components/text_custom.dart';
import 'package:superdriver/presentation/screens/main/cart_detail_screen.dart';
import 'package:superdriver/presentation/screens/main/home/home_widgets.dart';
import 'package:superdriver/presentation/screens/auth/login_screen.dart';
import 'package:superdriver/presentation/themes/colors_custom.dart';

// ============================================================
// RESTAURANT DETAIL SCREEN
// ============================================================

class RestaurantDetailScreen extends StatefulWidget {
  final String slug;
  final double? lat;
  final double? lng;
  const RestaurantDetailScreen({
    super.key,
    required this.slug,
    this.lat,
    this.lng,
  });

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();
  final _loadingIds = <int>{}; // instance-scoped loading tracker

  RestaurantDetail? _rest;
  List<MenuCategory> _cats = [];
  int _catIdx = 0;
  String _query = '';
  int _tab = 0;
  bool _searching = false;

  /// true while the cart load is the automatic initial check,
  /// so we can silently swallow "no cart" errors.
  bool _isInitialCartLoad = false;

  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _searchFocus.addListener(() {
      setState(() => _searching = _searchFocus.hasFocus);
    });
    context.read<RestaurantBloc>().add(
      RestaurantDetailsLoadRequested(
        slug: widget.slug,
        lat: widget.lat,
        lng: widget.lng,
      ),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  bool get _isAuth => context.read<AuthBloc>().state is AuthAuthenticated;
  bool get _isAr => Localizations.localeOf(context).languageCode == 'ar';

  // ── Data ──

  void _loadProducts(int rId, int cId) {
    context.read<MenuBloc>().add(
      MenuProductsLoadRequested(
        restaurantId: rId,
        categoryId: cId,
        search: _query.isEmpty ? null : _query,
      ),
    );
  }

  void _onSearch(String q) {
    setState(() => _query = q);
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      if (_rest != null && _cats.isNotEmpty) {
        _loadProducts(_rest!.id, _cats[_catIdx].id);
      }
    });
  }

  /// Initial cart check — errors are silently ignored.
  void _tryCart(int id) {
    if (_isAuth) {
      _isInitialCartLoad = true;
      context.read<CartBloc>().add(CartLoadRequested(restaurantId: id));
    }
  }

  // ── Cart actions ──

  void _addToCart(ProductSimpleMenu p) {
    if (!_isAuth) return _loginDialog();
    if (_rest == null) return;
    setState(() => _loadingIds.add(p.id));
    _isInitialCartLoad = false;
    context.read<CartBloc>().add(
      CartAddItemRequested(
        restaurantId: _rest!.id,
        productId: p.id,
        quantity: 1,
      ),
    );
  }

  /// Find the CartItem for a given product ID (null if not in cart).
  CartItem? _findCartItem(int productId) {
    final cart = context.read<CartBloc>().currentCart;
    if (cart == null) return null;
    try {
      return cart.items.firstWhere((i) => i.product.id == productId);
    } catch (_) {
      return null;
    }
  }

  /// Get cart quantity for a product (0 if not in cart).
  int _cartQuantity(int productId) => _findCartItem(productId)?.quantity ?? 0;

  void _incrementProduct(ProductSimpleMenu p) => _addToCart(p);

  void _decrementProduct(ProductSimpleMenu p) {
    final cartItem = _findCartItem(p.id);
    if (cartItem == null) return;

    setState(() => _loadingIds.add(p.id));
    _isInitialCartLoad = false;

    if (cartItem.quantity <= 1) {
      context.read<CartBloc>().add(
        CartRemoveItemRequested(itemId: cartItem.id),
      );
    } else {
      context.read<CartBloc>().add(
        CartUpdateItemRequested(
          itemId: cartItem.id,
          quantity: cartItem.quantity - 1,
        ),
      );
    }
  }

  void _goToCart() {
    if (!_isAuth) return _loginDialog();
    final cart = context.read<CartBloc>().currentCart;
    if (cart == null || _rest == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<CartBloc>(),
          child: CartDetailScreen(cartId: cart.id, restaurantId: _rest!.id),
        ),
      ),
    );
  }

  void _loginDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => _LoginSheet(
        l10n: l10n,
        onCancel: () => Navigator.pop(ctx),
        onLogin: () {
          Navigator.pop(ctx);
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (r) => false,
          );
        },
      ),
    );
  }

  // ── Product detail bottom sheet ──

  void _showProductDetail(ProductSimpleMenu p) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: ColorsCustom.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => BlocProvider.value(
        value: context.read<CartBloc>(),
        child: _ProductDetailSheet(
          product: p,
          isAr: _isAr,
          onAdd: () => _addToCart(p),
          onIncrement: () => _incrementProduct(p),
          onDecrement: () => _decrementProduct(p),
        ),
      ),
    );
  }

  void _snack(String msg, {required bool isError}) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: TextCustom(text: msg, fontSize: 14, color: Colors.white),
        backgroundColor: isError ? ColorsCustom.error : ColorsCustom.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ── Back button ──

  Widget _buildBackButton() {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: ColorsCustom.primarySoft,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: ColorsCustom.primary,
          ),
        ),
      ),
    );
  }

  // ── App bar ──

  Widget _buildAppBar(String name) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        bottom: 12,
        left: 12,
        right: 12,
      ),
      decoration: const BoxDecoration(
        color: ColorsCustom.surface,
        border: Border(
          bottom: BorderSide(color: ColorsCustom.border, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          _buildBackButton(),
          const SizedBox(width: 12),
          Expanded(
            child: TextCustom(
              text: name,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: ColorsCustom.textPrimary,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: ColorsCustom.background,
      resizeToAvoidBottomInset: true,
      body: MultiBlocListener(
        listeners: [
          BlocListener<RestaurantBloc, RestaurantState>(
            listener: (_, s) {
              if (s is RestaurantDetailsLoaded) {
                _rest = s.restaurant;
                context.read<MenuBloc>().add(
                  MenuCategoriesLoadRequested(restaurantId: s.restaurant.id),
                );
                _tryCart(s.restaurant.id);
              }
            },
          ),
          BlocListener<MenuBloc, MenuState>(
            listener: (_, s) {
              if (s is MenuCategoriesLoaded) {
                setState(() => _cats = s.categories);
                if (_cats.isNotEmpty && _rest != null) {
                  _loadProducts(_rest!.id, _cats[0].id);
                }
              }
            },
          ),
          BlocListener<CartBloc, CartState>(
            listener: (_, s) {
              if (s is CartOperationSuccess ||
                  s is CartLoaded ||
                  s is CartEmpty) {
                setState(() {
                  _loadingIds.clear();
                  _isInitialCartLoad = false;
                });
              }
              if (s is CartError) {
                setState(() => _loadingIds.clear());
                // Only show errors from user actions (add/update/remove).
                // Suppress errors from automatic initial cart check.
                if (!_isInitialCartLoad) {
                  _snack(s.message, isError: true);
                }
                _isInitialCartLoad = false;
              }
            },
          ),
        ],
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (_, auth) => Stack(
            children: [
              _buildBody(l10n),
              if (auth is AuthAuthenticated)
                _CartBar(restaurant: _rest, onTap: _goToCart),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    return BlocBuilder<RestaurantBloc, RestaurantState>(
      builder: (_, s) {
        if (s is RestaurantDetailsLoading) {
          return Column(
            children: [
              _buildAppBar(''),
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: ColorsCustom.primary),
                ),
              ),
            ],
          );
        }
        if (s is RestaurantDetailsError) {
          return Column(
            children: [
              _buildAppBar(''),
              Expanded(
                child: _ErrorView(
                  message: s.message,
                  onRetry: () => context.read<RestaurantBloc>().add(
                    RestaurantDetailsLoadRequested(
                      slug: widget.slug,
                      lat: widget.lat,
                      lng: widget.lng,
                    ),
                  ),
                ),
              ),
            ],
          );
        }
        if (s is RestaurantDetailsLoaded) {
          return _buildPage(l10n, s.restaurant);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildPage(AppLocalizations l10n, RestaurantDetail r) {
    final name = _isAr ? r.name : (r.nameEn ?? r.name);
    final logo = getFullImageUrl(r.logo);
    final cover = getFullImageUrl(r.coverImage);

    return Column(
      children: [
        _buildAppBar(name),
        Expanded(
          child: _searching || _query.isNotEmpty
              ? _menuSection(l10n, r)
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      _CoverWithLogo(coverUrl: cover, logoUrl: logo),
                      _InfoCard(restaurant: r, isArabic: _isAr),
                      _TabBar(
                        selected: _tab,
                        onChanged: (t) => setState(() => _tab = t),
                      ),
                      const SizedBox(height: 4),
                      _tab == 0
                          ? _menuInline(l10n, r)
                          : _InfoTab(restaurant: r),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  // ── Menu (inside SingleChildScrollView) ──

  Widget _menuInline(AppLocalizations l10n, RestaurantDetail r) {
    return BlocBuilder<MenuBloc, MenuState>(
      builder: (_, s) {
        if (s is MenuCategoriesLoading) {
          return const Padding(
            padding: EdgeInsets.all(48),
            child: Center(
              child: CircularProgressIndicator(color: ColorsCustom.primary),
            ),
          );
        }
        if (s is MenuCategoriesEmpty || _cats.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(48),
            child: _EmptyIcon(
              icon: Icons.restaurant_menu_rounded,
              text: l10n.noMenuAvailable,
              color: ColorsCustom.secondary,
              bgColor: ColorsCustom.secondarySoft,
            ),
          );
        }
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
              child: _SearchField(
                controller: _searchCtrl,
                focusNode: _searchFocus,
                hint: l10n.searchInMenu,
                onChanged: _onSearch,
                onClear: () {
                  _searchCtrl.clear();
                  _onSearch('');
                  _searchFocus.unfocus();
                },
              ),
            ),
            _CatChips(
              cats: _cats,
              idx: _catIdx,
              isAr: _isAr,
              onTap: (i) {
                setState(() => _catIdx = i);
                _loadProducts(r.id, _cats[i].id);
              },
            ),
            const SizedBox(height: 10),
            _productsInline(l10n),
          ],
        );
      },
    );
  }

  Widget _productsInline(AppLocalizations l10n) {
    return BlocBuilder<MenuBloc, MenuState>(
      builder: (_, s) {
        if (s is MenuProductsLoading) {
          return const Padding(
            padding: EdgeInsets.all(48),
            child: Center(
              child: CircularProgressIndicator(color: ColorsCustom.primary),
            ),
          );
        }
        if (s is MenuProductsEmpty) {
          return Padding(
            padding: const EdgeInsets.all(48),
            child: _EmptyIcon(
              icon: Icons.inbox_outlined,
              text: _query.isEmpty
                  ? l10n.noProductsInCategory
                  : l10n.noSearchResults,
              color: ColorsCustom.warning,
              bgColor: ColorsCustom.warningBg,
            ),
          );
        }
        if (s is MenuProductsLoaded) {
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
            itemCount: s.products.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final p = s.products[i];
              return _ProductCard(
                product: p,
                isAr: _isAr,
                loading: _loadingIds.contains(p.id),
                cartQuantity: _cartQuantity(p.id),
                onAdd: () => _addToCart(p),
                onIncrement: () => _incrementProduct(p),
                onDecrement: () => _decrementProduct(p),
                onTap: () => _showProductDetail(p),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  // ── Menu (fullscreen search mode) ──

  Widget _menuSection(AppLocalizations l10n, RestaurantDetail r) {
    return BlocBuilder<MenuBloc, MenuState>(
      builder: (_, s) {
        if (s is MenuCategoriesLoading) {
          return const Center(
            child: CircularProgressIndicator(color: ColorsCustom.primary),
          );
        }
        if (s is MenuCategoriesEmpty || _cats.isEmpty) {
          return Center(
            child: _EmptyIcon(
              icon: Icons.restaurant_menu_rounded,
              text: l10n.noMenuAvailable,
              color: ColorsCustom.secondary,
              bgColor: ColorsCustom.secondarySoft,
            ),
          );
        }
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
              child: _SearchField(
                controller: _searchCtrl,
                focusNode: _searchFocus,
                hint: l10n.searchInMenu,
                onChanged: _onSearch,
                onClear: () {
                  _searchCtrl.clear();
                  _onSearch('');
                  _searchFocus.unfocus();
                },
              ),
            ),
            _CatChips(
              cats: _cats,
              idx: _catIdx,
              isAr: _isAr,
              onTap: (i) {
                setState(() => _catIdx = i);
                _loadProducts(r.id, _cats[i].id);
              },
            ),
            const SizedBox(height: 10),
            Expanded(child: _productsList(l10n)),
          ],
        );
      },
    );
  }

  Widget _productsList(AppLocalizations l10n) {
    return BlocBuilder<MenuBloc, MenuState>(
      builder: (_, s) {
        if (s is MenuProductsLoading) {
          return const Center(
            child: CircularProgressIndicator(color: ColorsCustom.primary),
          );
        }
        if (s is MenuProductsEmpty) {
          return Center(
            child: _EmptyIcon(
              icon: Icons.inbox_outlined,
              text: _query.isEmpty
                  ? l10n.noProductsInCategory
                  : l10n.noSearchResults,
              color: ColorsCustom.warning,
              bgColor: ColorsCustom.warningBg,
            ),
          );
        }
        if (s is MenuProductsLoaded) {
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
            itemCount: s.products.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final p = s.products[i];
              return _ProductCard(
                product: p,
                isAr: _isAr,
                loading: _loadingIds.contains(p.id),
                cartQuantity: _cartQuantity(p.id),
                onAdd: () => _addToCart(p),
                onIncrement: () => _incrementProduct(p),
                onDecrement: () => _decrementProduct(p),
                onTap: () => _showProductDetail(p),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

// ============================================================
// COVER WITH LOGO
// ============================================================

const double _kCoverH = 180.0;
const double _kLogoSize = 56.0;
const double _kLogoBorder = 3.0;

class _CoverWithLogo extends StatelessWidget {
  final String coverUrl;
  final String logoUrl;
  const _CoverWithLogo({required this.coverUrl, required this.logoUrl});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _kCoverH,
      child: Stack(
        children: [
          SizedBox(
            height: _kCoverH,
            width: double.infinity,
            child: coverUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: coverUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => _coverPlaceholder(),
                    errorWidget: (_, __, ___) => _coverPlaceholder(),
                  )
                : _coverPlaceholder(),
          ),
          PositionedDirectional(
            end: 16,
            bottom: 12,
            child: Container(
              width: _kLogoSize,
              height: _kLogoSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ColorsCustom.surface,
                border: Border.all(
                  color: ColorsCustom.surface,
                  width: _kLogoBorder,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(38),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipOval(
                child: logoUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: logoUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => _logoPlaceholder(),
                        errorWidget: (_, __, ___) => _logoPlaceholder(),
                      )
                    : _logoPlaceholder(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _coverPlaceholder() => Container(
    color: ColorsCustom.primarySoft,
    child: const Center(
      child: Icon(
        Icons.restaurant_rounded,
        size: 48,
        color: ColorsCustom.primary,
      ),
    ),
  );

  Widget _logoPlaceholder() => Container(
    color: ColorsCustom.surfaceVariant,
    child: const Icon(Icons.restaurant, color: ColorsCustom.primary, size: 24),
  );
}

// ============================================================
// RESTAURANT INFO CARD
// ============================================================

class _InfoCard extends StatelessWidget {
  final RestaurantDetail restaurant;
  final bool isArabic;
  const _InfoCard({required this.restaurant, required this.isArabic});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isOpen = restaurant.isCurrentlyOpen;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
      child: Column(
        children: [
          // ── Delivery info + status — single unified card ──
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            decoration: BoxDecoration(
              color: ColorsCustom.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                _DeliveryItem(
                  icon: Icons.schedule_rounded,
                  value:
                      '${restaurant.deliveryTimeEstimate ?? '30'} ${l10n.minute}',
                  label: l10n.deliveryTime,
                  color: ColorsCustom.primary,
                  bgColor: ColorsCustom.primarySoft,
                ),
                _divider(),
                _DeliveryItem(
                  icon: Icons.delivery_dining_rounded,
                  value: restaurant.deliveryFee == 0
                      ? l10n.free
                      : '${restaurant.deliveryFee.toStringAsFixed(0)} ${l10n.currency}',
                  label: l10n.deliveryFee,
                  color: ColorsCustom.secondaryDark,
                  bgColor: ColorsCustom.secondarySoft,
                ),
                _divider(),
                _DeliveryItem(
                  icon: Icons.shopping_bag_outlined,
                  value:
                      '${restaurant.minimumOrderAmount.toStringAsFixed(0)} ${l10n.currency}',
                  label: l10n.minimum,
                  color: ColorsCustom.success,
                  bgColor: ColorsCustom.successBg,
                ),
                _divider(),
                _DeliveryItem(
                  icon: isOpen
                      ? Icons.storefront_rounded
                      : Icons.store_outlined,
                  value: isOpen ? l10n.open : l10n.closed,
                  color: isOpen ? ColorsCustom.success : ColorsCustom.error,
                  bgColor: isOpen
                      ? ColorsCustom.successBg
                      : ColorsCustom.errorBg,
                ),
              ],
            ),
          ),

          // ── Discount banner (only if active) ──
          if (restaurant.hasDiscount &&
              (restaurant.currentDiscount ?? 0) > 0) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: ColorsCustom.secondarySoft,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: ColorsCustom.secondary.withAlpha(51)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: ColorsCustom.secondary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.local_offer_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  TextCustom(
                    text:
                        '${(restaurant.currentDiscount ?? 0).toInt()}% ${l10n.discountOnAllProducts}',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: ColorsCustom.secondaryDark,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _divider() =>
      Container(width: 1, height: 36, color: ColorsCustom.border);
}

class _DeliveryItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String? label;
  final Color color;
  final Color bgColor;
  const _DeliveryItem({
    required this.icon,
    required this.value,
    this.label,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 6),
          TextCustom(
            text: value,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: ColorsCustom.textPrimary,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (label != null) ...[
            const SizedBox(height: 2),
            TextCustom(
              text: label!,
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: ColorsCustom.textSecondary,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

// ============================================================
// TAB BAR (Menu / Info)
// ============================================================

class _TabBar extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;
  const _TabBar({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: ColorsCustom.surfaceVariant,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _TabItem(
            text: l10n.menu,
            icon: Icons.restaurant_menu_rounded,
            active: selected == 0,
            onTap: () => onChanged(0),
          ),
          _TabItem(
            text: l10n.info,
            icon: Icons.info_outline_rounded,
            active: selected == 1,
            onTap: () => onChanged(1),
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  const _TabItem({
    required this.text,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? ColorsCustom.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: active ? Colors.white : ColorsCustom.textHint,
              ),
              const SizedBox(width: 6),
              TextCustom(
                text: text,
                fontSize: 14,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: active ? Colors.white : ColorsCustom.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// CATEGORY CHIPS
// ============================================================

class _CatChips extends StatelessWidget {
  final List<MenuCategory> cats;
  final int idx;
  final bool isAr;
  final ValueChanged<int> onTap;
  const _CatChips({
    required this.cats,
    required this.idx,
    required this.isAr,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: cats.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final c = cats[i];
          final name = isAr ? c.name : (c.nameEn ?? c.name);
          final sel = i == idx;
          return GestureDetector(
            onTap: () => onTap(i),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: sel ? ColorsCustom.primary : ColorsCustom.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: sel ? ColorsCustom.primary : ColorsCustom.border,
                ),
              ),
              child: Center(
                child: TextCustom(
                  text: name,
                  fontSize: 13,
                  fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                  color: sel ? Colors.white : ColorsCustom.textPrimary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// SEARCH FIELD
// ============================================================

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  const _SearchField({
    required this.controller,
    required this.focusNode,
    required this.hint,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: ColorsCustom.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        style: const TextStyle(
          fontSize: 14,
          color: ColorsCustom.textPrimary,
          fontFamily: 'Cairo',
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: ColorsCustom.textHint,
            fontSize: 14,
            fontFamily: 'Cairo',
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: ColorsCustom.textHint,
            size: 20,
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  onPressed: onClear,
                  icon: const Icon(
                    Icons.close_rounded,
                    color: ColorsCustom.textSecondary,
                    size: 18,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// PRODUCT CARD
// ============================================================

class _ProductCard extends StatelessWidget {
  final ProductSimpleMenu product;
  final bool isAr;
  final bool loading;
  final int cartQuantity;
  final VoidCallback onAdd;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback? onTap;

  const _ProductCard({
    required this.product,
    required this.isAr,
    required this.loading,
    required this.cartQuantity,
    required this.onAdd,
    required this.onIncrement,
    required this.onDecrement,
    this.onTap,
  });

  String get _name {
    if (!isAr && product.nameEn != null && product.nameEn!.isNotEmpty) {
      return product.nameEn!;
    }
    return product.name;
  }

  String? get _description {
    if (!isAr &&
        product.descriptionEn != null &&
        product.descriptionEn!.isNotEmpty) {
      return product.descriptionEn;
    }
    if (product.description != null && product.description!.isNotEmpty) {
      return product.description;
    }
    return null;
  }

  bool get _hasDiscount =>
      product.hasDiscount && product.discountAmountDouble > 0;

  int get _discountPercent =>
      ((product.discountAmountDouble / product.basePriceDouble) * 100).toInt();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final img = getFullImageUrl(product.image);
    final available = product.isAvailable;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    final imgBorderRadius = isRtl
        ? const BorderRadius.only(
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(16),
            bottomLeft: Radius.circular(16),
          );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 120),
        decoration: BoxDecoration(
          color: ColorsCustom.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(available ? 13 : 5),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // ── Image ──
              _buildImage(img, imgBorderRadius, available, l10n),

              // ── Content ──
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(l10n, available),
                      if (_description != null) ...[
                        const SizedBox(height: 4),
                        _buildDescription(),
                      ],
                      const Spacer(),
                      const SizedBox(height: 8),
                      _buildFooter(l10n, available),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Image section ──

  Widget _buildImage(
    String img,
    BorderRadius borderRadius,
    bool available,
    AppLocalizations l10n,
  ) {
    return SizedBox(
      width: 110,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: ColorsCustom.surfaceVariant,
                borderRadius: borderRadius,
              ),
              child: img.isNotEmpty
                  ? ClipRRect(
                      borderRadius: borderRadius,
                      child: CachedNetworkImage(
                        imageUrl: img,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => _imagePlaceholder(),
                        errorWidget: (_, __, ___) => _imagePlaceholder(),
                      ),
                    )
                  : _imagePlaceholder(),
            ),
          ),
          if (_hasDiscount)
            PositionedDirectional(
              top: 8,
              start: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: ColorsCustom.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextCustom(
                  text: '-$_discountPercent%',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          if (!available)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(153),
                  borderRadius: borderRadius,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return const Center(
      child: Icon(
        Icons.fastfood_rounded,
        color: ColorsCustom.textHint,
        size: 30,
      ),
    );
  }

  // ── Header (name + badge) ──

  Widget _buildHeader(AppLocalizations l10n, bool available) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextCustom(
            text: _name,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: available ? ColorsCustom.textPrimary : ColorsCustom.textHint,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (!available) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: ColorsCustom.errorBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextCustom(
              text: l10n.unavailable,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: ColorsCustom.error,
            ),
          ),
        ],
      ],
    );
  }

  // ── Description ──

  Widget _buildDescription() {
    return TextCustom(
      text: _description!,
      fontSize: 12,
      color: ColorsCustom.textSecondary,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  // ── Footer (price + cart controls) ──

  Widget _buildFooter(AppLocalizations l10n, bool available) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Price
        Expanded(child: _buildPrice(l10n)),

        // Cart controls
        if (available) _buildCartControls(),
      ],
    );
  }

  Widget _buildPrice(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextCustom(
          text:
              '${product.currentPriceDouble.toStringAsFixed(0)} ${l10n.currency}',
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: _hasDiscount ? ColorsCustom.primary : ColorsCustom.textPrimary,
        ),
        if (_hasDiscount)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: TextCustom(
              text:
                  '${product.basePriceDouble.toStringAsFixed(0)} ${l10n.currency}',
              fontSize: 11,
              color: ColorsCustom.textHint,
              decoration: TextDecoration.lineThrough,
            ),
          ),
      ],
    );
  }

  // ── Cart controls: + button or [ - count + ] ──

  Widget _buildCartControls() {
    if (loading) {
      return Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: ColorsCustom.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Padding(
          padding: EdgeInsets.all(9),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }

    // Not in cart → single add button
    if (cartQuantity == 0) {
      return _CartAddButton(onTap: onAdd);
    }

    // In cart → quantity counter
    return _QuantityCounter(
      quantity: cartQuantity,
      onIncrement: onIncrement,
      onDecrement: onDecrement,
    );
  }
}

// ── Add-to-cart button ──

class _CartAddButton extends StatelessWidget {
  final VoidCallback onTap;
  const _CartAddButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: ColorsCustom.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
      ),
    );
  }
}

// ── Quantity counter [ - count + ] ──

class _QuantityCounter extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _QuantityCounter({
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: ColorsCustom.primarySoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Minus
          _counterButton(
            icon: quantity == 1
                ? Icons.delete_outline_rounded
                : Icons.remove_rounded,
            iconSize: quantity == 1 ? 18.0 : 20.0,
            onTap: onDecrement,
          ),

          // Count
          SizedBox(
            width: 32,
            child: Center(
              child: TextCustom(
                text: '$quantity',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: ColorsCustom.primary,
              ),
            ),
          ),

          // Plus
          _counterButton(
            icon: Icons.add_rounded,
            iconSize: 20,
            onTap: onIncrement,
          ),
        ],
      ),
    );
  }

  Widget _counterButton({
    required IconData icon,
    required double iconSize,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 36,
        height: 38,
        child: Icon(icon, color: ColorsCustom.primary, size: iconSize),
      ),
    );
  }
}

// ============================================================
// INFO TAB
// ============================================================

class _InfoTab extends StatelessWidget {
  final RestaurantDetail restaurant;
  const _InfoTab({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (restaurant.description?.isNotEmpty == true)
            _InfoBlock(
              icon: Icons.info_outline_rounded,
              iconColor: ColorsCustom.primary,
              iconBg: ColorsCustom.primarySoft,
              title: l10n.about,
              child: TextCustom.body(text: restaurant.description!),
            ),
          if (restaurant.address != null)
            _InfoBlock(
              icon: Icons.location_on_outlined,
              iconColor: ColorsCustom.primary,
              iconBg: ColorsCustom.primarySoft,
              title: l10n.restaurantAddress,
              child: TextCustom(
                text: restaurant.address!,
                fontSize: 14,
                color: ColorsCustom.textPrimary,
              ),
            ),
          if (restaurant.workingHours.isNotEmpty)
            _InfoBlock(
              icon: Icons.schedule_rounded,
              iconColor: ColorsCustom.success,
              iconBg: ColorsCustom.successBg,
              title: l10n.workingHours,
              child: Column(
                children: restaurant.workingHours
                    .map((h) => _HoursRow(hours: h))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final Widget child;
  const _InfoBlock({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ColorsCustom.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: ColorsCustom.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 16, color: iconColor),
                ),
                const SizedBox(width: 10),
                TextCustom(
                  text: title,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: ColorsCustom.textPrimary,
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _HoursRow extends StatelessWidget {
  final dynamic hours;
  const _HoursRow({required this.hours});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextCustom(
            text: hours.dayName,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: ColorsCustom.textPrimary,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: hours.isClosed
                  ? ColorsCustom.errorBg
                  : ColorsCustom.successBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextCustom(
              text: hours.isClosed
                  ? l10n.closedDay
                  : '${hours.openingTime} - ${hours.closingTime}',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: hours.isClosed ? ColorsCustom.error : ColorsCustom.success,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// FLOATING CART BAR
// ============================================================

class _CartBar extends StatelessWidget {
  final RestaurantDetail? restaurant;
  final VoidCallback onTap;
  const _CartBar({required this.restaurant, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<CartBloc, CartState>(
      builder: (_, __) {
        final cart = context.read<CartBloc>().currentCart;
        if (cart == null ||
            cart.isEmpty ||
            restaurant == null ||
            cart.restaurant?.id != restaurant!.id) {
          return const SizedBox.shrink();
        }
        return Positioned(
          left: 16,
          right: 16,
          bottom: 24,
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              height: 58,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: ColorsCustom.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(51),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: TextCustom(
                        text: '${cart.itemsCount}',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextCustom(
                      text: l10n.viewCart,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  TextCustom(
                    text:
                        '${cart.totalDouble.toStringAsFixed(0)} ${l10n.currency}',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ============================================================
// LOGIN DIALOG
// ============================================================

class _LoginSheet extends StatelessWidget {
  final AppLocalizations l10n;
  final VoidCallback onCancel;
  final VoidCallback onLogin;
  const _LoginSheet({
    required this.l10n,
    required this.onCancel,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: EdgeInsets.zero,
      content: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: ColorsCustom.primarySoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.login_rounded,
                color: ColorsCustom.primary,
                size: 32,
              ),
            ),
            const SizedBox(height: 20),
            TextCustom(
              text: l10n.loginRequired,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: ColorsCustom.textPrimary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            TextCustom.body(
              text: l10n.loginToAddToCart,
              textAlign: TextAlign.center,
              color: ColorsCustom.textSecondary,
            ),
            const SizedBox(height: 24),
            ButtonCustom.primary(text: l10n.login, onPressed: onLogin),
            const SizedBox(height: 10),
            ButtonCustom.secondary(text: l10n.cancel, onPressed: onCancel),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// ERROR VIEW
// ============================================================

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

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
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: ColorsCustom.errorBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                size: 44,
                color: ColorsCustom.error,
              ),
            ),
            const SizedBox(height: 24),
            TextCustom(
              text: message,
              fontSize: 15,
              color: ColorsCustom.textSecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ButtonCustom.primary(
              text: l10n.retry,
              onPressed: onRetry,
              width: 200,
              icon: const Icon(
                Icons.refresh_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// EMPTY ICON
// ============================================================

class _EmptyIcon extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final Color bgColor;
  const _EmptyIcon({
    required this.icon,
    required this.text,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
          child: Icon(icon, size: 44, color: color),
        ),
        const SizedBox(height: 16),
        TextCustom(
          text: text,
          fontSize: 15,
          color: ColorsCustom.textSecondary,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ============================================================
// PRODUCT DETAIL BOTTOM SHEET
// ============================================================

class _ProductDetailSheet extends StatelessWidget {
  final ProductSimpleMenu product;
  final bool isAr;
  final VoidCallback onAdd;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _ProductDetailSheet({
    required this.product,
    required this.isAr,
    required this.onAdd,
    required this.onIncrement,
    required this.onDecrement,
  });

  String get _name {
    if (!isAr && product.nameEn != null && product.nameEn!.isNotEmpty) {
      return product.nameEn!;
    }
    return product.name;
  }

  String? get _description {
    if (!isAr &&
        product.descriptionEn != null &&
        product.descriptionEn!.isNotEmpty) {
      return product.descriptionEn;
    }
    if (product.description != null && product.description!.isNotEmpty) {
      return product.description;
    }
    return null;
  }

  bool get _hasDiscount =>
      product.hasDiscount && product.discountAmountDouble > 0;

  int get _discountPercent =>
      ((product.discountAmountDouble / product.basePriceDouble) * 100).toInt();

  int _getQty(BuildContext context) {
    try {
      final cart = context.read<CartBloc>().currentCart;
      if (cart == null) return 0;
      return cart.items.firstWhere((i) => i.product.id == product.id).quantity;
    } catch (_) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final img = getFullImageUrl(product.image);
    final available = product.isAvailable;
    final bottomPad = MediaQuery.of(context).viewPadding.bottom;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Drag handle ──
          const SizedBox(height: 10),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: ColorsCustom.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 14),

          // ── Scrollable content ──
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Image ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildImage(img, available),
                  ),
                  const SizedBox(height: 18),

                  // ── Name + Price row ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextCustom(
                            text: _name,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: available
                                ? ColorsCustom.textPrimary
                                : ColorsCustom.textHint,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _hasDiscount
                                ? ColorsCustom.primarySoft
                                : ColorsCustom.surfaceVariant,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: TextCustom(
                            text:
                                '${product.currentPriceDouble.toStringAsFixed(0)} ${l10n.currency}',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _hasDiscount
                                ? ColorsCustom.primary
                                : ColorsCustom.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Old price + discount badge ──
                  if (_hasDiscount) ...[
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          TextCustom(
                            text:
                                '${product.basePriceDouble.toStringAsFixed(0)} ${l10n.currency}',
                            fontSize: 14,
                            color: ColorsCustom.textHint,
                            decoration: TextDecoration.lineThrough,
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: ColorsCustom.successBg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: TextCustom(
                              text: '-$_discountPercent%',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: ColorsCustom.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // ── Unavailable badge ──
                  if (!available) ...[
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: ColorsCustom.errorBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.block_rounded,
                              size: 13,
                              color: ColorsCustom.error,
                            ),
                            const SizedBox(width: 5),
                            TextCustom(
                              text: l10n.unavailable,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: ColorsCustom.error,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  // ── Description ──
                  if (_description != null) ...[
                    const SizedBox(height: 14),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextCustom(
                        text: _description!,
                        fontSize: 14,
                        color: ColorsCustom.textSecondary,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // ── Action bar ──
          if (available)
            BlocBuilder<CartBloc, CartState>(
              builder: (ctx, state) {
                final qty = _getQty(ctx);
                final isLoading = state is CartLoading;
                return Container(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    12,
                    16,
                    bottomPad > 0 ? bottomPad : 16,
                  ),
                  decoration: BoxDecoration(
                    color: ColorsCustom.background,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(8),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: _buildActionBar(l10n, qty, isLoading),
                );
              },
            ),
        ],
      ),
    );
  }

  // ── Image ──

  Widget _buildImage(String img, bool available) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: 200,
            color: ColorsCustom.surfaceVariant,
            child: img.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: img,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 200,
                    placeholder: (_, __) => _placeholder(),
                    errorWidget: (_, __, ___) => _placeholder(),
                  )
                : _placeholder(),
          ),
          // Gradient at bottom for depth
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withAlpha(30)],
                ),
              ),
            ),
          ),
          // Discount badge
          if (_hasDiscount)
            PositionedDirectional(
              top: 10,
              start: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: ColorsCustom.primary,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: ColorsCustom.primary.withAlpha(77),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextCustom(
                  text: '-$_discountPercent%',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          if (!available)
            Positioned.fill(
              child: Container(color: Colors.white.withAlpha(153)),
            ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return const Center(
      child: Icon(
        Icons.fastfood_rounded,
        color: ColorsCustom.textHint,
        size: 44,
      ),
    );
  }

  // ── Action bar ──

  Widget _buildActionBar(AppLocalizations l10n, int qty, bool loading) {
    if (loading) {
      return Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: ColorsCustom.primary.withAlpha(179),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
      );
    }

    if (qty == 0) {
      return Material(
        color: ColorsCustom.primary,
        borderRadius: BorderRadius.circular(14),
        elevation: 2,
        shadowColor: ColorsCustom.primary.withAlpha(60),
        child: InkWell(
          onTap: onAdd,
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.add_shopping_cart_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
                TextCustom(
                  text: l10n.addToCart,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Quantity counter
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: ColorsCustom.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ColorsCustom.border),
      ),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onDecrement,
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(13),
                right: Radius.zero,
              ),
              child: SizedBox(
                width: 60,
                height: 52,
                child: Icon(
                  qty == 1
                      ? Icons.delete_outline_rounded
                      : Icons.remove_rounded,
                  color: qty == 1 ? ColorsCustom.error : ColorsCustom.primary,
                  size: 22,
                ),
              ),
            ),
          ),
          Container(width: 1, height: 28, color: ColorsCustom.border),
          Expanded(
            child: Center(
              child: TextCustom(
                text: '$qty',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: ColorsCustom.textPrimary,
              ),
            ),
          ),
          Container(width: 1, height: 28, color: ColorsCustom.border),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onIncrement,
              borderRadius: const BorderRadius.horizontal(
                left: Radius.zero,
                right: Radius.circular(13),
              ),
              child: const SizedBox(
                width: 60,
                height: 52,
                child: Icon(
                  Icons.add_rounded,
                  color: ColorsCustom.primary,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
