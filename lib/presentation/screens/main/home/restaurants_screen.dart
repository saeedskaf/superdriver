import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:superdriver/domain/bloc/restaurant/restaurant_bloc.dart';
import 'package:superdriver/domain/bloc/menu/menu_bloc.dart';
import 'package:superdriver/domain/bloc/cart/cart_bloc.dart';
import 'package:superdriver/domain/models/restaurant_model.dart';
import 'package:superdriver/l10n/app_localizations.dart';
import 'package:superdriver/presentation/components/btn_custom.dart';
import 'package:superdriver/presentation/components/text_custom.dart';
import 'package:superdriver/presentation/screens/main/home/home_widgets.dart';
import 'package:superdriver/presentation/screens/main/home/restaurant_detail_screen.dart';
import 'package:superdriver/presentation/themes/colors_custom.dart';

// ============================================================
// SCREEN MODES
// ============================================================

enum RestaurantsScreenMode {
  all,
  category,
  search,
  featured,
  popular,
  discount,
  nearby,
  newRestaurants,
}

// ============================================================
// RESTAURANTS SCREEN
// ============================================================

class RestaurantsScreen extends StatefulWidget {
  final RestaurantsScreenMode mode;
  final int? categoryId;
  final String? categoryName;
  final String? title;
  final String? initialSearchQuery;
  final double? latitude;
  final double? longitude;

  const RestaurantsScreen({
    super.key,
    this.mode = RestaurantsScreenMode.all,
    this.categoryId,
    this.categoryName,
    this.title,
    this.initialSearchQuery,
    this.latitude,
    this.longitude,
  });

  factory RestaurantsScreen.category({
    required int categoryId,
    required String categoryName,
    double? latitude,
    double? longitude,
  }) => RestaurantsScreen(
    mode: RestaurantsScreenMode.category,
    categoryId: categoryId,
    categoryName: categoryName,
    title: categoryName,
    latitude: latitude,
    longitude: longitude,
  );

  factory RestaurantsScreen.search({
    String? initialQuery,
    double? latitude,
    double? longitude,
  }) => RestaurantsScreen(
    mode: RestaurantsScreenMode.search,
    initialSearchQuery: initialQuery,
    latitude: latitude,
    longitude: longitude,
  );

  factory RestaurantsScreen.featured({double? latitude, double? longitude}) =>
      RestaurantsScreen(
        mode: RestaurantsScreenMode.featured,
        latitude: latitude,
        longitude: longitude,
      );

  factory RestaurantsScreen.popular({double? latitude, double? longitude}) =>
      RestaurantsScreen(
        mode: RestaurantsScreenMode.popular,
        latitude: latitude,
        longitude: longitude,
      );

  factory RestaurantsScreen.discount({double? latitude, double? longitude}) =>
      RestaurantsScreen(
        mode: RestaurantsScreenMode.discount,
        latitude: latitude,
        longitude: longitude,
      );

  factory RestaurantsScreen.nearby({
    required double latitude,
    required double longitude,
  }) => RestaurantsScreen(
    mode: RestaurantsScreenMode.nearby,
    latitude: latitude,
    longitude: longitude,
  );

  factory RestaurantsScreen.newRestaurants({
    double? latitude,
    double? longitude,
  }) => RestaurantsScreen(
    mode: RestaurantsScreenMode.newRestaurants,
    latitude: latitude,
    longitude: longitude,
  );

  @override
  State<RestaurantsScreen> createState() => _RestaurantsScreenState();
}

class _RestaurantsScreenState extends State<RestaurantsScreen> {
  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();
  final _scrollCtrl = ScrollController();

  // ── Filters ──
  bool _openNow = false;
  bool _hasDiscount = false;
  bool _freeDelivery = false;
  String? _sorting;
  String _query = '';

  // ── Pagination ──
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  List<RestaurantListItem> _allItems = [];

  static const _pageSize = 10;

