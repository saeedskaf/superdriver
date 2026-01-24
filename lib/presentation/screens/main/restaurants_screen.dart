import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:superdriver/domain/bloc/restaurant/restaurant_bloc.dart';
import 'package:superdriver/domain/models/restaurant_model.dart';
import 'package:superdriver/l10n/app_localizations.dart';
import 'package:superdriver/presentation/components/text_custom.dart';
import 'package:superdriver/presentation/themes/colors_custom.dart';

class RestaurantsScreen extends StatefulWidget {
  final String? categorySlug;
  final String? categoryName;

  const RestaurantsScreen({super.key, this.categorySlug, this.categoryName});

  @override
  State<RestaurantsScreen> createState() => _RestaurantsScreenState();
}

class _RestaurantsScreenState extends State<RestaurantsScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Filter states
  bool _openNowFilter = false;
  bool _hasDiscountFilter = false;
  bool _isFeaturedFilter = false;
  String? _selectedSorting;

  @override
  void initState() {
    super.initState();
    _loadRestaurants();
  }

  void _loadRestaurants() {
    if (widget.categorySlug != null) {
      context.read<RestaurantBloc>().add(
        RestaurantsByCategoryLoadRequested(
          categorySlug: widget.categorySlug!,
          // If your event supports filters, uncomment:
          // filters: _buildFilterParams(),
        ),
      );
    } else {
      context.read<RestaurantBloc>().add(
        RestaurantsLoadRequested(filters: _buildFilterParams()),
      );
    }
  }

  // ✅ Params builder (renamed to avoid conflict with widgets builder)
  RestaurantFilterParams _buildFilterParams() {
    return RestaurantFilterParams(
      isOpen: _openNowFilter ? true : null,
      hasDiscount: _hasDiscountFilter ? true : null,
      isFeatured: _isFeaturedFilter ? true : null,
      ordering: _selectedSorting,
    );
  }

  void _onSearch(String query) {
    if (query.trim().isEmpty) {
      context.read<RestaurantBloc>().add(const RestaurantsSearchCleared());
    } else {
      context.read<RestaurantBloc>().add(
        RestaurantsSearchRequested(query: query),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: ColorsCustom.background,
      appBar: _buildAppBar(context, l10n),
      body: Column(
        children: [
          // Search Bar
          _buildSearchBar(context, l10n),

          // ✅ Filters (widgets)
          _buildFiltersBar(context, l10n),

          // Restaurant List
          Expanded(
            child: BlocBuilder<RestaurantBloc, RestaurantState>(
              builder: (context, state) {
                if (state is RestaurantsLoading ||
                    state is RestaurantsSearching) {
                  return _buildLoadingState();
                }

                if (state is RestaurantsError) {
                  return _buildErrorState(context, l10n, state.message);
                }

                if (state is RestaurantsEmpty ||
                    state is RestaurantsSearchEmpty) {
                  return _buildEmptyState(context, l10n);
                }

                List<RestaurantListItem> restaurants = [];
                if (state is RestaurantsLoaded) {
                  restaurants = state.restaurants;
                } else if (state is RestaurantsSearchResults) {
                  restaurants = state.restaurants;
                }

                if (restaurants.isEmpty) {
                  return _buildEmptyState(context, l10n);
                }

                return _buildRestaurantsList(context, l10n, restaurants);
              },
            ),
          ),
        ],
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
      title: TextCustom(
        text: widget.categoryName ?? l10n.allRestaurants,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: ColorsCustom.textPrimary,
      ),
      centerTitle: true,
    );
  }

  Widget _buildSearchBar(BuildContext context, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearch,
        decoration: InputDecoration(
          hintText: l10n.searchPlaceholder,
          hintStyle: TextStyle(color: ColorsCustom.textSecondary, fontSize: 14),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: ColorsCustom.textSecondary,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    _onSearch('');
                    setState(() {}); // refresh suffix icon
                  },
                  icon: Icon(
                    Icons.close_rounded,
                    color: ColorsCustom.textSecondary,
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
    );
  }

  // ✅ Widgets builder renamed to avoid conflict
  Widget _buildFiltersBar(BuildContext context, AppLocalizations l10n) {
    return SizedBox(
      height: 45,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          _buildFilterChip(
            label: l10n.openNow,
            isSelected: _openNowFilter,
            onTap: () {
              setState(() => _openNowFilter = !_openNowFilter);
              _loadRestaurants();
            },
          ),
          _buildFilterChip(
            label: l10n.hasOffers,
            isSelected: _hasDiscountFilter,
            onTap: () {
              setState(() => _hasDiscountFilter = !_hasDiscountFilter);
              _loadRestaurants();
            },
          ),
          _buildFilterChip(
            label: l10n.featured,
            isSelected: _isFeaturedFilter,
            onTap: () {
              setState(() => _isFeaturedFilter = !_isFeaturedFilter);
              _loadRestaurants();
            },
          ),
          _buildSortingChip(context, l10n),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? ColorsCustom.primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? ColorsCustom.primary : ColorsCustom.grey300,
          ),
        ),
        child: TextCustom(
          text: label,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: isSelected ? Colors.white : ColorsCustom.textPrimary,
        ),
      ),
    );
  }

  Widget _buildSortingChip(BuildContext context, AppLocalizations l10n) {
    return GestureDetector(
      onTap: () => _showSortingModal(context, l10n),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: _selectedSorting != null ? ColorsCustom.primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _selectedSorting != null
                ? ColorsCustom.primary
                : ColorsCustom.grey300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sort_rounded,
              size: 18,
              color: _selectedSorting != null
                  ? Colors.white
                  : ColorsCustom.textPrimary,
            ),
            const SizedBox(width: 6),
            TextCustom(
              text: l10n.sortBy,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _selectedSorting != null
                  ? Colors.white
                  : ColorsCustom.textPrimary,
            ),
          ],
        ),
      ),
    );
  }

  void _showSortingModal(BuildContext context, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: ColorsCustom.grey300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextCustom(
              text: l10n.sortBy,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: ColorsCustom.textPrimary,
            ),
            const SizedBox(height: 16),
            _buildSortOption(l10n.rating, 'average_rating', l10n),
            _buildSortOption(l10n.mostOrdered, 'total_orders', l10n),
            _buildSortOption(l10n.deliveryFeeSort, 'delivery_fee', l10n),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String label, String value, AppLocalizations l10n) {
    final isSelected = _selectedSorting == value;
    return ListTile(
      onTap: () {
        setState(() {
          _selectedSorting = isSelected ? null : value;
        });
        Navigator.pop(context);
        _loadRestaurants();
      },
      leading: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
        color: isSelected ? ColorsCustom.primary : ColorsCustom.grey400,
      ),
      title: TextCustom(
        text: label,
        fontSize: 16,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: ColorsCustom.textPrimary,
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(ColorsCustom.primary),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant_rounded, size: 80, color: ColorsCustom.grey300),
          const SizedBox(height: 16),
          TextCustom(
            text: l10n.noRestaurants,
            fontSize: 18,
            fontWeight: FontWeight.bold,
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, size: 60, color: Colors.redAccent),
          const SizedBox(height: 16),
          TextCustom(
            text: message,
            fontSize: 14,
            color: ColorsCustom.textSecondary,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadRestaurants,
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorsCustom.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: TextCustom(
              text: l10n.retry,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantsList(
    BuildContext context,
    AppLocalizations l10n,
    List<RestaurantListItem> restaurants,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<RestaurantBloc>().add(const RestaurantsRefreshRequested());
      },
      color: ColorsCustom.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: restaurants.length,
        itemBuilder: (context, index) {
          final restaurant = restaurants[index];
          return _buildRestaurantCard(context, l10n, restaurant);
        },
      ),
    );
  }

  Widget _buildRestaurantCard(
    BuildContext context,
    AppLocalizations l10n,
    RestaurantListItem restaurant,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<RestaurantBloc>(),
              child: RestaurantDetailsScreen(slug: restaurant.slug),
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: ColorsCustom.grey200,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: restaurant.logo != null
                      ? ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                          child: Image.network(
                            restaurant.logo!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildPlaceholder(),
                          ),
                        )
                      : _buildPlaceholder(),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: restaurant.isCurrentlyOpen
                          ? Colors.green.shade500
                          : Colors.red.shade500,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextCustom(
                      text: restaurant.isCurrentlyOpen
                          ? l10n.open
                          : l10n.closed,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (restaurant.hasDiscount)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: ColorsCustom.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.local_offer_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          TextCustom(
                            text: '${restaurant.discountDouble.toInt()}%',
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                if (restaurant.isFeatured)
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade600,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 3),
                          TextCustom(
                            text: l10n.featured,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextCustom(
                          text: restaurant.name,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: ColorsCustom.textPrimary,
                          maxLines: 1,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.star_rounded,
                              size: 16,
                              color: Colors.amber.shade600,
                            ),
                            const SizedBox(width: 4),
                            TextCustom(
                              text: restaurant.ratingDouble.toStringAsFixed(1),
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber.shade700,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 16,
                        color: ColorsCustom.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      TextCustom(
                        text: restaurant.deliveryTimeEstimate ?? '20-30',
                        fontSize: 13,
                        color: ColorsCustom.textSecondary,
                      ),
                      const SizedBox(width: 16),
                      if (restaurant.deliveryFeeDouble == 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: TextCustom(
                            text: l10n.freeDelivery,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.green.shade700,
                          ),
                        )
                      else
                        Row(
                          children: [
                            Icon(
                              Icons.delivery_dining_rounded,
                              size: 16,
                              color: ColorsCustom.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            TextCustom(
                              text:
                                  '${restaurant.deliveryFeeDouble.toStringAsFixed(0)} ${l10n.currency}',
                              fontSize: 13,
                              color: ColorsCustom.textSecondary,
                            ),
                          ],
                        ),
                      const Spacer(),
                      TextCustom(
                        text: '(${restaurant.totalReviews} ${l10n.reviews})',
                        fontSize: 12,
                        color: ColorsCustom.textSecondary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Icon(
        Icons.restaurant_rounded,
        size: 50,
        color: ColorsCustom.grey400,
      ),
    );
  }
}

// Placeholder for Restaurant Details Screen
class RestaurantDetailsScreen extends StatelessWidget {
  final String slug;

  const RestaurantDetailsScreen({super.key, required this.slug});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Restaurant Details')));
  }
}