  @override
  void initState() {
    super.initState();
    if (widget.initialSearchQuery != null) {
      _searchCtrl.text = widget.initialSearchQuery!;
      _query = widget.initialSearchQuery!;
    }
    if (widget.mode == RestaurantsScreenMode.search) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _searchFocus.requestFocus();
      });
    }
    _initFilters();
    _scrollCtrl.addListener(_onScroll);
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    _scrollCtrl.removeListener(_onScroll);
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _initFilters() {
    if (widget.mode == RestaurantsScreenMode.discount) _hasDiscount = true;
    if (widget.mode == RestaurantsScreenMode.popular) {
      _sorting = '-total_orders';
    }
  }

  // ============================================================
  // DATA
  // ============================================================

  void _load() {
    _currentPage = 1;
    _hasMore = true;
    _allItems = [];

    final bloc = context.read<RestaurantBloc>();

    // Nearby mode uses a dedicated endpoint (no pagination)
    if (widget.mode == RestaurantsScreenMode.nearby &&
        widget.latitude != null &&
        widget.longitude != null) {
      bloc.add(
        NearbyRestaurantsLoadRequested(
          lat: widget.latitude!,
          lng: widget.longitude!,
        ),
      );
      return;
    }

    bloc.add(RestaurantsLoadRequested(filters: _filters()));
  }

  void _loadMore() {
    if (_isLoadingMore || !_hasMore) return;
    if (widget.mode == RestaurantsScreenMode.nearby) return;

    setState(() => _isLoadingMore = true);
    _currentPage++;
    context.read<RestaurantBloc>().add(
      RestaurantsLoadRequested(filters: _filters()),
    );
  }

  /// Build filter params including location (Fix 4) and pagination (Fix 5).
  RestaurantFilterParams _filters() => RestaurantFilterParams(
    categoryId: widget.mode == RestaurantsScreenMode.category
        ? widget.categoryId
        : null,
    search: _query.isNotEmpty ? _query : null,
    isCurrentlyOpen: _openNow ? true : null,
    hasDiscount: _hasDiscount ? true : null,
    isFeatured: widget.mode == RestaurantsScreenMode.featured ? true : null,
    ordering: _sorting ?? _defaultSort(),
    lat: widget.latitude,
    lng: widget.longitude,
    page: _currentPage,
    pageSize: _pageSize,
  );

  String? _defaultSort() => switch (widget.mode) {
    RestaurantsScreenMode.popular => '-total_orders',
    RestaurantsScreenMode.newRestaurants => '-created_at',
    _ => null,
  };

  void _onSearch(String q) {
    setState(() => _query = q.trim());
    _load();
  }

  void _clearSearch() {
    _searchCtrl.clear();
    setState(() => _query = '');
    _load();
  }

  void _clearFilters() {
    setState(() {
      _openNow = false;
      _hasDiscount = widget.mode == RestaurantsScreenMode.discount;
      _freeDelivery = false;
      _sorting = _defaultSort();
    });
    _load();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  /// Client-side free delivery filter (Fix 3).
  /// Only matches restaurants where deliveryFee is explicitly 0,
  /// not null (unknown because no lat/lng was provided).
  List<RestaurantListItem> _clientFilter(List<RestaurantListItem> list) {
    if (_freeDelivery) {
      return list
          .where((r) => r.deliveryFee != null && r.deliveryFee == 0)
          .toList();
    }
    return list;
  }

  String _title(AppLocalizations l10n) {
    if (widget.title != null) return widget.title!;
    if (widget.categoryName != null) return widget.categoryName!;
    return switch (widget.mode) {
      RestaurantsScreenMode.all => l10n.allRestaurants,
      RestaurantsScreenMode.category => widget.categoryName ?? l10n.restaurants,
      RestaurantsScreenMode.search => l10n.search,
      RestaurantsScreenMode.featured => l10n.featuredRestaurants,
      RestaurantsScreenMode.popular => l10n.popularRestaurants,
      RestaurantsScreenMode.discount => l10n.discountRestaurants,
      RestaurantsScreenMode.nearby => l10n.nearbyRestaurants,
      RestaurantsScreenMode.newRestaurants => l10n.newRestaurants,
    };
  }

  /// Fix 1+2: Create fresh Bloc instances (not shared) with CartBloc.
  void _goToRestaurant(RestaurantListItem r) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => RestaurantBloc()),
            BlocProvider(create: (_) => MenuBloc()),
            BlocProvider(create: (_) => CartBloc()),
          ],
          child: RestaurantDetailScreen(
            slug: r.slug,
            lat: widget.latitude,
            lng: widget.longitude,
          ),
        ),
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
      body: Column(
        children: [
          _buildAppBar(l10n),
          _buildSearch(l10n),
          _buildFilters(l10n),
          Expanded(
            child: BlocConsumer<RestaurantBloc, RestaurantState>(
              listener: (_, s) {
                if (s is RestaurantsLoaded) {
                  final incoming = s.restaurants;
                  setState(() {
                    if (_isLoadingMore) {
                      _allItems = [..._allItems, ...incoming];
                      _hasMore = incoming.length >= _pageSize;
                      _isLoadingMore = false;
                    } else {
                      _allItems = incoming;
                      _hasMore = incoming.length >= _pageSize;
                    }
                  });
                }
                if (s is NearbyRestaurantsLoaded) {
                  setState(() {
                    _allItems = s.restaurants;
                    _hasMore = false;
                  });
                }
                if (s is RestaurantsEmpty ||
                    s is RestaurantsSearchEmpty ||
                    s is RestaurantsError) {
                  if (_isLoadingMore) {
                    setState(() {
                      _hasMore = false;
                      _isLoadingMore = false;
                    });
                  }
                }
              },
              builder: (_, s) => _buildBody(l10n, s),
            ),
          ),
        ],
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

  Widget _buildAppBar(AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        bottom: 12,
        left: 16,
        right: 16,
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
          const SizedBox(width: 14),
          Expanded(
            child: TextCustom(
              text: _title(l10n),
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: ColorsCustom.textPrimary,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Results count badge
          if (_allItems.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: ColorsCustom.secondarySoft,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextCustom(
                text: '${_allItems.length}',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: ColorsCustom.secondaryDark,
              ),
            )
          else
            const SizedBox(width: 40),
        ],
      ),
    );
  }

  // ── Search ──

  Widget _buildSearch(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: ColorsCustom.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: ColorsCustom.border),
        ),
        child: TextField(
          controller: _searchCtrl,
          focusNode: _searchFocus,
          onChanged: _onSearch,
          onSubmitted: _onSearch,
          textInputAction: TextInputAction.search,
          style: const TextStyle(
            fontSize: 14,
            color: ColorsCustom.textPrimary,
            fontFamily: 'Cairo',
          ),
          decoration: InputDecoration(
            hintText: l10n.searchRestaurants,
            hintStyle: const TextStyle(
              color: ColorsCustom.textHint,
              fontSize: 14,
              fontFamily: 'Cairo',
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: ColorsCustom.textHint,
              size: 22,
            ),
            suffixIcon: _searchCtrl.text.isNotEmpty
                ? IconButton(
                    onPressed: _clearSearch,
                    icon: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: ColorsCustom.surfaceVariant,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: ColorsCustom.textSecondary,
                        size: 16,
                      ),
                    ),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }

  // ── Filters ──

  Widget _buildFilters(AppLocalizations l10n) {
    final hasActive =
        _openNow || _hasDiscount || _freeDelivery || _sorting != null;

    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        children: [
          // Clear indicator
          if (hasActive)
            GestureDetector(
              onTap: _clearFilters,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 40,
                decoration: BoxDecoration(
                  color: ColorsCustom.errorBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: ColorsCustom.error.withAlpha(77)),
                ),
                child: const Icon(
                  Icons.filter_alt_off_rounded,
                  size: 18,
                  color: ColorsCustom.error,
                ),
              ),
            ),
          _FilterChip(
            label: l10n.openNow,
            icon: Icons.access_time_rounded,
            isActive: _openNow,
            activeColor: ColorsCustom.success,
            activeBg: ColorsCustom.successBg,
            onTap: () {
              setState(() => _openNow = !_openNow);
              _load();
            },
          ),
          if (widget.mode != RestaurantsScreenMode.discount)
            _FilterChip(
              label: l10n.hasOffers,
              icon: Icons.local_offer_rounded,
              isActive: _hasDiscount,
              activeColor: ColorsCustom.primary,
              activeBg: ColorsCustom.primarySoft,
              onTap: () {
                setState(() => _hasDiscount = !_hasDiscount);
                _load();
              },
            ),
          _FilterChip(
            label: l10n.freeDelivery,
            icon: Icons.delivery_dining_rounded,
            isActive: _freeDelivery,
            activeColor: ColorsCustom.secondaryDark,
            activeBg: ColorsCustom.secondarySoft,
            onTap: () {
              setState(() => _freeDelivery = !_freeDelivery);
              // Client-side only filter — no API re-fetch needed
            },
          ),
          _SortChip(
            label: l10n.sortBy,
            sorting: _sorting,
            onChanged: (s) {
              setState(() => _sorting = s);
              _load();
            },
          ),
        ],
      ),
    );
  }

  // ── Body content ──

  Widget _buildBody(AppLocalizations l10n, RestaurantState s) {
    // Initial loading
    if (s is RestaurantsLoading || s is NearbyRestaurantsLoading) {
      if (_allItems.isNotEmpty) {
        return _buildList(_clientFilter(_allItems), refreshing: true);
      }
      return const Center(
        child: CircularProgressIndicator(color: ColorsCustom.primary),
      );
    }

    // Errors (only show full-screen if no cached data)
    if (s is RestaurantsError && _allItems.isEmpty) {
      return _StateView.error(msg: s.message, onRetry: _load);
    }
    if (s is NearbyRestaurantsError) {
      return _StateView.error(msg: s.message, onRetry: _load);
    }

    // Empty
    if ((s is RestaurantsEmpty || s is NearbyRestaurantsEmpty) &&
        _allItems.isEmpty) {
      final hasF = _openNow || _hasDiscount || _freeDelivery;
      return _StateView.empty(onClear: hasF ? _clearFilters : null);
    }
    if (s is RestaurantsSearchEmpty) {
      return _StateView.searchEmpty(query: s.query);
    }

    // Data — use accumulated items
    final list = _clientFilter(_allItems);
    if (list.isEmpty && _allItems.isNotEmpty) {
      // All items filtered out by client-side filter (free delivery)
      return _StateView.empty(
        onClear: () {
          setState(() => _freeDelivery = false);
        },
      );
    }
    if (list.isEmpty) {
      final hasF = _openNow || _hasDiscount || _freeDelivery;
      return _StateView.empty(onClear: hasF ? _clearFilters : null);
    }

    return _buildList(list);
  }

  Widget _buildList(List<RestaurantListItem> list, {bool refreshing = false}) {
    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () async => _load(),
          color: ColorsCustom.primary,
          child: ListView.separated(
            controller: _scrollCtrl,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: list.length + (_hasMore ? 1 : 0),
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              // Pagination loading indicator
              if (i >= list.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: ColorsCustom.primary,
                      ),
                    ),
                  ),
                );
              }
              return RestaurantCard(
                restaurant: list[i],
                onTap: () => _goToRestaurant(list[i]),
              );
            },
          ),
        ),
        if (refreshing)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(
              backgroundColor: ColorsCustom.secondarySoft,
              valueColor: const AlwaysStoppedAnimation<Color>(
                ColorsCustom.secondary,
              ),
            ),
          ),
      ],
    );
  }
}

// ============================================================
// FILTER CHIP — colored per type
// ============================================================

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final Color activeColor;
  final Color activeBg;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.activeColor,
    required this.activeBg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? activeBg : ColorsCustom.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? activeColor.withAlpha(128) : ColorsCustom.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? activeColor : ColorsCustom.textHint,
            ),
            const SizedBox(width: 6),
            TextCustom(
              text: label,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isActive ? activeColor : ColorsCustom.textPrimary,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// SORT CHIP + SHEET
// ============================================================

class _SortChip extends StatelessWidget {
  final String label;
  final String? sorting;
  final ValueChanged<String?> onChanged;

  const _SortChip({
    required this.label,
    required this.sorting,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final on = sorting != null;
    return GestureDetector(
      onTap: () => _showSheet(context),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: on ? ColorsCustom.primary : ColorsCustom.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: on ? ColorsCustom.primary : ColorsCustom.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sort_rounded,
              size: 16,
              color: on ? Colors.white : ColorsCustom.textHint,
            ),
            const SizedBox(width: 6),
            TextCustom(
              text: label,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: on ? Colors.white : ColorsCustom.textPrimary,
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: on ? Colors.white : ColorsCustom.textHint,
            ),
          ],
        ),
      ),
    );
  }

  void _showSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final options = [
      (
        v: null,
        l: l10n.defaultSort,
        i: Icons.tune_rounded,
        c: ColorsCustom.textSecondary,
      ),
      (
        v: '-average_rating',
        l: l10n.rating,
        i: Icons.star_rounded,
        c: ColorsCustom.secondary,
      ),
      (
        v: '-total_orders',
        l: l10n.mostOrdered,
        i: Icons.trending_up_rounded,
        c: ColorsCustom.success,
      ),
      (
        v: 'delivery_fee',
        l: l10n.deliveryFeeSort,
        i: Icons.delivery_dining_rounded,
        c: ColorsCustom.secondaryDark,
      ),
      (
        v: 'minimum_order_amount',
        l: l10n.minimumOrderSort,
        i: Icons.shopping_bag_rounded,
        c: ColorsCustom.primary,
      ),
      (
        v: '-created_at',
        l: l10n.newest,
        i: Icons.new_releases_rounded,
        c: ColorsCustom.warning,
      ),
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: ColorsCustom.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final bottomPadding = MediaQuery.of(ctx).viewPadding.bottom;
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              12,
              16,
              bottomPadding > 0 ? bottomPadding : 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: ColorsCustom.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextCustom.subheading(text: l10n.sortBy),
                ),
                const SizedBox(height: 16),
                ...options.map((o) {
                  final sel = sorting == o.v;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          onChanged(o.v);
                          Navigator.pop(ctx);
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: sel ? ColorsCustom.primarySoft : null,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: sel
                                      ? o.c.withAlpha(26)
                                      : ColorsCustom.surfaceVariant,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  o.i,
                                  size: 20,
                                  color: sel ? o.c : ColorsCustom.textHint,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: TextCustom(
                                  text: o.l,
                                  fontSize: 15,
                                  fontWeight: sel
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: ColorsCustom.textPrimary,
                                ),
                              ),
                              if (sel)
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: ColorsCustom.primary,
                                  size: 22,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ============================================================
// STATE VIEWS (error / empty / search-empty)
// ============================================================

class _StateView extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String title;
  final String? subtitle;
  final String? btnText;
  final IconData? btnIcon;
  final VoidCallback? onBtn;

  const _StateView({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.title,
    this.subtitle,
    this.btnText,
    this.btnIcon,
    this.onBtn,
  });

  factory _StateView.error({
    required String msg,
    required VoidCallback onRetry,
  }) {
    return _StateView(
      icon: Icons.cloud_off_rounded,
      iconColor: ColorsCustom.error,
      bgColor: ColorsCustom.errorBg,
      title: msg,
      btnText: 'retry',
      btnIcon: Icons.refresh_rounded,
      onBtn: onRetry,
    );
  }

  factory _StateView.empty({VoidCallback? onClear}) {
    return _StateView(
      icon: Icons.restaurant_rounded,
      iconColor: ColorsCustom.secondary,
      bgColor: ColorsCustom.secondarySoft,
      title: 'noRestaurants',
      subtitle: 'tryChangingFilters',
      btnText: onClear != null ? 'clearFilters' : null,
      btnIcon: Icons.filter_alt_off_rounded,
      onBtn: onClear,
    );
  }

  factory _StateView.searchEmpty({required String query}) {
    return _StateView(
      icon: Icons.search_off_rounded,
      iconColor: ColorsCustom.warning,
      bgColor: ColorsCustom.warningBg,
      title: query,
      subtitle: 'tryDifferentKeywords',
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final resolvedTitle = switch (title) {
      'noRestaurants' => l10n.noRestaurants,
      _ =>
        title.contains('tryDifferentKeywords')
            ? title
            : (icon == Icons.search_off_rounded
                  ? '${l10n.noResultsFor} "$title"'
                  : title),
    };
    final resolvedSub = switch (subtitle) {
      'tryChangingFilters' => l10n.tryChangingFilters,
      'tryDifferentKeywords' => l10n.tryDifferentKeywords,
      _ => subtitle,
    };
    final resolvedBtn = switch (btnText) {
      'retry' => l10n.retry,
      'clearFilters' => l10n.clearFilters,
      _ => btnText,
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
              child: Icon(icon, size: 48, color: iconColor),
            ),
            const SizedBox(height: 24),
            TextCustom(
              text: resolvedTitle,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: ColorsCustom.textPrimary,
              textAlign: TextAlign.center,
            ),
            if (resolvedSub != null) ...[
              const SizedBox(height: 8),
              TextCustom.caption(
                text: resolvedSub,
                textAlign: TextAlign.center,
                fontSize: 14,
              ),
            ],
            if (onBtn != null && resolvedBtn != null) ...[
              const SizedBox(height: 24),
              ButtonCustom.primary(
                text: resolvedBtn,
                onPressed: onBtn,
                width: 180,
                icon: Icon(btnIcon!, color: Colors.white, size: 18),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
